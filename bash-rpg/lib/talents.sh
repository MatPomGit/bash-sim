#!/usr/bin/env bash
# lib/talents.sh – System talentów postaci

# shellcheck source=lib/ui.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/colors.sh"
source "${SCRIPT_DIR}/ui.sh"

# Maksymalny poziom pojedynczej ścieżki talentów.
TALENT_MAX_LEVEL=3

# Nazwy ścieżek talentów prezentowane w interfejsie.
TALENT_PATH_OFFENSE="Ofensywa"
TALENT_PATH_DEFENSE="Obrona"
TALENT_PATH_KNOWLEDGE="Wiedza"

# Zeruje progres talentów dla nowej gry.
talents_reset() {
    PLAYER_TALENT_POINTS=0
    TALENT_OFFENSE_LEVEL=0
    TALENT_DEFENSE_LEVEL=0
    TALENT_KNOWLEDGE_LEVEL=0
    TALENT_KNOWLEDGE_HINTS=0
}

# Przyznaje punkt talentu po awansie poziomu.
talent_grant_level_point() {
    (( PLAYER_TALENT_POINTS++ ))
    printf "  %b✦ Zdobywasz 1 punkt talentu! (Dostępne: %d)%b\n" \
        "${BOLD_CYAN}" "$PLAYER_TALENT_POINTS" "${RESET}"
}

# Zwraca redukcję obrażeń wynikającą z talentu obrony.
talent_defense_reduction() {
    printf "%d" "$TALENT_DEFENSE_LEVEL"
}

# Wylicza i wypisuje końcowe obrażenia gracza po uwzględnieniu talentów ofensywnych.
# Format: "damage|was_critical"
talent_apply_offense_bonus() {
    local base_damage="$1"
    local damage="$base_damage"
    local crit=false

    # Każdy poziom ofensywy daje +5%% na trafienie krytyczne.
    local crit_roll=$(( RANDOM % 100 ))
    local crit_chance=$(( TALENT_OFFENSE_LEVEL * 5 ))
    if [[ $crit_roll -lt $crit_chance ]]; then
        crit=true
        # Krytyk skaluje się wraz z poziomem talentu (1.5x, 1.7x, 2.0x).
        local mult_num=15
        local mult_den=10
        if [[ $TALENT_OFFENSE_LEVEL -eq 2 ]]; then
            mult_num=17
        elif [[ $TALENT_OFFENSE_LEVEL -ge 3 ]]; then
            mult_num=20
        fi
        damage=$(( damage * mult_num / mult_den ))
    fi

    printf "%s|%s" "$damage" "$crit"
}

# Daje szansę na uratowanie błędnej odpowiedzi dzięki talentowi wiedzy.
# Zwraca 0, jeżeli bonus zadziałał, w przeciwnym razie 1.
talent_knowledge_salvage() {
    [[ $TALENT_KNOWLEDGE_LEVEL -le 0 ]] && return 1
    local roll=$(( RANDOM % 100 ))
    local chance=$(( TALENT_KNOWLEDGE_LEVEL * 10 ))
    [[ $roll -lt $chance ]]
}

# Wyświetla krótką podpowiedź do pytania, jeżeli gracz ma ładunki wiedzy.
talent_knowledge_try_hint() {
    local primary_answer="$1"
    [[ $TALENT_KNOWLEDGE_HINTS -le 0 ]] && return 1

    if [[ "${BASH_RPG_TESTING:-}" == "1" ]]; then
        return 1
    fi

    ui_prompt "Użyć podpowiedzi wiedzy? [t/N]: "
    local decision
    read -r decision
    case "$decision" in
        t|T|tak|TAK|y|Y)
            (( TALENT_KNOWLEDGE_HINTS-- ))
            local first_char="${primary_answer:0:1}"
            local answer_len="${#primary_answer}"
            printf "  %b💡 Podpowiedź:%b odpowiedź zaczyna się od '%s' i ma %d znaków.\n" \
                "${COLOR_HINT}" "${RESET}" "$first_char" "$answer_len"
            return 0
            ;;
    esac
    return 1
}

# Dodaje bonusowe ładunki podpowiedzi po rozwinięciu talentu wiedzy.
talent_grant_knowledge_hint() {
    (( TALENT_KNOWLEDGE_HINTS++ ))
    printf "  %b🧠 Otrzymujesz 1 ładunek podpowiedzi wiedzy (łącznie: %d).%b\n" \
        "${COLOR_HINT}" "$TALENT_KNOWLEDGE_HINTS" "${RESET}"
}

