#!/usr/bin/env bash
# levels/level_06.sh – Cytadela Procesów
# Uczy: ps, kill, top, bg, fg, jobs, nohup, pgrep

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/colors.sh"
source "${SCRIPT_DIR}/../lib/ui.sh"
source "${SCRIPT_DIR}/../lib/player.sh"
source "${SCRIPT_DIR}/../lib/combat.sh"
source "${SCRIPT_DIR}/../lib/save_load.sh"

level_06_intro() {
    ui_clear
    ui_header "Rozdział 6 – Cytadela Procesów"
    ui_story "Pięć prób za sobą. Jesteś teraz Wojownikiem Bash – ale misja jeszcze trwa."
    ui_story "Wirus Chaosu uciekł na ostatnią linię obrony: Cytadelę Procesów."
    ui_story "Zainfekował samo jądro systemu, uruchamiając niekontrolowane procesy."
    ui_story "Zombie procesów zapełniają tablicę, osierocone programy pożerają CPU."
    ui_story "Pamięć systemowa sięga limitu – usługi padają jedna po drugiej."
    ui_story "Jeśli tego nie powstrzymasz, cały system terminala straci stabilność na zawsze."
    echo
    ui_story "Na wzgórzu za Wieżą Czarodzieja stoi mroczna Cytadela Procesów."
    ui_story "Jej mury drżą od nieustannie działających procesów i nieskończonych pętli."
    ui_story "W oknach widać błyski – to PID-y przebijające się przez zainfekowane jądro."
    ui_story "Przy bramie czeka postać w ciężkiej zbroi wykutej z tablic PID-ów."
    echo
    ui_dialog "Strażnik Procesów Daemon" \
        "Wojowniku Bash! Cytadela kryje ostateczny sekret terminala – zarządzanie \
procesami. Wirus zainfekował tu wszystko – każdy proces jest jego agentem. \
Musisz nauczyć się jak widzieć wszystkie uruchomione procesy za \
pomocą 'ps', jak je zatrzymywać z 'kill', jak monitorować z 'top' i jak \
zarządzać tłem z 'bg' i 'fg'. Wiem kto jesteś – pokonałeś pięć prób. \
To jest ostatnia bitwa. Pokonaj moich strażników i wypędź Wirusa raz na zawsze! \
Królestwo Terminala liczy na ciebie." \
        "${BOLD_WHITE}"
    press_enter

    ui_story "Trzy niebezpieczne istoty strzegą Cytadeli Procesów, każda potężniejsza od poprzedniej."
    ui_story "To jest twoje ostateczne wyzwanie, Wojowniku Bash!"
    echo
    press_enter
}

level_06_spellbook() {
    ui_clear
    ui_header "📖 Księga Zaklęć – Zarządzanie Procesami"
    ui_story "Daemon wyjmuje metalową tablicę z wygrawerowanymi PID-ami i symbolami."
    ui_story "Tablica jest ciężka – każdy PID to odpowiedzialność za żywy proces w systemie."
    ui_story "\"Procesy to żywe istoty w twoim systemie. Naucz się nimi władać – i dbać o nie.\""
    echo
    ui_hr "─"
    printf "  %b%-7s%b  ✦ %-20s  %s\n" "${COLOR_COMMAND}" "ps"     "${RESET}" "Oko Procesów"      "wyświetl wszystkie procesy"
    printf "  %b%-7s%b  ✦ %-20s  %s\n" "${COLOR_COMMAND}" "kill"   "${RESET}" "Ostateczny Sygnał" "zakończ proces (wyślij sygnał)"
    printf "  %b%-7s%b  ✦ %-20s  %s\n" "${COLOR_COMMAND}" "top"    "${RESET}" "Wszechwidzące Oko" "monitoruj procesy w czasie rzeczywistym"
    printf "  %b%-7s%b  ✦ %-20s  %s\n" "${COLOR_COMMAND}" "bg"     "${RESET}" "Cień Tła"          "wyślij zadanie do tła"
    printf "  %b%-7s%b  ✦ %-20s  %s\n" "${COLOR_COMMAND}" "fg"     "${RESET}" "Przywołanie"       "przenieś zadanie na pierwszy plan"
    printf "  %b%-7s%b  ✦ %-20s  %s\n" "${COLOR_COMMAND}" "jobs"   "${RESET}" "Zwój Zadań"        "wyświetl zadania bieżącej powłoki"
    printf "  %b%-7s%b  ✦ %-20s  %s\n" "${COLOR_COMMAND}" "nohup"  "${RESET}" "Tarcza Nieśmierci" "uruchom odpornie na rozłączenie"
    printf "  %b%-7s%b  ✦ %-20s  %s\n" "${COLOR_COMMAND}" "pgrep"  "${RESET}" "Łowca z Imienia"   "znajdź PID procesu po jego nazwie"
    ui_hr "─"
    echo
    ui_dialog "Strażnik Procesów Daemon" \
        "'ps aux' to twoje Oko Procesów – pokaże ci każdy działający program z jego \
PID-em, właścicielem i zużyciem CPU. 'kill PID' wysyła SIGTERM (15), \
ale 'kill -9 PID' to SIGKILL – któremu absolutnie nic się nie oprze. \
'top' to Wszechwidzące Oko – żywy widok wszystkich procesów, \
naciśnij 'q' by wyjść. 'Ctrl+Z' zatrzymuje proces, 'bg' wysyła do tła, \
'fg' go wróci. 'jobs' pokaże wszystkie zadania bieżącej sesji. \
'nohup komenda &' to Tarcza Nieśmierci – nawet wylogowanie go nie zatrzyma. \
'pgrep bash' znajdzie PID po nazwie – bez przeszukiwania całego 'ps'!" \
        "${BOLD_CYAN}"
    press_enter
}

