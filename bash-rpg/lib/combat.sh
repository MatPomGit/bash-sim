#!/usr/bin/env bash
# lib/combat.sh – Turn-based combat engine

# shellcheck source=lib/ui.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/colors.sh"
source "${SCRIPT_DIR}/ui.sh"
source "${SCRIPT_DIR}/player.sh"
source "${SCRIPT_DIR}/challenges.sh"

# ──────────────────────────────────────────────────────────────────────────────
# Enemy definition helpers
# ──────────────────────────────────────────────────────────────────────────────

# Global enemy state set before combat_start
ENEMY_NAME=""
ENEMY_HP=0
ENEMY_MAX_HP=0
ENEMY_ATTACK=0
ENEMY_CATEGORY=""
ENEMY_DESCRIPTION=""
ENEMY_VICTORY_MSG=""
ENEMY_XP_REWARD=0
ENEMY_GOLD_REWARD=0
ENEMY_ITEM_REWARD=""   # empty = no item

# Stan efektów walki (resetowany na początku każdej walki)
PLAYER_STATUS_STUN_TURNS=0
PLAYER_STATUS_BLEED_TURNS=0
PLAYER_STATUS_BLEED_DAMAGE=0
PLAYER_SHIELD_VALUE=0
ENEMY_STATUS_STUN_TURNS=0
ENEMY_STATUS_BLEED_TURNS=0
ENEMY_STATUS_BLEED_DAMAGE=0
ENEMY_SHIELD_VALUE=0

# Define an enemy (call before combat_start)
enemy_set() {
    ENEMY_NAME="$1"
    ENEMY_MAX_HP="$2"
    ENEMY_HP="$2"
    ENEMY_ATTACK="$3"
    ENEMY_CATEGORY="$4"      # challenge category
    ENEMY_DESCRIPTION="$5"
    ENEMY_VICTORY_MSG="$6"
    ENEMY_XP_REWARD="$7"
    ENEMY_GOLD_REWARD="$8"
    ENEMY_ITEM_REWARD="${9:-}"
}

# Resetuje wszystkie statusy i tarcze przed nową walką.
combat_reset_status_effects() {
    PLAYER_STATUS_STUN_TURNS=0
    PLAYER_STATUS_BLEED_TURNS=0
    PLAYER_STATUS_BLEED_DAMAGE=0
    PLAYER_SHIELD_VALUE=0
    ENEMY_STATUS_STUN_TURNS=0
    ENEMY_STATUS_BLEED_TURNS=0
    ENEMY_STATUS_BLEED_DAMAGE=0
    ENEMY_SHIELD_VALUE=0
}

