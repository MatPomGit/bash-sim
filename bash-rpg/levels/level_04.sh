#!/usr/bin/env bash
# levels/level_04.sh – Rzeka Potoków
# Uczy: |, >, >>, <, 2>, tee, xargs, /dev/null

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/colors.sh"
source "${SCRIPT_DIR}/../lib/ui.sh"
source "${SCRIPT_DIR}/../lib/player.sh"
source "${SCRIPT_DIR}/../lib/combat.sh"
source "${SCRIPT_DIR}/../lib/save_load.sh"

level_04_intro() {
    ui_clear
    ui_header "Rozdział 4 – Rzeka Potoków"
    ui_story "Pokonałeś strażników tekstu. Twój arsenał zaklęć rośnie z każdą chwilą."
    ui_story "Lecz Wirus Chaosu uderzył w samo serce przepływu danych – Rzekę Potoków."
    ui_story "Bez sprawnych połączeń między poleceniami, cały system terminala zginie."
    ui_story "Jego agenci zerwali potoki, zatamowali przekierowania i zmieszali strumienie."
    echo
    ui_story "Docierasz do brzegów legendarnej Rzeki Potoków."
    ui_story "Kiedyś wartka i czysta, teraz wzdymają się w niej bąble błędnych danych."
    ui_story "Dane płyną jak woda – lub raczej – powinny płynąć."
    ui_story "Teraz spiętrzają się w chaotycznych rozlewiskach, gubią się w martwych ramionach rzeki."
    ui_story "Na kamieniu przy moście siedzi starszy przewoźnik, reperując rury."
    echo
    ui_dialog "Przewoźnik Przekierowanie" \
        "By przeprawić się przez Rzekę Potoków, musisz rozumieć przepływ danych. \
Symbol potoku '|' wysyła wyjście jednego polecenia do drugiego jak wodę przez rurę. \
Nawiasy '>' i '>>' przekierowują dane do plików – jeden niszczy stare, drugi dołącza. \
'<' pobiera dane z plików. '2>' przechwytuje błędy jak sieć łowi ryby. \
A 'tee' rozdziela przepływ na dwa strumienie jednocześnie. \
Widziałem, jak wielu wędrowców utonęło przez brak tej wiedzy. \
Opanuj przekierowania, a opanujesz samą krew powłoki!" \
        "${BOLD_WHITE}"
    press_enter

    ui_story "Trzy potwory rzeczne strzegą przeprawy i czynią rzekę nieprzebytą."
    ui_story "Tylko mistrz potoków i przekierowań może przejść suchą nogą."
    echo
    press_enter
}

level_04_spellbook() {
    ui_clear
    ui_header "📖 Księga Zaklęć – Potoki i Przekierowania"
    ui_story "Przewoźnik wyciąga z rękawa metalową tabliczkę z wyrytymi symbolami."
    ui_story "Symbole błyszczą jak rtęć – to nie litery, to sam przepływ danych."
    ui_story "\"Te znaki to nie litery – to mosty i śluzy między poleceniami. Naucz się ich!\""
    echo
    ui_hr "─"
    printf "  %b%-6s%b  ✦ %-20s  %s\n" "${COLOR_COMMAND}" "|"     "${RESET}" "Most Mocy"          "wyślij stdout do stdin następnego"
    printf "  %b%-6s%b  ✦ %-20s  %s\n" "${COLOR_COMMAND}" ">"     "${RESET}" "Pieczęć Danych"     "przekieruj stdout do pliku (nadpisz)"
    printf "  %b%-6s%b  ✦ %-20s  %s\n" "${COLOR_COMMAND}" ">>"    "${RESET}" "Łańcuch Wpisu"      "dołącz stdout do pliku (dołącz)"
    printf "  %b%-6s%b  ✦ %-20s  %s\n" "${COLOR_COMMAND}" "<"     "${RESET}" "Runa Przywołania"   "przekieruj plik na stdin"
    printf "  %b%-6s%b  ✦ %-20s  %s\n" "${COLOR_COMMAND}" "2>"    "${RESET}" "Pułapka Błędów"     "przekieruj stderr do pliku"
    printf "  %b%-6s%b  ✦ %-20s  %s\n" "${COLOR_COMMAND}" "tee"   "${RESET}" "Rozdwojenie"        "wyświetl I zapisz jednocześnie"
    printf "  %b%-6s%b  ✦ %-20s  %s\n" "${COLOR_COMMAND}" "xargs" "${RESET}" "Tkanie Argumentów"  "buduj argumenty z linii stdin"
    ui_hr "─"
    echo
    ui_dialog "Przewoźnik Przekierowanie" \
        "Każdy z tych symboli to most lub zapora na rzece danych. '|' łączy \
polecenia – wyjście pierwszego staje się wejściem drugiego. Możesz łączyć \
tyle poleceń ile chcesz: 'cat plik | grep wzorzec | sort | uniq'. \
'>' to tama, która skierowuje dane do pliku – ale uwaga, niszczy co było! \
'>>' delikatniej dołącza do istniejącego pliku. '<' odwraca przepływ – \
plik zasila polecenie. '2>' przechwytuje błędy oddzielnie od danych. \
'2>&1' scala stderr ze stdout w jeden strumień. \
'tee' rozdziela rzekę na dwa kanały – jeden na ekran, drugi do pliku. \
Łącz je razem jak rury wodociągu, a zbudujesz potężne rurociągi danych!" \
        "${BOLD_CYAN}"
    press_enter
}

