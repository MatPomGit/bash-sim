#!/usr/bin/env bash
# bash_rpg.sh – Main entry point for Bash RPG: The Terminal Chronicles
# Run: bash bash_rpg.sh

set -euo pipefail

GAME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all libraries
source "${GAME_DIR}/lib/colors.sh"
source "${GAME_DIR}/lib/ui.sh"
source "${GAME_DIR}/lib/player.sh"
source "${GAME_DIR}/lib/challenges.sh"
source "${GAME_DIR}/lib/combat.sh"
source "${GAME_DIR}/lib/save_load.sh"
source "${GAME_DIR}/lib/shop.sh"

# Source all levels
source "${GAME_DIR}/levels/level_01.sh"
source "${GAME_DIR}/levels/level_02.sh"
source "${GAME_DIR}/levels/level_03.sh"
source "${GAME_DIR}/levels/level_04.sh"
source "${GAME_DIR}/levels/level_05.sh"
source "${GAME_DIR}/levels/level_06.sh"

# ──────────────────────────────────────────────────────────────────────────────
# New game
# ──────────────────────────────────────────────────────────────────────────────

new_game() {
    ui_clear
    ui_header "Nowa gra"
    ui_story "Witaj, dzielny poszukiwaczu przygód!"
    ui_story "Kraina Bash woła bohatera, który opanuje tajniki terminala."
    echo
    ui_prompt "Podaj imię swojego bohatera: "
    local name
    read -r name
    [[ -z "$name" ]] && name="Bohater"
    player_create "$name"
    echo
    printf "  %bWitaj, %s!%b Twoja przygoda zaczyna się teraz.\n\n" "${COLOR_SUCCESS}" "$name" "${RESET}"
    sleep 1

    # Prolog
    ui_clear
    ui_header "Prolog"
    ui_story "Dawno temu Królestwo Terminala rozkwitało pod rządami Mistrza Bourne'a."
    ui_story "Pięć filarów krainy – Nawigacja, Pliki, Tekst, Potoki i Skrypty –"
    ui_story "utrzymywało porządek i dobrobyt w całej krainie."
    echo
    ui_story "Lecz wielka ciemność nadeszła. Stwory chaosu i zamętu"
    ui_story "opanowały ziemię, niszcząc katalogi, mieszając pliki i zrywając"
    ui_story "potoki wszędzie, gdzie okiem sięgnąć."
    echo
    ui_story "Jesteś Wybrańcem – przeznaczonym do opanowania starożytnej sztuki Bash"
    ui_story "i przywrócenia harmonii królestwu terminala."
    echo
    ui_story "Twoja podróż zaczyna się na skraju Zaczarowanego Lasu..."
    echo
    press_enter

    start_adventure
}

# ──────────────────────────────────────────────────────────────────────────────
# Continue game
# ──────────────────────────────────────────────────────────────────────────────

continue_game() {
    if load_game; then
        printf "\n  %bWitaj ponownie, %s! (Poziom %d)%b\n\n" \
            "${COLOR_SUCCESS}" "$PLAYER_NAME" "$PLAYER_LEVEL" "${RESET}"
        sleep 1
        start_adventure
    else
        ui_error "Nie znaleziono pliku zapisu."
        press_enter
    fi
}

# ──────────────────────────────────────────────────────────────────────────────
# Main adventure loop – routes player to the correct level
# ──────────────────────────────────────────────────────────────────────────────

start_adventure() {
    while true; do
        if player_is_dead; then
            game_over_menu
            return
        fi

        case "$CURRENT_LEVEL" in
            1) run_level_01 ;;
            2) run_level_02 ;;
            3) run_level_03 ;;
            4) run_level_04 ;;
            5) run_level_05 ;;
            6) run_level_06 ;;
            7|*)
                # Gra ukończona
                game_complete
                return
                ;;
        esac

        # Between levels: check player status
        if player_is_dead; then
            game_over_menu
            return
        fi

        ui_player_status
        shop_level_checkpoint
        press_enter
    done
}

# ──────────────────────────────────────────────────────────────────────────────
# Menus
# ──────────────────────────────────────────────────────────────────────────────

main_menu() {
    while true; do
        ui_title_screen
        local options=("Nowa gra" "Kontynuuj" "Jak grać" "Wyjdź")
        if has_save; then
            options[1]="Kontynuuj  [znaleziono zapis]"
        fi

        ui_menu "Menu główne" "${options[@]}"
        ui_prompt "Wybór: "
        local choice
        read -r choice

        case "$choice" in
            1) new_game; return ;;
            2) continue_game ;;
            3) show_help ;;
            4|q|Q|quit|exit) farewell; exit 0 ;;
            *) ui_error "Podaj cyfrę 1-4." ;;
        esac
    done
}

game_over_menu() {
    ui_clear
    ui_hr "═"
    ui_center "${COLOR_ERROR}  Koniec gry  ${RESET}"
    ui_hr "═"
    echo
    ui_story "Poległeś w boju..."
    ui_story "Ale każda porażka to lekcja. Powstań i opanuj terminal!"
    echo

    ui_menu "Co zamierzasz zrobić?" "Wczytaj zapis" "Nowa gra" "Wróć do menu głównego"
    ui_prompt "Wybór: "
    local choice
    read -r choice

    case "$choice" in
        1)
            if load_game; then
                PLAYER_HP=$(( PLAYER_MAX_HP / 2 ))  # startuj z połową PŻ po wskrzeszeniu
                start_adventure
            else
                new_game
            fi
            ;;
        2) new_game ;;
        3|*) main_menu ;;
    esac
}