# Faza startu tury dla celu: redukcja liczników, tick bleed i sprawdzenie ogłuszenia.
# Argumenty:
#   1) "player" lub "enemy"
# Zwraca:
#   0 -> może wykonać akcję, 1 -> pomija akcję (stun)
combat_start_turn_phase() {
    local target="$1"

    if [[ "$target" == "player" ]]; then
        # Redukujemy licznik i nakładamy obrażenia okresowe krwawienia.
        if [[ $PLAYER_STATUS_BLEED_TURNS -gt 0 ]]; then
            (( PLAYER_STATUS_BLEED_TURNS-- ))
            local bleed_dmg="$PLAYER_STATUS_BLEED_DAMAGE"
            printf "  %b☠ Krwawienie zadaje ci %d obrażeń (pozostało tur: %d).%b\n" \
                "${COLOR_WARNING}" "$bleed_dmg" "$PLAYER_STATUS_BLEED_TURNS" "${RESET}"
            player_damage "$bleed_dmg"
        fi

        # Redukujemy licznik i oznaczamy pominięcie akcji przy ogłuszeniu.
        if [[ $PLAYER_STATUS_STUN_TURNS -gt 0 ]]; then
            (( PLAYER_STATUS_STUN_TURNS-- ))
            ui_warning "Jesteś ogłuszony! Pomijasz akcję (pozostało tur: ${PLAYER_STATUS_STUN_TURNS})."
            return 1
        fi
    else
        # Redukujemy licznik i nakładamy obrażenia okresowe krwawienia.
        if [[ $ENEMY_STATUS_BLEED_TURNS -gt 0 ]]; then
            (( ENEMY_STATUS_BLEED_TURNS-- ))
            local bleed_dmg="$ENEMY_STATUS_BLEED_DAMAGE"
            ENEMY_HP=$(( ENEMY_HP - bleed_dmg ))
            [[ $ENEMY_HP -lt 0 ]] && ENEMY_HP=0
            printf "  %b☠ %s krwawi i otrzymuje %d obrażeń (pozostało tur: %d).%b\n" \
                "${COLOR_WARNING}" "$ENEMY_NAME" "$bleed_dmg" "$ENEMY_STATUS_BLEED_TURNS" "${RESET}"
        fi

        # Redukujemy licznik i oznaczamy pominięcie akcji przy ogłuszeniu.
        if [[ $ENEMY_STATUS_STUN_TURNS -gt 0 ]]; then
            (( ENEMY_STATUS_STUN_TURNS-- ))
            ui_warning "${ENEMY_NAME} jest ogłuszony i pomija akcję (pozostało tur: ${ENEMY_STATUS_STUN_TURNS})."
            return 1
        fi
    fi

    return 0
}

# Wykonuje pełną turę przeciwnika: faza startu tury + atak (jeśli nie jest ogłuszony).
combat_enemy_turn() {
    combat_start_turn_phase "enemy"
    local can_act=$?
    if [[ $ENEMY_HP -le 0 ]]; then
        return 2
    fi
    if [[ $can_act -ne 0 ]]; then
        return 1
    fi

    combat_enemy_attack
    return 0
}

# ──────────────────────────────────────────────────────────────────────────────
# Combat loop
# ──────────────────────────────────────────────────────────────────────────────

