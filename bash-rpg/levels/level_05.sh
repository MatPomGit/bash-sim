#!/usr/bin/env bash
# levels/level_05.sh – Wieża Czarodzieja
# Uczy: zmienne, if, for, while, funkcje, $?, shebang

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/colors.sh"
source "${SCRIPT_DIR}/../lib/ui.sh"
source "${SCRIPT_DIR}/../lib/player.sh"
source "${SCRIPT_DIR}/../lib/combat.sh"
source "${SCRIPT_DIR}/../lib/save_load.sh"

level_05_intro() {
    ui_clear
    ui_header "Rozdział 5 – Wieża Czarodzieja"
    ui_story "Cztery wielkie próby za tobą. Twoja moc jest imponująca – lecz nie wystarczająca."
    ui_story "Wirus Chaosu ewoluuje. Ucieka od pojedynczych poleceń, kryje się w czasie."
    ui_story "Stworzył skrypty, które się samoczynnie uruchamiają, replikują i niszczą."
    ui_story "By go pokonać raz na zawsze, potrzebujesz Najwyższej Sztuki – Skryptowania."
    echo
    ui_story "Nareszcie przed tobą wyrasta Wieża Skryptowania Czarodzieja."
    ui_story "Błyskawice uderzają w jej iglicę, gdy zmienne skrzą się w powietrzu."
    ui_story "Wokół niej krążą fragmenty kodu – pętle, warunki, zmienne – jak świetlne duchy."
    ui_story "Sama wieża wydaje się żywa, jakby oddychała rytmem skryptów."
    ui_story "Wielki Czarodziej Bourne pojawia się w wybuchu fragmentów skryptów."
    echo
    ui_dialog "Wielki Czarodziej Bourne" \
        "A więc przybyłeś, by nauczyć się najwyższej sztuki – Skryptowania Bash! \
Znam cię już z opowieści – pokonałeś strażników Lasu, Jaskini, Świątyni i Rzeki. \
Ale to wszystko były zaledwie zaklęcia jednorazowe. Zmienne to pojemniki na moc, \
warunki to rozwidlenia losu, pętle to nieskończone inkantacje, \
a funkcje wiążą wiedzę w wielokrotne zaklęcia. \
Razem tworzą skrypty – autonomiczne programy, które działają bez twojego udziału. \
To właśnie tym narzędziem pokonasz Wirusa Chaosu raz na zawsze! \
Przeżyj moich strażników, a zdobędziesz tytuł Wojownika Bash!" \
        "${BOLD_WHITE}"
    press_enter

    ui_story "Trzech potężnych strażników skryptowania stoi między tobą a tytułem Wojownika Bash."
    ui_story "To twój przedostatni test – po nim czeka już tylko finał."
    echo
    press_enter
}

level_05_spellbook() {
    ui_clear
    ui_header "📖 Księga Zaklęć – Skryptowanie"
    ui_story "Czarodziej Bourne otwiera ogromny tom oprawiony w piorunochron."
    ui_story "Strony iskrzą się – każdy przykład kodu jest żywy i porusza się po kartce."
    ui_story "\"Skryptowanie to magia wyższego rzędu. Zaklęcia, które same się wykonują.\""
    ui_story "\"Jeden skrypt może zastąpić godziny pracy. To jest prawdziwa moc terminala.\""
    echo
    ui_hr "─"
    printf "  %b%-12s%b  ✦ %-18s  %s\n" "${COLOR_COMMAND}" 'var=wartość' "${RESET}" "Runa Wiązania"   "zapisz wartość w zmiennej"
    printf "  %b%-12s%b  ✦ %-18s  %s\n" "${COLOR_COMMAND}" '$var'        "${RESET}" "Runa Wyzwolenia" "odczytaj wartość ze zmiennej"
    printf "  %b%-12s%b  ✦ %-18s  %s\n" "${COLOR_COMMAND}" "if/fi"       "${RESET}" "Rozwidlenie Losu" "wykonaj kod warunkowo"
    printf "  %b%-12s%b  ✦ %-18s  %s\n" "${COLOR_COMMAND}" "for/done"    "${RESET}" "Pętla Iteracji"  "powtórz dla każdego elementu"
    printf "  %b%-12s%b  ✦ %-18s  %s\n" "${COLOR_COMMAND}" "while/done"  "${RESET}" "Wieczna Warta"   "pętla dopóki warunek prawdziwy"
    printf "  %b%-12s%b  ✦ %-18s  %s\n" "${COLOR_COMMAND}" "func() {}"   "${RESET}" "Pieczęć Wiedzy"  "stwórz wielokrotnego użytku zaklęcie"
    printf "  %b%-12s%b  ✦ %-18s  %s\n" "${COLOR_COMMAND}" '$?'          "${RESET}" "Wyrocznianik"    "odczytaj wynik ostatniego polecenia"
    ui_hr "─"
    echo
    ui_dialog "Wielki Czarodziej Bourne" \
        "Zmienna to runa wiążąca – 'var=wartość' zapisuje, '\$var' odczytuje. \
Pamiętaj: żadnych spacji wokół znaku '='! To najczęstszy błąd początkujących. \
'if/fi' to moment decyzji – ścieżka rozwidla się: 'if [ warunek ]; then ... fi'. \
'for item in lista; do ... done' to inkantacja iteracji po każdym elemencie. \
'while [ warunek ]; do ... done' trwa dopóki warunek jest prawdziwy. \
Funkcja 'func() { ... }' wiąże całe zaklęcia w jedno słowo. \
A '\$?' to wyrocznianik – powie ci, czy ostatnie polecenie \
się udało (0) czy nie (cokolwiek innego). '\$1', '\$2'... to argumenty skryptu. \
To są cztery filary skryptowania – opanuj je, a nie ma rzeczy niemożliwych!" \
        "${BOLD_CYAN}"
    press_enter
}

