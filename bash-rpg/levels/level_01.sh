#!/usr/bin/env bash
# levels/level_01.sh – Las Nawigacji
# Uczy: ls, pwd, cd, mkdir, rmdir

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/colors.sh"
source "${SCRIPT_DIR}/../lib/ui.sh"
source "${SCRIPT_DIR}/../lib/player.sh"
source "${SCRIPT_DIR}/../lib/combat.sh"
source "${SCRIPT_DIR}/../lib/save_load.sh"

level_01_intro() {
    ui_clear
    ui_header "Rozdział 1 – Las Nawigacji"
    ui_story "Królestwo Terminala płonie."
    ui_story "Mroczna siła – Wirus Chaosu – wdarła się do systemów, plików i procesów."
    ui_story "Jak zaraza pełzająca przez korytarze kodu, niszczy wszystko, czego dotknie."
    ui_story "Katalogi są poplątane, dane skradzione, a procesy szaleją bez kontroli."
    ui_story "Wsie programistów leżą w gruzach – nikt nie może znaleźć swoich plików."
    ui_story "Tylko mistrz Bash może przepędzić chaos i przywrócić porządek w królestwie."
    echo
    ui_story "Ty, młody adept, opuściłeś wioskę Początkujących z jednym postanowieniem:"
    ui_story "nauczyć się Starożytnej Sztuki Bash i ocalić Królestwo Terminala."
    ui_story "Za plecami słyszysz łkanie mieszkańców – ich dane są zgubione, ich skrypty martwe."
    ui_story "Przysięgasz sobie, że wrócisz z wiedzą, która wszystko naprawi."
    echo
    ui_story "Twoja podróż zaczyna się tutaj – na skraju Zaczarowanego Lasu Bash."
    ui_story "Stare drzewa wznoszą się ku niebu, ich kora pokryta tajemniczymi runami poleceń."
    ui_story "Ścieżki plączą się w nieskończoność, a każdy krok w złym kierunku grozi zagubieniem."
    ui_story "Powietrze pachnie mchem i ozonowymi iskrami – tu terminal żyje własnym życiem."
    ui_story "Stary pustelnik blokuje ścieżkę, opierając się o sękatą laskę."
    echo
    ui_dialog "Pustelnik Siwobrodek" \
        "Stój, wędrowcze! Ten las kryje wiele niebezpieczeństw dla tych, którzy \
nie znają praw terminala. Jestem Siwobrodek – strzegę tej ścieżki od dekad, \
odkąd sam byłem w twoim miejscu. Stwory tutaj strzegą sekretów NAWIGACJI – \
sztuki poruszania się po katalogach, listowania ich zawartości \
i tworzenia nowych ścieżek. Wirus Chaosu wypchnął je z głębin lasu \
i uzbrojił w dezorientację. Ucz się dobrze, a las ustąpi twojej woli. \
A pamiętaj – to dopiero pierwsza z sześciu prób, które czekają na twojej drodze!" \
        "${BOLD_WHITE}"
    press_enter

    ui_story "Siwobrodek wskazuje na głąb lasu, gdzie ścieżki rozwidlają się w nieskończoność."
    ui_story "Musisz pokonać strażników, by przekroczyć Las Nawigacji."
    ui_story "Każda walka sprawdza twoją znajomość poleceń nawigacyjnych Bash."
    echo
    press_enter
}