level_06_encounter1() {
    ui_story "Wchodzisz przez bramę cytadeli. Korytarze pełne są błędów systemowych."
    ui_story "Tablica procesów miga – zamiast normalnych wpisów, same znaki zapytania."
    ui_story "Zombie Procesów wyłania się z mroku, ciągnąc za sobą łańcuch martwych procesów!"
    ui_story "Nie może umrzeć, bo nikt nie wywołał wait() na jego rodzicu."
    ui_story "Każdy jego krok zostawia nowy wpis w tablicy – nieusuwalne widmo procesu."
    sleep 1

    enemy_set \
        "Zombie Procesów" \
        90 \
        18 \
        "processes" \
        "Martwy proces, który nie może zniknąć ze stołu procesów. Zapełnia tablicę i spowalnia system do granicy wytrzymałości. To agent Wirusa – stworzony by paraliżować." \
        "Zombie procesów w końcu zostaje zebrany przez init – jego wpis znika z tablicy. Lista procesów jest czysta! Słyszysz jak system odetchnął z ulgą." \
        110 \
        35 \
        "Mikstura zdrowia"

    combat_start
}

level_06_encounter2() {
    ui_story "Idziesz głębiej w cytadelę. CPU-metr na ścianie bije na czerwono."
    ui_story "Wchodzisz głębiej. Demon Sierot Procesów blokuje drogę!"
    ui_story "Jego dzieci-procesy działają bez kontroli, zjadając CPU i pamięć."
    ui_story "Każdy rodzi następny – to stworzenie samo siebie reprodukuje w nieskończoność."
    ui_story "\"Moje dzieci są wszędzie!\" – ryczy demon z dziką radością."
    sleep 1

    enemy_set \
        "Demon Sierot" \
        110 \
        21 \
        "processes" \
        "Demon, którego procesy potomne oderwały się od kontroli – fork bomb w ludzkiej postaci. Każdy z nich konsumuje zasoby bez żadnego nadzoru. Stworzony przez Wirusa, by udusić system." \
        "Osierocone procesy zostają przejęte przez init i właściwie zakończone jednym po drugim. Demon patrzy w niedowierzaniu, jak jego armia znika. 'Jak... jak to możliwe?' – szepce i disparu!" \
        130 \
        40 \
        "Eliksir wiedzy"

    combat_start
}

level_06_encounter3() {
    ui_story "Wchodzisz do Wielkiej Komnaty Jądra. Jest tu zimno jak w serwerowym centrum danych."
    ui_story "Szczyt cytadeli. Kolos Jądra przebudza się z wiecznego snu!"
    ui_story "Jego ciało zbudowane jest z wątków jądra, a każde uderzenie to SIGKILL."
    ui_story "Ma tysiące oczu – każde patrzy na inny proces. Jest procesem nr 1 – sam init."
    ui_story "\"Jestem samym sercem systemu. Każdy proces żyje i umiera z mojej woli.\""
    sleep 1

    enemy_set \
        "Kolos Jądra" \
        170 \
        28 \
        "processes" \
        "Strażnik samego jądra systemu, ucieleśnienie init. Operuje bezpośrednio na tablicy procesów i może unicestwić każdy proces jednym gestem. Wirus uczynił go swoim ostatnim bastionem." \
        "Kolos Jądra pada z hukiem, który wstrząsa całą cytadelą. Przekazuje ci Klucz Administratora. 'Jesteś teraz pełnym władcą terminala!' – echo rozbrzmiewa w korytarzach." \
        180 \
        60 \
        "Klucz Administratora"

    combat_start
}

level_06_midpoint() {
    ui_story "Daemon czeka na ciebie przed ostatnimi drzwiami cytadeli."
    ui_story "Za drzwiami słyszysz bicie – jak serce samego jądra."
    echo
    ui_dialog "Strażnik Procesów Daemon" \
        "Posłuchaj zanim zaatakujesz Kolosa! Tam jest ostateczny strażnik Wirusa. \
'kill -9' to absolutna broń – żaden proces jej nie przetrwa, nawet nieprzerwywalne. \
'pkill -f wzorzec' uderza po nazwie lub wzorcu zamiast PID-u – wygodniejsze. \
'wait PID' wstrzyma skrypt do chwili zakończenia danego procesu. \
'nice -n -20 komenda' da ci maksymalny priorytet – twój proces staje się panem CPU. \
I pamiętaj: 'ps aux | grep wirus' znajdzie każdego agenta Wirusa po nazwie. \
Ta wiedza to twoja ostatnia tarcza – i miecz!" \
        "${BOLD_CYAN}"
    press_enter
}