level_05_encounter1() {
    ui_story "Wchodzisz do wieży. Ściany pokryte są ruchomymi liniami kodu."
    ui_story "Błyskawica! Z krokwi spada Wampir Zmiennych!"
    ui_story "Wysysa wartości ze zmiennych, zostawiając tylko puste ciągi."
    ui_story "Wszędzie gdzie przeszedł, zmienne są puste – \$PATH, \$HOME, \$USER – wszystko wymazane."
    sleep 1

    enemy_set \
        "Wampir Zmiennych" \
        80 \
        16 \
        "scripting" \
        "Blada istota wysysająca wartości ze zmiennych. Nie znosi prawidłowego przypisywania i rozwijania. Służy Wirusowi, by sabotować każdy skrypt poprzez wymazywanie wartości." \
        "Trumna pustych zmiennych wampira zostaje rozbita poprawnym przypisaniem. Zmienne znów płyną swobodnie! Słyszysz jak \$PATH wraca do życia." \
        100 \
        30 \
        ""

    combat_start
}

level_05_encounter2() {
    ui_story "Klatka schodowa kręci się w górę. Na każdym stopniu widać ten sam fragment kodu."
    ui_story "Lich Pętli blokuje następne piętro!"
    ui_story "Jest uwięziony w nieskończonej pętli i próbuje wciągnąć cię do środka."
    ui_story "Jego ciało miga – zapętlone między chwilą 'while true' a wiecznością."
    ui_story "\"Dołącz do mnie! Tu jest spokój – ta sama chwila, w nieskończoność!\""
    sleep 1

    enemy_set \
        "Lich Pętli" \
        100 \
        19 \
        "scripting" \
        "Nieumarły mag uwięziony w nieskończonej pętli 'while true; do'. Wykonuje ten sam kod od stuleci i szuka towarzystwa dla swojego wiecznego piekła. Stworzony przez błąd programisty, który zapomniał o warunku wyjścia." \
        "Przerywasz nieskończoną pętlę licha dobrze umieszczoną instrukcją 'break'. Lich zatrzymuje się, patrzy na swoje dłonie w niedowierzaniu. W końcu po wiekach – odpoczywa." \
        120 \
        35 \
        "Mikstura zdrowia"

    combat_start
}

level_05_encounter3() {
    ui_story "Szczyt wieży. Drzwi przed tobą ozdobione są drzewem decyzyjnym wyrytym w złocie."
    ui_story "Konstrukt Warunków budzi się – golem z czystego if/else!"
    ui_story "Jego ciało zbudowane jest z logiki boolowskiej, a oczy płoną operatorami porównania."
    ui_story "-eq, -ne, -gt, -lt – każde spojrzenie to inny operator, każde uderzenie to test."
    sleep 1

    enemy_set \
        "Konstrukt Warunków" \
        150 \
        25 \
        "scripting" \
        "Przerażający automat zbudowany z instrukcji warunkowych. Każdy atak to rozgałęziające się drzewo decyzyjne o głębokości stu poziomów. Tylko mistrz logiki skryptowania może rozplątać jego kod." \
        "Ostatni warunek Konstruktu ewaluuje do TRUE: jesteś godny. Automat zatrzymuje się i kłania. 'Logika jest z tobą' – mówi, wręczając Laskę Skryptów!" \
        160 \
        50 \
        "Laska Skryptów"

    combat_start
}