level_01_spellbook() {
    ui_clear
    ui_header "📖 Księga Zaklęć – Nawigacja"
    ui_story "Siwobrodek wyjmuje z płaszcza starą księgę pokrytą świecącymi runami."
    ui_story "Strony szeleszczą same z siebie, jakby żyły własnym życiem."
    ui_story "\"Każde polecenie to zaklęcie. Ucz się ich nazw i mocy, zanim ruszysz dalej.\""
    ui_story "\"W tym lesie zgubiło się wielu przed tobą, bo nie znali tych słów.\""
    echo
    ui_hr "─"
    printf "  %b%-7s%b  ✦ %-18s  %s\n" "${COLOR_COMMAND}" "ls"    "${RESET}" "Wzrok Sowy"       "ujrzyj wszystko, co leży w katalogu"
    printf "  %b%-7s%b  ✦ %-18s  %s\n" "${COLOR_COMMAND}" "pwd"   "${RESET}" "Kamień Miejsca"   "poznaj swoje dokładne położenie w lesie"
    printf "  %b%-7s%b  ✦ %-18s  %s\n" "${COLOR_COMMAND}" "cd"    "${RESET}" "Teleportacja"     "przenieś się do dowolnego katalogu"
    printf "  %b%-7s%b  ✦ %-18s  %s\n" "${COLOR_COMMAND}" "mkdir" "${RESET}" "Stworzenie"       "wykuj nową ścieżkę z nicości"
    printf "  %b%-7s%b  ✦ %-18s  %s\n" "${COLOR_COMMAND}" "rmdir" "${RESET}" "Rozproszenie"     "wymaż pusty katalog ze świata"
    ui_hr "─"
    echo
    ui_dialog "Pustelnik Siwobrodek" \
        "'ls' – Wzrok Sowy – otworzy ci oczy na zawartość każdego katalogu. \
'pwd' – Kamień Miejsca – nigdy nie pozwoli ci się zgubić w gąszczu ścieżek. \
'cd' da ci moc swobodnego poruszania się między królestwami katalogów. \
Spróbuj 'cd ..' by wspiąć się wyżej, albo 'cd ~' by wrócić do domu. \
'mkdir' stworzy nowe ścieżki tam, gdzie ich nie ma, \
a 'rmdir' usunie te, których już nie potrzebujesz – lecz tylko puste! \
To pięć filarów, na których stoi cała nawigacja terminala!" \
        "${BOLD_CYAN}"
    press_enter
}

level_01_encounter1() {
    ui_story "Wchodzisz między pierwsze drzewa. Las jest gęsty i dezorientujący."
    ui_story "Ścieżki krzyżują się bez sensu – to robota Wirusa Chaosu."
    ui_story "Zagubiony Goblin wyłania się z zarośli, rzucając wokół pomiętymi mapami..."
    ui_story "Jego kieszenie pełne są pomięty wydruków katalogów, których nie potrafi czytać."
    ui_story "Widzisz w jego oczach panikę – nie wie, gdzie jest ani skąd przyszedł."
    sleep 1

    enemy_set \
        "Zagubiony Goblin" \
        40 \
        8 \
        "navigation" \
        "Zdezorientowany goblin ściskający zepsuty kompas. Ciągle myli 'ls' z 'cd'. Wirus Chaosu odebrał mu poczucie orientacji." \
        "Goblin pada ze zdezorientowania, upuszczając pomięty plan katalogów. Przez chwilę wygląda jakby coś pojął." \
        30 \
        10 \
        "Mikstura zdrowia"

    combat_start
}

level_01_encounter2() {
    ui_story "Głębiej w las. Drzewa są coraz starsze, a runy na ich korze – coraz bardziej pokrzywione."
    ui_story "Słyszysz ciężkie kroki... ziemia drży pod każdym krokiem."
    ui_story "Na ścieżkę wychodzi Zdezorientowany Troll, przewracając po drodze dwa dęby."
    ui_story "Ciągle wpisuje 'gdziejestem' i ryczy, gdy nic się nie dzieje."
    ui_story "Na jego kamienna tabliczka widać dziesiątki przekreślonych prób – żadna nie zadziałała."
    sleep 1

    enemy_set \
        "Zdezorientowany Troll" \
        60 \
        12 \
        "navigation" \
        "Ogromny troll wściekle walący w kamienny klawiaturę. Wie, że katalogi istnieją, ale nie ma pojęcia jak nimi nawigować. Wirus Chaosu wymazał mu pamięć o 'pwd'." \
        "Troll w końcu rozumie 'pwd' i ze łzami w oczach sprawdza gdzie jest. Spokojnie odchodzi, mamrocząc ścieżkę do domu." \
        50 \
        15 \
        ""

    combat_start
}

level_01_encounter3() {
    ui_story "Las ciemnieje nagle – jakby ktoś zgasił słońce."
    ui_story "Drzewa ciemnieją. Widmo Nawigacji materializuje się z cieni..."
    ui_story "Jego postać utkana jest z zagmatwanych ścieżek i zgubionych dowiązań."
    ui_story "Czujesz zimno przenikające do kości – to nie jest zwykłe stworzenie."
    ui_story "Widmo szepcze nazwy katalogów jak zaklęcia: /usr/local/share/lost/nobody/knows..."
    sleep 1

    enemy_set \
        "Widmo Nawigacji" \
        80 \
        15 \
        "navigation" \
        "Starożytny duch skręcony z zapomnianych ścieżek. Żywi się dezorientacją tych, którzy nie umieją nawigować w terminalu. Podobno było tu od samego początku, zanim powstał pierwszy katalog." \
        "Widmo rozprasza się w smugi światła, gdy recytujesz polecenia nawigacyjne. Droga przez las jest wolna! W miejscu gdzie stało leży błyszczący kompas." \
        80 \
        25 \
        "Kompas pwd"

    combat_start
}