# Returns 0 if player wins, 1 if player dies/flees
combat_start() {
    local used_challenges=""
    local turn=1
    local fled=false

    combat_reset_status_effects

    ui_clear
    ui_combat_banner "$ENEMY_NAME"
    echo
    printf "  %b%s%b\n" "${COLOR_STORY}" "$ENEMY_DESCRIPTION" "${RESET}"
    echo
    press_enter

    ui_combat_start_animation "$ENEMY_NAME"

    while true; do
        # Draw status
        ui_clear
        ui_combat_banner "$ENEMY_NAME"
        ui_player_status
        echo
        ui_enemy_status "$ENEMY_NAME" "$ENEMY_HP" "$ENEMY_MAX_HP"
        ui_combat_effects "Gracz" "$PLAYER_STATUS_STUN_TURNS" "$PLAYER_STATUS_BLEED_TURNS" \
            "$PLAYER_STATUS_BLEED_DAMAGE" "$PLAYER_SHIELD_VALUE"
        ui_combat_effects "$ENEMY_NAME" "$ENEMY_STATUS_STUN_TURNS" "$ENEMY_STATUS_BLEED_TURNS" \
            "$ENEMY_STATUS_BLEED_DAMAGE" "$ENEMY_SHIELD_VALUE"
        echo
        ui_hr "─"
        printf "  %bKolejka %d%b\n" "${DIM}" "$turn" "${RESET}"
        ui_hr "─"

        # Faza startu tury gracza: liczniki, tick bleed i ewentualne ogłuszenie.
        if ! combat_start_turn_phase "player"; then
            if player_is_dead; then
                combat_defeat
                return 1
            fi

            # Gdy gracz jest ogłuszony, przechodzi od razu tura przeciwnika.
            combat_enemy_turn
            local enemy_turn_result=$?
            if [[ $enemy_turn_result -eq 2 ]]; then
                combat_victory
                return 0
            fi
            if player_is_dead; then
                combat_defeat
                return 1
            fi
            (( turn++ ))
            continue
        fi

        if player_is_dead; then
            combat_defeat
            return 1
        fi

        # Combat menu
        echo
        printf "  %b[1]%b Atakuj (odpowiedz na pytanie Bash)\n" "${BOLD_CYAN}" "${RESET}"
        printf "  %b[2]%b Użyj przedmiotu\n" "${BOLD_CYAN}" "${RESET}"
        printf "  %b[3]%b Pokaż ekwipunek\n" "${BOLD_CYAN}" "${RESET}"
        printf "  %b[4]%b Uciekaj (stracisz 20 PŻ)\n" "${BOLD_CYAN}" "${RESET}"
        echo
        ui_prompt "Twój wybór: "
        local choice
        read -r choice

        case "$choice" in
            1)
                combat_player_attack "$used_challenges"
                local attack_result=$?
                # attack_result: 0=correct, 1=wrong, used CHALLENGE_IDX already updated
                used_challenges="$used_challenges $CHALLENGE_IDX"

                if [[ $attack_result -eq 0 ]]; then
                    # Player dealt damage
                    if [[ $ENEMY_HP -le 0 ]]; then
                        combat_victory
                        return 0
                    fi
                fi

                # Enemy counter-attacks
                combat_enemy_turn
                local enemy_turn_result=$?
                if [[ $enemy_turn_result -eq 2 ]]; then
                    combat_victory
                    return 0
                fi
                ;;
            2)
                combat_use_item
                # Enemy still attacks after item use
                combat_enemy_turn
                local enemy_turn_result=$?
                if [[ $enemy_turn_result -eq 2 ]]; then
                    combat_victory
                    return 0
                fi
                ;;
            3)
                player_show_inventory
                press_enter
                continue
                ;;
            4)
                printf "\n  %bUciekasz! Wróg zadaje ci pożegnalny cios...%b\n" "${COLOR_WARNING}" "${RESET}"
                player_damage $(( ENEMY_ATTACK * 2 ))
                fled=true
                ;;
            *)
                ui_error "Nieprawidłowy wybór."
                continue
                ;;
        esac

        # Check player death
        if player_is_dead; then
            combat_defeat
            return 1
        fi

        # Check flee
        if $fled; then
            return 1
        fi

        (( turn++ ))
    done
}

# ──────────────────────────────────────────────────────────────────────────────
# Attack: challenge-based
# ──────────────────────────────────────────────────────────────────────────────