game_complete() {
    ui_clear
    ui_hr "═"
    ui_center "${BOLD_YELLOW}  ★  Wojownik Bash  ★  ${RESET}"
    ui_center "${BOLD_WHITE}  Kroniki Terminala  ${RESET}"
    ui_hr "═"
    echo
    ui_story "Ukończyłeś wszystkie sześć rozdziałów Bash RPG!"
    ui_story ""
    ui_story "Pokonując strażników Nawigacji, Plików, Tekstu, Potoków, Skryptów"
    ui_story "i Procesów, przywróciłeś pokój Królestwu Terminala."
    echo
    player_show_stats
    echo
    ui_story "Umiejętności zdobyte w tej podróży to PRAWDZIWE polecenia Bash."
    ui_story "Wypróbuj je w swoim terminalu i poczuj moc, którą teraz dzierżysz!"
    echo
    press_enter
    main_menu
}

show_help() {
    ui_clear
    ui_header "Jak grać"
    ui_story "Bash RPG to edukacyjna gra RPG, która uczy poleceń terminala Bash."
    echo
    printf "  %bWalka%b\n" "${BOLD_WHITE}" "${RESET}"
    printf "  Podczas bitwy odpowiadasz na pytania o polecenia Bash, by atakować wrogów.\n"
    printf "  Poprawne odpowiedzi zadają obrażenia; błędne oznaczają utratę kolejki.\n"
    printf "  Wróg atakuje w każdej kolejce bez względu na wynik.\n"
    echo
    printf "  %bNauczane polecenia%b\n" "${BOLD_WHITE}" "${RESET}"
    printf "  Rozdział 1 – Nawigacja : ls, pwd, cd, mkdir, rmdir\n"
    printf "  Rozdział 2 – Pliki     : touch, cat, cp, mv, rm, ln, file\n"
    printf "  Rozdział 3 – Tekst     : grep, find, head, tail, wc, sort, uniq, cut\n"
    printf "  Rozdział 4 – Potoki    : |  >  >>  <  2>  tee  xargs\n"
    printf "  Rozdział 5 – Skrypty   : zmienne, if, for, while, funkcje\n"
    printf "  Rozdział 6 – Procesy   : ps, kill, top, bg, fg, jobs, nohup, pgrep\n"
    echo
    printf "  %bPrzedmioty%b\n" "${BOLD_WHITE}" "${RESET}"
    printf "  Mikstura zdrowia    – przywraca 50 PŻ\n"
    printf "  Mikstura many       – odnawia 1 ładunek podpowiedzi (talent Wiedza)\n"
    printf "  Mikstura wiedzy     – odnawia 2 ładunki podpowiedzi\n"
    printf "  Tarcza tymczasowa   – dodaje 40 pkt. tarczy pochłaniającej obrażenia\n"
    printf "  Oczyszczenie        – usuwa negatywne efekty (ogłuszenie/krwawienie)\n"
    echo
    printf "  %bSklep po rozdziale%b\n" "${BOLD_WHITE}" "${RESET}"
    printf "  Po ukończeniu poziomu możesz wejść do sklepu i kupić przedmioty za złoto.\n"
    printf "  Ceny rosną wraz z poziomem obszaru, aby utrzymać balans rozgrywki.\n"
    echo
    printf "  %bTalenty (od poziomu 2)%b\n" "${BOLD_WHITE}" "${RESET}"
    printf "  Za każdy awans dostajesz 1 punkt talentu do rozdania.\n"
    printf "  Ofensywa            – +5%% szansy na trafienie krytyczne za poziom talentu.\n"
    printf "  Obrona              – stała redukcja obrażeń od wroga o 1 za poziom talentu.\n"
    printf "  Wiedza              – szansa uratowania błędnej odpowiedzi i ładunki podpowiedzi.\n"
    echo
    printf "  %bWskazówki%b\n" "${BOLD_WHITE}" "${RESET}"
    printf "  • Wpisz tylko nazwę polecenia (np. 'ls') lub pełną odpowiedź.\n"
    printf "  • Odpowiedzi nie rozróżniają wielkich i małych liter.\n"
    printf "  • Czytaj wyjaśnienia po walkach – są edukacyjne!\n"
    printf "  • Gra zapisuje się automatycznie po każdym rozdziale.\n"
    echo
    press_enter
}

farewell() {
    ui_clear
    echo
    ui_center "${BOLD_CYAN}Dziękujemy za grę w Bash RPG: Kroniki Terminala!${RESET}"
    echo
    ui_center "${DIM}Pamiętaj: prawdziwym skarbem były polecenia Bash, których się nauczyłeś.${RESET}"
    echo
}

# ──────────────────────────────────────────────────────────────────────────────
# Entry point
# ──────────────────────────────────────────────────────────────────────────────

# Verify bash version >= 4 (needed for nameref / associative arrays)
if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
    echo "Błąd: Do gry w Bash RPG wymagany jest Bash 4.0 lub nowszy." >&2
    echo "Twoja wersja: ${BASH_VERSION}" >&2
    exit 1
fi

ui_resize_half_screen
ui_startup_animation
main_menu