level_01_midpoint() {
    ui_story "Zatrzymujesz się na małej polanie. Promienie słońca przebijają przez korony drzew."
    ui_story "Stary pustelnik pojawia się zza drzewa, kiwając głową z uznaniem."
    echo
    ui_dialog "Pustelnik Siwobrodek" \
        "Widzę, że radzisz sobie dobrze z podstawami! Zanim zmierzysz się z Widmem, \
zapamiętaj: flaga '-l' przy 'ls' pokaże ci szczegółowe uprawnienia pliku. \
Flaga '-t' sortuje pliki po czasie modyfikacji, '-R' przeszukuje \
podkatalogi rekurencyjnie, a 'cd -' przeniesie cię z powrotem tam, gdzie byłeś. \
Widmo nawigacji żywi się twoim strachem – zmusza cię do wykonywania \
poleceń pod presją. Pamiętaj o tych sztuczkach!" \
        "${BOLD_CYAN}"
    press_enter
}

level_01_encounter4() {
    ui_story "Las milknie. Nawet wiatr zatrzymał się w bezruchu."
    ui_story "Gdy już myślisz, że las jest wolny, ziemia pod stopami zaczyna drżeć!"
    ui_story "Korzenie drzew splątują się w gigantyczną postać. Leśny Arcystrażnik wyłania się!"
    ui_story "Ten pradawny elemental zbudowany jest z samych ścieżek absolutnych i względnych."
    ui_story "Jego głos brzmi jak szum tysiąca katalogów naraz: 'Czy naprawdę znasz ten las?'"
    sleep 1

    enemy_set \
        "Leśny Arcystrażnik" \
        95 \
        17 \
        "navigation" \
        "Pradawny duch lasu tkany ze ścieżek absolutnych i względnych. Strzeże sekretu lasu od zarania dziejów terminala. Testuje tylko tych, którzy naprawdę opanowali nawigację – nie oszczędza słabych." \
        "Arcystrażnik kiwa z szacunkiem. Korzenie opadają spokojnie. 'Godny jesteś przejść przez Las Nawigacji' – szepczą drzewa chórem. Skryta skrzynka ze złotem leży u twoich stóp!" \
        95 \
        30 \
        ""

    combat_start
}

level_01_complete() {
    ui_clear
    ui_header "Las Nawigacji – Pokonany!"
    ui_story "Słońce zalewa polanę gdy ostatni strażnik pada."
    ui_story "Las stopniowo się rozjaśnia – runy na drzewach zaczynają świecić spokojnym blaskiem."
    ui_story "Ścieżki prostują się – chaos Wirusa cofnął się chociaż z tego miejsca."
    echo
    ui_dialog "Pustelnik Siwobrodek" \
        "Niezwykłe! Opanowałeś sztukę nawigacji w rekordowym czasie. Pamiętaj: \
'ls' by zobaczyć, 'pwd' by wiedzieć gdzie jesteś, 'cd' by się poruszać, \
i 'mkdir'/'rmdir' by kształtować świat wokół siebie. Te umiejętności \
będą ci służyć w każdym zakątku terminala. Jaskinia Plików czeka na wschodzie – \
bądź tam ostrożny. Wirus ukrył tam znacznie więcej swoich sług." \
        "${BOLD_GREEN}"

    echo
    printf "  %b━━━ Opanowane Polecenia ━━━%b\n" "${BOLD_WHITE}" "${RESET}"
    printf "  %bls%b    – wyświetl zawartość katalogu\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %bpwd%b   – wypisz bieżący katalog roboczy\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %bcd%b    – zmień katalog\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %bmkdir%b – utwórz nowy katalog\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %brmdir%b – usuń pusty katalog\n" "${COLOR_COMMAND}" "${RESET}"
    echo
    press_enter

    CURRENT_LEVEL=2
    save_game
}

run_level_01() {
    level_01_intro
    level_01_spellbook
    level_01_encounter1 || return 1
    if ! player_is_dead; then
        level_01_encounter2 || true
    fi
    if ! player_is_dead; then
        level_01_midpoint
        level_01_encounter3 || true
    fi
    if ! player_is_dead; then
        level_01_encounter4 || true
    fi
    if ! player_is_dead; then
        level_01_complete
    fi
}