combat_player_attack() {
    local used="$1"
    challenges_get_random "$ENEMY_CATEGORY" "$used"
    local primary_answer
    primary_answer="$(echo "$CHALLENGE_ANSWERS" | cut -d"${SEP}" -f1)"

    echo
    ui_hr "─"
    printf "  %b⚔  Wyzwanie:%b\n" "${BOLD_YELLOW}" "${RESET}"
    printf "  %b%s%b\n\n" "${BOLD_WHITE}" "$CHALLENGE_QUESTION" "${RESET}"
    talent_knowledge_try_hint "$primary_answer" >/dev/null
    ui_prompt "Twoja odpowiedź: "
    local answer
    read -r answer

    if challenges_check_answer "$answer" "$CHALLENGE_ANSWERS"; then
        local dmg=$(( PLAYER_ATTACK + RANDOM % 5 ))
        local offense_result
        offense_result="$(talent_apply_offense_bonus "$dmg")"
        local final_dmg="${offense_result%%|*}"
        local was_crit="${offense_result##*|}"
        dmg="$final_dmg"
        local absorbed=0
        if [[ $ENEMY_SHIELD_VALUE -gt 0 ]]; then
            absorbed=$(( dmg < ENEMY_SHIELD_VALUE ? dmg : ENEMY_SHIELD_VALUE ))
            ENEMY_SHIELD_VALUE=$(( ENEMY_SHIELD_VALUE - absorbed ))
            dmg=$(( dmg - absorbed ))
            printf "  %b🛡 Tarcza wroga pochłania %d obrażeń (pozostało: %d).%b\n" \
                "${BOLD_CYAN}" "$absorbed" "$ENEMY_SHIELD_VALUE" "${RESET}"
        fi

        ENEMY_HP=$(( ENEMY_HP - dmg ))
        [[ $ENEMY_HP -lt 0 ]] && ENEMY_HP=0
        printf "\n  %b✔ Poprawnie!%b  Zadajesz %b%d obrażeń%b!\n" \
            "${COLOR_SUCCESS}" "${RESET}" "${BOLD_RED}" "$dmg" "${RESET}"
        if [[ "$was_crit" == "true" ]]; then
            printf "  %b✦ Trafienie krytyczne dzięki talentowi ofensywy!%b\n" \
                "${BOLD_RED}" "${RESET}"
        fi
        printf "  %b%s%b\n" "${DIM}" "$CHALLENGE_EXPLAIN" "${RESET}"
        sleep 1
        return 0
    elif talent_knowledge_salvage; then
        local dmg=$(( PLAYER_ATTACK / 2 + RANDOM % 3 ))
        local offense_result
        offense_result="$(talent_apply_offense_bonus "$dmg")"
        local final_dmg="${offense_result%%|*}"
        local was_crit="${offense_result##*|}"
        dmg="$final_dmg"
        ENEMY_HP=$(( ENEMY_HP - dmg ))
        [[ $ENEMY_HP -lt 0 ]] && ENEMY_HP=0
        printf "\n  %b🧠 Talent wiedzy uratował odpowiedź!%b Zadajesz %b%d obrażeń%b.\n" \
            "${COLOR_HINT}" "${RESET}" "${BOLD_RED}" "$dmg" "${RESET}"
        if [[ "$was_crit" == "true" ]]; then
            printf "  %b✦ Dodatkowo aktywował się krytyk ofensywy!%b\n" \
                "${BOLD_RED}" "${RESET}"
        fi
        printf "  %bPoprawna odpowiedź to:%b %b%s%b\n" \
            "${DIM}" "${RESET}" "${COLOR_COMMAND}" "$primary_answer" "${RESET}"
        printf "  %b%s%b\n" "${DIM}" "$CHALLENGE_EXPLAIN" "${RESET}"
        sleep 1
        return 0
    else
        printf "\n  %b✘ Błąd!%b  Poprawna odpowiedź to: %b%s%b\n" \
            "${COLOR_ERROR}" "${RESET}" "${COLOR_COMMAND}" \
            "$primary_answer" "${RESET}"
        printf "  %b%s%b\n" "${DIM}" "$CHALLENGE_EXPLAIN" "${RESET}"
        printf "  %bTracisz kolejkę!%b\n" "${COLOR_WARNING}" "${RESET}"
        press_enter
        return 1
    fi
}

# ──────────────────────────────────────────────────────────────────────────────
# Enemy attacks player
# ──────────────────────────────────────────────────────────────────────────────

combat_enemy_attack() {
    local base_dmg=$(( ENEMY_ATTACK + RANDOM % 5 ))
    local mitigation
    mitigation="$(talent_defense_reduction)"
    local dmg=$(( base_dmg - mitigation ))
    [[ $dmg -lt 1 ]] && dmg=1
    local absorbed=0
    printf "\n  %b%s atakuje cię!%b\n" "${COLOR_ENEMY}" "$ENEMY_NAME" "${RESET}"
    if [[ "$mitigation" -gt 0 ]]; then
        printf "  %b🛡 Talent obrony redukuje obrażenia o %d.%b\n" \
            "${BOLD_CYAN}" "$mitigation" "${RESET}"
    fi

    if [[ $PLAYER_SHIELD_VALUE -gt 0 ]]; then
        absorbed=$(( dmg < PLAYER_SHIELD_VALUE ? dmg : PLAYER_SHIELD_VALUE ))
        PLAYER_SHIELD_VALUE=$(( PLAYER_SHIELD_VALUE - absorbed ))
        dmg=$(( dmg - absorbed ))
        printf "  %b🛡 Twoja tarcza pochłania %d obrażeń (pozostało: %d).%b\n" \
            "${BOLD_CYAN}" "$absorbed" "$PLAYER_SHIELD_VALUE" "${RESET}"
    fi

    if [[ $dmg -gt 0 ]]; then
        player_damage "$dmg"
    else
        printf "  %bAtak nie przebił się przez tarczę!%b\n" "${COLOR_SUCCESS}" "${RESET}"
    fi
    [[ "${BASH_RPG_TESTING:-}" == "1" ]] || sleep 0.5
}

