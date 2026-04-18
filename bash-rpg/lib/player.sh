#!/usr/bin/env bash
# lib/player.sh – Player state management

# shellcheck source=lib/ui.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/colors.sh"
source "${SCRIPT_DIR}/ui.sh"
source "${SCRIPT_DIR}/talents.sh"

# ──────────────────────────────────────────────────────────────────────────────
# Player state (global variables)
# ──────────────────────────────────────────────────────────────────────────────
PLAYER_NAME=""
PLAYER_LEVEL=1
PLAYER_XP=0
PLAYER_XP_NEXT=100
PLAYER_HP=100
PLAYER_MAX_HP=100
PLAYER_GOLD=0
PLAYER_ATTACK=10
PLAYER_DEFENSE=5
PLAYER_TALENT_POINTS=0
TALENT_OFFENSE_LEVEL=0
TALENT_DEFENSE_LEVEL=0
TALENT_KNOWLEDGE_LEVEL=0
TALENT_KNOWLEDGE_HINTS=0
declare -a PLAYER_INVENTORY=()
CURRENT_LEVEL=1

# Domyślne wartości efektów bojowych (faktycznie wykorzystywane przez lib/combat.sh).
# Utrzymujemy je także tutaj, aby użycie przedmiotów poza walką nie powodowało błędów.
PLAYER_SHIELD_VALUE=${PLAYER_SHIELD_VALUE:-0}
PLAYER_STATUS_STUN_TURNS=${PLAYER_STATUS_STUN_TURNS:-0}
PLAYER_STATUS_BLEED_TURNS=${PLAYER_STATUS_BLEED_TURNS:-0}
PLAYER_STATUS_BLEED_DAMAGE=${PLAYER_STATUS_BLEED_DAMAGE:-0}
ENEMY_STATUS_BLEED_TURNS=${ENEMY_STATUS_BLEED_TURNS:-0}
ENEMY_STATUS_BLEED_DAMAGE=${ENEMY_STATUS_BLEED_DAMAGE:-0}

# XP thresholds per level (index = level)
XP_TABLE=(0 100 250 450 700 1000 1400 1900 2500 3200 4000)
MAX_HP_TABLE=(0 100 120 145 175 210 250 300 360 430 500)

# ──────────────────────────────────────────────────────────────────────────────
# Initialization
# ──────────────────────────────────────────────────────────────────────────────

player_create() {
    local name="$1"
    PLAYER_NAME="$name"
    PLAYER_LEVEL=1
    PLAYER_XP=0
    PLAYER_XP_NEXT=${XP_TABLE[2]}   # 250 XP to reach level 2
    PLAYER_HP=100
    PLAYER_MAX_HP=100
    PLAYER_GOLD=0
    PLAYER_ATTACK=10
    PLAYER_DEFENSE=5
    PLAYER_INVENTORY=()
    CURRENT_LEVEL=1
    talents_reset
}

# ──────────────────────────────────────────────────────────────────────────────
# Experience & Leveling
# ──────────────────────────────────────────────────────────────────────────────