level_04_encounter1() {
    ui_story "Wchodzisz na most nad rzeką. Woda jest czarna od skażonych danych."
    ui_story "Nagle most drży. Coś wynurza się z wody!"
    ui_story "Potokowy Smok wyrywa się z wody, owijając się wokół zepsutego rurociągu!"
    ui_story "Jego ogon to symbol potoku, a z pyska zieje niezłączonymi poleceniami."
    ui_story "Wokół niego wirują fragmenty poleceń, które nigdy nie dotrą do celu."
    sleep 1

    enemy_set \
        "Potokowy Smok" \
        70 \
        14 \
        "pipes" \
        "Wężowy smok, którego moc pochodzi ze zepsutych rurociągów. Nie znosi poprawnie połączonych poleceń – zerwane potoki to jego żywioł." \
        "Potokowy Smok rozplątuje się gdy każde polecenie w łańcuchu dociera do celu. Wślizguje się z powrotem do rzeki, pokonany i upokorzony." \
        75 \
        25 \
        ""

    combat_start
}

level_04_encounter2() {
    ui_story "Przeprawiasz się na drugi brzeg. Tu rzeka ma kilka ramion – wszystkie kręte."
    ui_story "Nurt przybiera! Coś pędzi pod powierzchnią, zostawiając ślad bąbli błędów."
    ui_story "Wąż Przekierowania wynurza się, sycząc nazwami plików!"
    ui_story "Indyskryminacyjnie nadpisuje pliki swoim kłem '>' – niszczy wszystko na swej drodze."
    ui_story "Za nim zostaje ścieżka zniszczonych logów i uśmierconych danych."
    sleep 1

    enemy_set \
        "Wąż Przekierowania" \
        90 \
        17 \
        "pipes" \
        "Przebiegły wąż nadpisujący ważne pliki kłem '>'. Boi się operatora '>>' nade wszystko – dołączanie zamiast niszczenia to dla niego tortury." \
        "Wąż jest zmuszony dołączać zamiast nadpisywać i wycofuje się ze wstydem. Za nim widać ścieżkę plików, które udało się ocalić." \
        90 \
        30 \
        "Mikstura zdrowia"

    combat_start
}

level_04_encounter3() {
    ui_story "Docierasz do głębokiej toni. Woda jest tu niemal czarna."
    ui_story "Rzeka ciemnieje. Z głębin wynurza się Kałamarnica Strumieni!"
    ui_story "Osiem macek, każda to inny deskryptor pliku, smaga powierzchnię wody."
    ui_story "Jej atrament to czysty stderr, zatruwający wszystko wokół."
    sleep 1

    enemy_set \
        "Kałamarnica Strumieni" \
        130 \
        22 \
        "pipes" \
        "Starożytna kałamarnica stderr i stdout. Plącze wszystkie twoje potoki i przekierowuje błędy do /dev/null, by nie wiedział co idzie nie tak. Przerażający przeciwnik w każdych wodach." \
        "Deskryptory pliku kałamarnicy zostają wreszcie posortowane i poprawnie połączone. Zanurza się z zadowolonym bulgotaniem, zostawiając Trójząb Potoków na skale!" \
        130 \
        40 \
        "Trójząb Potoków"

    combat_start
}