# Próbuje ulepszyć wskazaną ścieżkę talentów. Zwraca 0 przy sukcesie.
talent_upgrade_path() {
    local path="$1"

    if [[ $PLAYER_TALENT_POINTS -le 0 ]]; then
        ui_warning "Brak dostępnych punktów talentu."
        return 1
    fi

    case "$path" in
        offense)
            if [[ $TALENT_OFFENSE_LEVEL -ge $TALENT_MAX_LEVEL ]]; then
                ui_warning "Ścieżka ${TALENT_PATH_OFFENSE} ma już maksymalny poziom."
                return 1
            fi
            (( TALENT_OFFENSE_LEVEL++ ))
            (( PLAYER_TALENT_POINTS-- ))
            printf "  %b⚔ %s -> poziom %d%b\n" \
                "${BOLD_RED}" "$TALENT_PATH_OFFENSE" "$TALENT_OFFENSE_LEVEL" "${RESET}"
            ;;
        defense)
            if [[ $TALENT_DEFENSE_LEVEL -ge $TALENT_MAX_LEVEL ]]; then
                ui_warning "Ścieżka ${TALENT_PATH_DEFENSE} ma już maksymalny poziom."
                return 1
            fi
            (( TALENT_DEFENSE_LEVEL++ ))
            (( PLAYER_TALENT_POINTS-- ))
            printf "  %b🛡 %s -> poziom %d%b\n" \
                "${BOLD_CYAN}" "$TALENT_PATH_DEFENSE" "$TALENT_DEFENSE_LEVEL" "${RESET}"
            ;;
        knowledge)
            if [[ $TALENT_KNOWLEDGE_LEVEL -ge $TALENT_MAX_LEVEL ]]; then
                ui_warning "Ścieżka ${TALENT_PATH_KNOWLEDGE} ma już maksymalny poziom."
                return 1
            fi
            (( TALENT_KNOWLEDGE_LEVEL++ ))
            (( PLAYER_TALENT_POINTS-- ))
            printf "  %b📚 %s -> poziom %d%b\n" \
                "${BOLD_YELLOW}" "$TALENT_PATH_KNOWLEDGE" "$TALENT_KNOWLEDGE_LEVEL" "${RESET}"
            talent_grant_knowledge_hint
            ;;
        *)
            ui_error "Nieznana ścieżka talentu: $path"
            return 1
            ;;
    esac

    return 0
}

# Automatycznie wydaje punkty w testach, aby uniknąć interakcji.
talent_auto_spend_for_tests() {
    while [[ $PLAYER_TALENT_POINTS -gt 0 ]]; do
        talent_upgrade_path "offense" >/dev/null || break
    done
}

# Interaktywne menu rozdawania punktów talentów po awansie.
talent_choose_on_level_up() {
    [[ $PLAYER_TALENT_POINTS -le 0 ]] && return 0

    if [[ "${BASH_RPG_TESTING:-}" == "1" ]]; then
        talent_auto_spend_for_tests
        return 0
    fi

    while [[ $PLAYER_TALENT_POINTS -gt 0 ]]; do
        echo
        ui_hr "─"
        printf "  %bTalenty – dostępne punkty: %d%b\n" "${BOLD_WHITE}" "$PLAYER_TALENT_POINTS" "${RESET}"
        printf "  %b[1]%b %s (poz. %d/%d): +5%% szansy na krytyk / poziom\n" \
            "${BOLD_CYAN}" "${RESET}" "$TALENT_PATH_OFFENSE" "$TALENT_OFFENSE_LEVEL" "$TALENT_MAX_LEVEL"
        printf "  %b[2]%b %s (poz. %d/%d): stała redukcja obrażeń +1 / poziom\n" \
            "${BOLD_CYAN}" "${RESET}" "$TALENT_PATH_DEFENSE" "$TALENT_DEFENSE_LEVEL" "$TALENT_MAX_LEVEL"
        printf "  %b[3]%b %s (poz. %d/%d): +10%% szansy na ratunek odpowiedzi i 1 podpowiedź / poziom\n" \
            "${BOLD_CYAN}" "${RESET}" "$TALENT_PATH_KNOWLEDGE" "$TALENT_KNOWLEDGE_LEVEL" "$TALENT_MAX_LEVEL"
        printf "  %b[4]%b Zakończ rozdawanie na później\n" "${BOLD_CYAN}" "${RESET}"
        ui_prompt "Wybierz ścieżkę talentu: "

        local choice
        read -r choice
        case "$choice" in
            1) talent_upgrade_path "offense" ;;
            2) talent_upgrade_path "defense" ;;
            3) talent_upgrade_path "knowledge" ;;
            4) break ;;
            *) ui_error "Podaj cyfrę 1-4." ;;
        esac
    done
}

# Buduje krótkie podsumowanie talentów do ekranów statystyk.
talent_summary_line() {
    printf "TP:%d  Ofensywa:%d  Obrona:%d  Wiedza:%d  Podpowiedzi:%d" \
        "$PLAYER_TALENT_POINTS" "$TALENT_OFFENSE_LEVEL" "$TALENT_DEFENSE_LEVEL" \
        "$TALENT_KNOWLEDGE_LEVEL" "$TALENT_KNOWLEDGE_HINTS"
}