player_add_xp() {
    local amount="$1"
    PLAYER_XP=$(( PLAYER_XP + amount ))
    ui_xp_gain "$amount"

    # Check for level up(s)
    local max_level=$(( ${#XP_TABLE[@]} - 1 ))
    while [[ $PLAYER_LEVEL -lt $max_level && $PLAYER_XP -ge $PLAYER_XP_NEXT ]]; do
        player_level_up
    done
}

player_level_up() {
    (( PLAYER_LEVEL++ ))
    PLAYER_MAX_HP=${MAX_HP_TABLE[$PLAYER_LEVEL]}
    PLAYER_HP=$PLAYER_MAX_HP    # full heal on level up
    PLAYER_XP_NEXT=${XP_TABLE[$(( PLAYER_LEVEL + 1 ))]}
    (( PLAYER_ATTACK += 3 ))
    (( PLAYER_DEFENSE += 2 ))
    talent_grant_level_point

    ui_level_up "$PLAYER_LEVEL"
    printf "  %b Maks. PŻ: %d   Atak: %d   Obrona: %d%b\n" \
        "${BOLD_WHITE}" "$PLAYER_MAX_HP" "$PLAYER_ATTACK" "$PLAYER_DEFENSE" "${RESET}"
    printf "  %b Talenty -> %s%b\n" "${BOLD_WHITE}" "$(talent_summary_line)" "${RESET}"
    talent_choose_on_level_up
    press_enter
}

# ──────────────────────────────────────────────────────────────────────────────
# HP management
# ──────────────────────────────────────────────────────────────────────────────

player_heal() {
    local amount="$1"
    PLAYER_HP=$(( PLAYER_HP + amount ))
    [[ $PLAYER_HP -gt $PLAYER_MAX_HP ]] && PLAYER_HP=$PLAYER_MAX_HP
    printf "  %b❤  Uleczono %d PŻ  (PŻ: %d/%d)%b\n" "${COLOR_HP_HIGH}" "$amount" \
        "$PLAYER_HP" "$PLAYER_MAX_HP" "${RESET}"
}

player_damage() {
    local amount="$1"
    local effective=$(( amount - PLAYER_DEFENSE ))
    [[ $effective -lt 1 ]] && effective=1
    PLAYER_HP=$(( PLAYER_HP - effective ))
    [[ $PLAYER_HP -lt 0 ]] && PLAYER_HP=0
    printf "  %b💔 Otrzymałeś %d obrażeń  (PŻ: %d/%d)%b\n" "${COLOR_HP_LOW}" "$effective" \
        "$PLAYER_HP" "$PLAYER_MAX_HP" "${RESET}"
}

player_is_dead() {
    [[ $PLAYER_HP -le 0 ]]
}

# ──────────────────────────────────────────────────────────────────────────────
# Inventory
# ──────────────────────────────────────────────────────────────────────────────

player_add_item() {
    local item="$1"
    PLAYER_INVENTORY+=("$item")
    printf "  %b✦ Zdobyto: %s%b\n" "${COLOR_ITEM}" "$item" "${RESET}"
}

player_has_item() {
    local item="$1"
    local i
    for i in "${PLAYER_INVENTORY[@]}"; do
        [[ "$i" == "$item" ]] && return 0
    done
    return 1
}

player_remove_item() {
    local item="$1"
    local new_inv=()
    local removed=false
    local i
    for i in "${PLAYER_INVENTORY[@]}"; do
        if [[ "$i" == "$item" && "$removed" == "false" ]]; then
            removed=true
        else
            new_inv+=("$i")
        fi
    done
    PLAYER_INVENTORY=("${new_inv[@]}")
    [[ "$removed" == "true" ]]
}

player_use_item() {
    local item="$1"
    case "$item" in
        "Mikstura zdrowia")
            if player_has_item "Mikstura zdrowia"; then
                player_remove_item "Mikstura zdrowia"
                player_heal 50
                return 0
            else
                ui_error "Nie masz Mikstury zdrowia!"
                return 1
            fi
            ;;
        "Eliksir wiedzy"|"Mikstura wiedzy")
            local knowledge_item="${item}"
            if player_has_item "$knowledge_item"; then
                player_remove_item "$knowledge_item"
                TALENT_KNOWLEDGE_HINTS=$(( TALENT_KNOWLEDGE_HINTS + 2 ))
                printf "  %b🧠 Twoja wiedza rośnie (+2 podpowiedzi, razem: %d).%b\n" \
                    "${COLOR_ITEM}" "$TALENT_KNOWLEDGE_HINTS" "${RESET}"
                return 0
            else
                ui_error "Nie masz przedmiotu: ${knowledge_item}!"
                return 1
            fi
            ;;
        "Mikstura many")
            if player_has_item "Mikstura many"; then
                player_remove_item "Mikstura many"
                TALENT_KNOWLEDGE_HINTS=$(( TALENT_KNOWLEDGE_HINTS + 1 ))
                printf "  %b🔹 Odzyskujesz manę wiedzy (+1 podpowiedź, razem: %d).%b\n" \
                    "${COLOR_HINT}" "$TALENT_KNOWLEDGE_HINTS" "${RESET}"
                return 0
            else
                ui_error "Nie masz Mikstury many!"
                return 1
            fi
            ;;
        "Runa tarczy")
            if player_has_item "Runa tarczy"; then
                player_remove_item "Runa tarczy"
                # Dodajemy warstwę tarczy, która pochłania obrażenia przed pancerzem.
                PLAYER_SHIELD_VALUE=$(( PLAYER_SHIELD_VALUE + 25 ))
                printf "  %b🛡 Aktywujesz Runę tarczy (+25 tarczy, łącznie: %d).%b\n" \
                    "${BOLD_CYAN}" "$PLAYER_SHIELD_VALUE" "${RESET}"
                return 0
            else
                ui_error "Nie masz Runy tarczy!"
                return 1
            fi
            ;;
        "Bombka krwawienia")
            if player_has_item "Bombka krwawienia"; then
                player_remove_item "Bombka krwawienia"
                # Nakładamy efekt krwawienia na przeciwnika na kolejne tury.
                ENEMY_STATUS_BLEED_TURNS=3
                ENEMY_STATUS_BLEED_DAMAGE=8
                printf "  %b☠ Rzucasz Bombkę krwawienia! Wróg krwawi przez 3 tury.%b\n" \
                    "${COLOR_WARNING}" "${RESET}"
                return 0
            else
                ui_error "Nie masz Bombki krwawienia!"
                return 1
            fi
            ;;
        "Tarcza tymczasowa")
            if player_has_item "Tarcza tymczasowa"; then
                player_remove_item "Tarcza tymczasowa"
                # Zapewniamy większą osłonę na wymagające starcia.
                PLAYER_SHIELD_VALUE=$(( PLAYER_SHIELD_VALUE + 40 ))
                printf "  %b🛡 Aktywujesz Tarczę tymczasową (+40, łącznie: %d).%b\n" \
                    "${BOLD_CYAN}" "$PLAYER_SHIELD_VALUE" "${RESET}"
                return 0
            else
                ui_error "Nie masz Tarczy tymczasowej!"
                return 1
            fi
            ;;
        "Reset efektów negatywnych"|"Oczyszczenie")
            local cleanse_item="$item"
            if player_has_item "$cleanse_item"; then
                player_remove_item "$cleanse_item"
                # Czyścimy negatywne efekty gracza bez naruszania pozytywnych buffów.
                PLAYER_STATUS_STUN_TURNS=0
                PLAYER_STATUS_BLEED_TURNS=0
                PLAYER_STATUS_BLEED_DAMAGE=0
                printf "  %b✨ Oczyszczenie usuwa negatywne efekty statusu.%b\n" \
                    "${COLOR_SUCCESS}" "${RESET}"
                return 0
            else
                ui_error "Nie masz przedmiotu: ${cleanse_item}!"
                return 1
            fi
            ;;
        *)
            ui_error "Nieznany przedmiot: $item"
            return 1
            ;;
    esac
}