level_04_midpoint() {
    ui_story "Zatrzymujesz się na kamienistej ławicy w połowie rzeki."
    ui_story "Przewoźnik Przekierowanie dobija tu łódką i zatrzymuje się przy tobie."
    echo
    ui_dialog "Przewoźnik Przekierowanie" \
        "Miej się na baczności! Za Kałamarnicą czeka jeszcze coś straszniejszego. \
Pamiętaj o operatorach '&&' i '||' – łańcuchują polecenia logicznie: \
'cmd1 && cmd2' wykona drugie tylko jeśli pierwsze się powiedzie. \
'cmd1 || cmd2' wykona drugie tylko jeśli pierwsze się nie powiedzie. \
Subshell '()' izoluje środowisko – zmiany tam nie przedostaną się na zewnątrz. \
A heredoc '<<EOF' wpycha tekst prosto do polecenia bez pliku. \
To są bronie wyższego rzędu – używaj ich mądrze!" \
        "${BOLD_CYAN}"
    press_enter
}

level_04_encounter4() {
    ui_story "Prawie jesteś na drugim brzegu. Rzeka ostatni raz wzdyma się złowrogo."
    ui_story "Rzeka wzbiera. Z jej środka wyłania się Hydra Przekierowań!"
    ui_story "Każda z siedmiu głów reprezentuje inny operator przekierowania."
    ui_story "Odetnij jedną głowę, a wyrosną dwie – to ostatnia linia obrony Wirusa na rzece."
    sleep 1

    enemy_set \
        "Hydra Przekierowań" \
        145 \
        24 \
        "pipes" \
        "Mityczny potwór z siedmioma głowami – każda to inny operator: |, >, >>, <, 2>, &&, ||. Odetnij jedną głowę, wyrosną dwie. Tylko kompletna wiedza o każdym operatorze może ją pokonać." \
        "Wszystkie głowy Hydry opadają jednocześnie gdy demonstrujesz pełne mistrzostwo potoków. Rzeka rozlewa się złotym blaskiem, a Kamień Potoków ląduje w twoich rękach!" \
        145 \
        45 \
        ""

    combat_start
}

level_04_complete() {
    ui_clear
    ui_header "Rzeka Potoków – Przeprawiona!"
    ui_story "Rzeka uspokaja się. Dane płyną płynnie przez idealnie połączone potoki."
    ui_story "Strumienie są czyste, przekierowania sprawne – Wirus stracił kontrolę nad rzeką."
    ui_story "Na drugim brzegu widać w oddali sylwetkę wieży przeszytej piorunami."
    echo
    ui_dialog "Przewoźnik Przekierowanie" \
        "Zrobiłeś to! Rzeka jest oswojona i znowu czysta. Z potokami i przekierowaniami \
możesz łączyć dowolną liczbę poleceń, filtrować i transformować strumienie danych, \
zapisywać wyjście do plików i wyciszać hałas z /dev/null. \
'2>&1' to jeden z najpotężniejszych tricków – scala stderr ze stdout. \
To są fundamentalne elementy składowe mistrzostwa skryptowania powłoki. \
Wieża Czarodzieja czeka na ciebie na wzgórzu – tam nauczysz się ostatecznej sztuki!" \
        "${BOLD_GREEN}"

    echo
    printf "  %b━━━ Opanowane Operatory ━━━%b\n" "${BOLD_WHITE}" "${RESET}"
    printf "  %b|%b      – potok: wyślij stdout do stdin następnego polecenia\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %b>%b      – przekieruj stdout do pliku (nadpisz)\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %b>>%b     – przekieruj stdout do pliku (dołącz)\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %b<%b      – przekieruj plik na stdin\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %b2>%b     – przekieruj stderr do pliku\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %b2>&1%b   – przekieruj stderr na stdout\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %btee%b    – podziel wyjście: wyświetl I zapisz\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %bxargs%b  – zbuduj argumenty polecenia z linii stdin\n" "${COLOR_COMMAND}" "${RESET}"
    echo
    press_enter

    CURRENT_LEVEL=5
    save_game
}

run_level_04() {
    level_04_intro
    level_04_spellbook
    level_04_encounter1 || return 1
    if ! player_is_dead; then
        level_04_encounter2 || true
    fi
    if ! player_is_dead; then
        level_04_midpoint
        level_04_encounter3 || true
    fi
    if ! player_is_dead; then
        level_04_encounter4 || true
    fi
    if ! player_is_dead; then
        level_04_complete
    fi
}