# ──────────────────────────────────────────────────────────────────────────────
# Item use during combat
# ──────────────────────────────────────────────────────────────────────────────

combat_use_item() {
    if [[ ${#PLAYER_INVENTORY[@]} -eq 0 ]]; then
        ui_warning "Twój ekwipunek jest pusty!"
        return
    fi

    # Pokazujemy listę unikalnych nazw z numeracją,
    # aby bezpiecznie obsłużyć przedmioty o nazwach wielowyrazowych.
    local unique_items=()
    local item
    for item in "${PLAYER_INVENTORY[@]}"; do
        local exists=false
        local listed
        for listed in "${unique_items[@]}"; do
            if [[ "$listed" == "$item" ]]; then
                exists=true
                break
            fi
        done
        [[ "$exists" == "false" ]] && unique_items+=("$item")
    done

    echo
    printf "  %bUżyj przedmiotu:%b\n\n" "${BOLD_WHITE}" "${RESET}"
    local i
    for i in "${!unique_items[@]}"; do
        printf "  %b[%d]%b %s\n" "${BOLD_CYAN}" "$(( i + 1 ))" "${RESET}" "${unique_items[$i]}"
    done
    printf "  %b[Q]%b Powrót\n\n" "${BOLD_CYAN}" "${RESET}"

    ui_prompt "Wybierz numer przedmiotu: "
    local choice
    read -r choice

    case "${choice,,}" in
        q|powrot|powrót|exit)
            return
            ;;
    esac

    if [[ ! "$choice" =~ ^[0-9]+$ ]] || [[ "$choice" -lt 1 ]] || [[ "$choice" -gt "${#unique_items[@]}" ]]; then
        ui_error "Nieprawidłowy numer przedmiotu."
        return
    fi

    local item_name="${unique_items[$(( choice - 1 ))]}"
    player_use_item "$item_name"
}

# ──────────────────────────────────────────────────────────────────────────────
# Outcome screens
# ──────────────────────────────────────────────────────────────────────────────

combat_victory() {
    echo
    ui_hr "═"
    ui_center "${COLOR_SUCCESS}  ★  Zwycięstwo!  ★  ${RESET}"
    ui_hr "═"
    echo
    printf "  %b%s%b\n\n" "${COLOR_STORY}" "$ENEMY_VICTORY_MSG" "${RESET}"

    player_add_xp "$ENEMY_XP_REWARD"
    PLAYER_GOLD=$(( PLAYER_GOLD + ENEMY_GOLD_REWARD ))
    ui_gold_gain "$ENEMY_GOLD_REWARD"

    if [[ -n "$ENEMY_ITEM_REWARD" ]]; then
        player_add_item "$ENEMY_ITEM_REWARD"
    fi
    echo
    press_enter
}

combat_defeat() {
    echo
    ui_hr "═"
    ui_center "${COLOR_ERROR}  ✝  Poległeś  ✝  ${RESET}"
    ui_hr "═"
    echo
    printf "  %bTwoja przygoda kończy się tutaj... na razie.%b\n" "${COLOR_STORY}" "${RESET}"
    printf "  %bAle prawdziwy wojownik Bash nigdy się nie poddaje!%b\n\n" "${COLOR_STORY}" "${RESET}"
    press_enter
}