level_06_encounter4() {
    ui_story "Za tronem Kolosa powietrze się zapada. Coś ogromnego wyłania się z ciemności."
    ui_story "Za tronem Kolosa unosi się coś niepojętego – Duch Jądra Linuksa we własnej osobie!"
    ui_story "Jest zbudowany z milionów linii kodu źródłowego i zarządza każdym procesem w systemie."
    ui_story "To sam Wirus Chaosu w swojej ostatecznej formie – przejął jądro i stał się nim."
    ui_story "\"Jestem teraz nieśmiertelny. Jestem systemem. Spróbuj mnie zatrzymać!\""
    sleep 1

    enemy_set \
        "Duch Jądra Linuksa" \
        185 \
        30 \
        "processes" \
        "Ostateczna forma Wirusa Chaosu – manifestacja skażonego jądra Linuksa. Każde jego spojrzenie wysyła sygnał. Każdy ruch to wywołanie systemowe. Połączył się z jądrem by stać się niepokonanym. To najcięższy egzamin w historii Królestwa Terminala." \
        "Duch Jądra skłania się nisko, a z jego sylwetki ulatuje mroczna energia – to Wirus opuszcza jądro! System zaczyna wracać do normalności. 'System działa harmonijnie pod twoją opieką' – brzmi echo. Wirus Chaosu jest pokonany! Pierścień Root'a ląduje w twoich rękach." \
        185 \
        65 \
        ""

    combat_start
}

level_06_complete() {
    ui_clear
    ui_header "Cytadela Procesów – Zdobyta!"
    ui_story "Cytadela milknie. Wszystkie procesy działają harmonijnie pod twoją kontrolą."
    ui_story "Wirus Chaosu opuścił jądro – sześć wielkich prób za tobą."
    ui_story "Królestwo Terminala zaczyna się odradzać. Katalogi prostują się, pliki wracają."
    ui_story "Strumienie tekstu płyną spokojnie, potoki łączą się we właściwym porządku."
    ui_story "Skrypty uruchamiają się same i wykonują swoją pracę. Procesy żyją w harmonii."
    echo
    ui_dialog "Strażnik Procesów Daemon" \
        "NIESAMOWITE! Pokonałeś wszystkich strażników Cytadeli i przepędziłeś Wirusa Chaosu! \
Posiadasz teraz kompletną wiedzę o zarządzaniu procesami: 'ps' by widzieć, \
'kill' by zatrzymywać, 'top' by monitorować, 'bg'/'fg' by zarządzać tłem, \
'jobs' by śledzić zadania, i 'nohup' by uodparniać procesy. \
Połącz tę wiedzę z tym, czego nauczyłeś się w Lesie, Jaskini, Świątyni, \
Rzece i Wieży – a będziesz absolutnym WŁADCĄ TERMINALA na wieki wieków!" \
        "${BOLD_YELLOW}"

    echo
    printf "  %b━━━ Opanowane Zarządzanie Procesami ━━━%b\n" "${BOLD_WHITE}" "${RESET}"
    printf "  %bps%b      – wyświetl uruchomione procesy\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %bkill%b    – zakończ proces (wyślij sygnał)\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %btop%b     – monitor procesów w czasie rzeczywistym\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %bbg%b      – wznów zadanie w tle\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %bfg%b      – przenieś zadanie na pierwszy plan\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %bjobs%b    – wyświetl zadania bieżącej powłoki\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %bnohup%b   – uruchom odpornie na rozłączenie\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %bpgrep%b   – szukaj PID-u po nazwie procesu\n" "${COLOR_COMMAND}" "${RESET}"
    echo

    ui_hr "★"
    ui_center "${BOLD_YELLOW}🏆  Gratulacje, ${PLAYER_NAME}!  🏆${RESET}"
    ui_center "${BOLD_WHITE}Jesteś teraz certyfikowanym WOJOWNIKIEM BASH!${RESET}"
    ui_center "${BOLD_GREEN}Wirus Chaosu pokonany. Królestwo Terminala ocalone.${RESET}"
    ui_hr "★"
    echo
    press_enter

    CURRENT_LEVEL=7
    save_game
}

run_level_06() {
    level_06_intro
    level_06_spellbook
    level_06_encounter1 || return 1
    if ! player_is_dead; then
        level_06_encounter2 || true
    fi
    if ! player_is_dead; then
        level_06_midpoint
        level_06_encounter3 || true
    fi
    if ! player_is_dead; then
        level_06_encounter4 || true
    fi
    if ! player_is_dead; then
        level_06_complete
    fi
}