player_show_inventory() {
    echo
    printf "  %b=== Ekwipunek ===%b\n" "${BOLD_WHITE}" "${RESET}"
    if [[ ${#PLAYER_INVENTORY[@]} -eq 0 ]]; then
        printf "  %bPusty%b\n" "${DIM}" "${RESET}"
    else
        local counts=()
        local seen=()
        local item
        for item in "${PLAYER_INVENTORY[@]}"; do
            local found=false
            local j
            for j in "${!seen[@]}"; do
                if [[ "${seen[$j]}" == "$item" ]]; then
                    (( counts[$j]++ ))
                    found=true
                    break
                fi
            done
            if [[ "$found" == "false" ]]; then
                seen+=("$item")
                counts+=(1)
            fi
        done
        for j in "${!seen[@]}"; do
            printf "  %b%-25s%b x%d\n" "${COLOR_ITEM}" "${seen[$j]}" "${RESET}" "${counts[$j]}"
        done
    fi
    printf "  %bZłoto: %d%b\n" "${COLOR_GOLD}" "$PLAYER_GOLD" "${RESET}"
    echo
}

# ──────────────────────────────────────────────────────────────────────────────
# Display full stats
# ──────────────────────────────────────────────────────────────────────────────

player_show_stats() {
    echo
    ui_hr "─"
    printf "  %b%-12s%b %s\n" "${BOLD_WHITE}" "Imię:"    "${RESET}" "$PLAYER_NAME"
    printf "  %b%-12s%b %d\n" "${BOLD_WHITE}" "Poziom:"  "${RESET}" "$PLAYER_LEVEL"
    printf "  %b%-12s%b %d / %d\n" "${BOLD_WHITE}" "PŻ:"     "${RESET}" "$PLAYER_HP" "$PLAYER_MAX_HP"
    printf "  %b%-12s%b %d / %d\n" "${BOLD_WHITE}" "PD:"     "${RESET}" "$PLAYER_XP" "$PLAYER_XP_NEXT"
    printf "  %b%-12s%b %d\n" "${BOLD_WHITE}" "Atak:"    "${RESET}" "$PLAYER_ATTACK"
    printf "  %b%-12s%b %d\n" "${BOLD_WHITE}" "Obrona:"  "${RESET}" "$PLAYER_DEFENSE"
    printf "  %b%-12s%b %d\n" "${BOLD_WHITE}" "Złoto:"   "${RESET}" "$PLAYER_GOLD"
    printf "  %b%-12s%b %d\n" "${BOLD_WHITE}" "Obszar:"  "${RESET}" "$CURRENT_LEVEL"
    printf "  %b%-12s%b %d\n" "${BOLD_WHITE}" "Pkt. talent:" "${RESET}" "$PLAYER_TALENT_POINTS"
    printf "  %b%-12s%b O:%d D:%d W:%d\n" "${BOLD_WHITE}" "Talenty:" "${RESET}" \
        "$TALENT_OFFENSE_LEVEL" "$TALENT_DEFENSE_LEVEL" "$TALENT_KNOWLEDGE_LEVEL"
    printf "  %b%-12s%b %d\n" "${BOLD_WHITE}" "Podpowiedzi:" "${RESET}" "$TALENT_KNOWLEDGE_HINTS"
    ui_hr "─"
    player_show_inventory
}