level_05_midpoint() {
    ui_story "Czarodziej Bourne materializuje się w wirze kodu, siadając na kryształowym kamieniu."
    echo
    ui_dialog "Wielki Czarodziej Bourne" \
        "Dobra robota do tej pory! Ale Konstrukt Warunków to dopiero prolog. \
Za nim ukrywają się jeszcze silniejsi przeciwnicy. Przypomnij sobie: \
'\$1', '\$@' i '\$#' to klucze do argumentów skryptów – bez nich skrypt \
nie może przyjmować danych z zewnątrz. 'case ... esac' jest elegantszy \
od długich if-elif: 'case \$var in a) ... ;; b) ... ;; esac'. \
A tablice 'arr=(elem1 elem2)' to struktury danych, które otwierają \
zupełnie nowe możliwości! '\${arr[@]}' odczyta wszystkie elementy." \
        "${BOLD_CYAN}"
    press_enter
}

level_05_encounter4() {
    ui_story "Uniosłeś Laskę Skryptów. Piorun uderza w iglicę wieży."
    ui_story "Spod Laski Skryptów wyłania się cień... Arcymag Kodu się przebudza!"
    ui_story "Napisał pierwsze skrypty powłoki. Pamięta czasy przed bash, kiedy był tylko sh."
    ui_story "Jego szaty to tysiące linii kodu, a broda sięga do /dev/null."
    ui_story "\"Widziałem narodziny Bash. Byłem tu, kiedy powstawał pierwszy shebang. Czy ty jesteś godny?\""
    sleep 1

    enemy_set \
        "Arcymag Kodu" \
        165 \
        27 \
        "scripting" \
        "Legendarny czarodziej, który napisał pierwszy skrypt powłoki. Jego moc pochodzi z dekad doświadczenia. Zna każdą zmienną specjalną, każdy operator i każdą pułapkę – i używa ich wszystkich." \
        "Arcymag kiwa głową w milczeniu. Długa chwila ciszy. Potem przemawia cicho: 'Masz duszę skryptowacza. Wyjdź i twórz!' Wręcza ci Rodowód Bourne'a – dowód twojego mistrzostwa." \
        165 \
        55 \
        ""

    combat_start
}

level_05_complete() {
    ui_clear
    ui_header "Wieża Czarodzieja – Zdobyta!"
    ui_story "Wieża jaśnieje złotym światłem. Osiągnąłeś szczyt – dosłownie i w przenośni."
    ui_story "Skrypty latają wokół ciebie jak świetlne motyle, każdy kompletny i elegancki."
    ui_story "Ale gdzieś w oddali słyszysz głuchy łomot – Cytadela Procesów jeszcze czeka."
    echo
    ui_dialog "Wielki Czarodziej Bourne" \
        "NIESAMOWITE! Pokonałeś wszystkich moich strażników i dowiodłeś swojej wartości. \
Posiadasz teraz wiedzę zmiennych, warunków, pętli i \
funkcji – cztery filary skryptowania Bash. Z tymi mocami \
połączonymi z twoim mistrzostwem nawigacji, plików, tekstu i potoków, \
jesteś prawdziwym WOJOWNIKIEM BASH! \
Ale Wirus Chaosu uciekł do ostatniego bastionu – Cytadeli Procesów. \
Zainfekował samo jądro systemu. Idź tam i skończ z nim raz na zawsze!" \
        "${BOLD_YELLOW}"

    echo
    printf "  %b━━━ Opanowane Skrypty ━━━%b\n" "${BOLD_WHITE}" "${RESET}"
    printf "  %bvar=wartość%b  – przypisz zmienną (bez spacji!)\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %b\$var%b         – rozwiń zmienną\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %bif/fi%b        – warunkowe rozgałęzienie\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %bfor/done%b     – iteruj po liście\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %bwhile/done%b   – pętla gdy warunek prawdziwy\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %bfunc() {}%b    – zdefiniuj funkcję\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %b\$?%b           – kod wyjścia ostatniego polecenia\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %bread%b         – wczytaj wejście użytkownika\n" "${COLOR_COMMAND}" "${RESET}"
    echo
    press_enter

    CURRENT_LEVEL=6
    save_game
}

run_level_05() {
    level_05_intro
    level_05_spellbook
    level_05_encounter1 || return 1
    if ! player_is_dead; then
        level_05_encounter2 || true
    fi
    if ! player_is_dead; then
        level_05_midpoint
        level_05_encounter3 || true
    fi
    if ! player_is_dead; then
        level_05_encounter4 || true
    fi
    if ! player_is_dead; then
        level_05_complete
    fi
}
