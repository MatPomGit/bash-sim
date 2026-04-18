#!/usr/bin/env bash
# levels/level_02.sh – Jaskinia Plików
# Uczy: touch, cat, cp, mv, rm, ln, file, man

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/colors.sh"
source "${SCRIPT_DIR}/../lib/ui.sh"
source "${SCRIPT_DIR}/../lib/player.sh"
source "${SCRIPT_DIR}/../lib/combat.sh"
source "${SCRIPT_DIR}/../lib/save_load.sh"

level_02_intro() {
    ui_clear
    ui_header "Rozdział 2 – Jaskinia Plików"
    ui_story "Las Nawigacji jest za tobą. Twoje pierwsze zaklęcia płyną już w żyłach."
    ui_story "Lecz Wirus Chaosu nie śpi – jego macki sięgają głębiej niż gałęzie lasu."
    ui_story "Przed tobą, wyryta w skale, zieje ciemna szczelina: Jaskinia Plików."
    ui_story "To tu Wirus ukrywa skradzione dane, miesza pliki i niszczy archiwa."
    ui_story "Z głębin dochodzą odgłosy – skrzypienie zmienianych nazw, trzask usuwanych danych."
    ui_story "Ściany jaskini wyłożone są kryształami w kształcie ikon plików."
    ui_story "Część z nich jest rozbita – to ślady po działaniach Wirusa Chaosu."
    ui_story "Tajemniczy archiwista siedzi przy wejściu, polerując pergaminowy zwój."
    echo
    ui_dialog "Archiwista Pergamin" \
        "Witaj, nawigatorze! Jaskinia przed tobą rządzona jest przez stwory, które \
niszczą, ukrywają i usuwają pliki. To armia Wirusa – stworzona specjalnie \
po to, by uniemożliwić zarządzanie danymi. By przeżyć, musisz opanować operacje \
na plikach – tworzenie z 'touch', czytanie z 'cat', kopiowanie z 'cp', \
przenoszenie z 'mv' i budzącą postrach 'rm', która niszczy bez litości. \
Uważaj – w odróżnieniu od świata powyżej, tutaj nie ma cofania! \
Każdy usunięty plik znika na zawsze." \
        "${BOLD_WHITE}"
    press_enter

    ui_story "Archiwista wskazuje na głąb jaskini, gdzie błyskają kryształy danych."
    ui_story "Strażnicy chronią Jaskinię Plików przed każdym, kto chce zaprowadzić porządek."
    ui_story "Pokonaj ich, by zdobyć Traktat Mistrzostwa Plików i ruszyć dalej."
    echo
    press_enter
}

level_02_spellbook() {
    ui_clear
    ui_header "📖 Księga Zaklęć – Pliki"
    ui_story "Archiwista Pergamin rozwija stary zwój i wskazuje na wyryte w nim runy."
    ui_story "Zwój jest stary – jego krawędzie spalone, ale treść nienaruszona."
    ui_story "\"Pliki to istota każdego systemu. Kto panuje nad plikami, panuje nad wszystkim.\""
    ui_story "\"Przed tobą osiem zaklęć – każde niezbędne, każde niebezpieczne w złych rękach.\""
    echo
    ui_hr "─"
    printf "  %b%-7s%b  ✦ %-18s  %s\n" "${COLOR_COMMAND}" "touch"  "${RESET}" "Przywołanie"      "stwórz nowy, pusty plik"
    printf "  %b%-7s%b  ✦ %-18s  %s\n" "${COLOR_COMMAND}" "cat"    "${RESET}" "Czytanie Zwoju"   "wyświetl zawartość pliku"
    printf "  %b%-7s%b  ✦ %-18s  %s\n" "${COLOR_COMMAND}" "cp"     "${RESET}" "Duplikacja"       "skopiuj plik w nowe miejsce"
    printf "  %b%-7s%b  ✦ %-18s  %s\n" "${COLOR_COMMAND}" "mv"     "${RESET}" "Translokacja"     "przenieś lub zmień nazwę pliku"
    printf "  %b%-7s%b  ✦ %-18s  %s\n" "${COLOR_COMMAND}" "rm"     "${RESET}" "Unicestwienie"    "usuń plik – bezpowrotnie!"
    printf "  %b%-7s%b  ✦ %-18s  %s\n" "${COLOR_COMMAND}" "ln -s"  "${RESET}" "Więź Cienia"      "stwórz dowiązanie symboliczne"
    printf "  %b%-7s%b  ✦ %-18s  %s\n" "${COLOR_COMMAND}" "file"   "${RESET}" "Prawdziwe Oblicze" "ujawnij prawdziwy typ pliku"
    printf "  %b%-7s%b  ✦ %-18s  %s\n" "${COLOR_COMMAND}" "man"    "${RESET}" "Wyrocznia"        "pytaj wyrocznię o każde zaklęcie"
    ui_hr "─"
    echo
    ui_dialog "Archiwista Pergamin" \
        "Zapamiętaj: 'touch' przywołuje nowy plik z nicości lub odświeża jego datę. \
'cat' pozwoli ci zajrzeć do jego wnętrza – możesz go też użyć \
do łączenia plików razem! 'cp' to duplikacja – oryginał zostaje, \
'cp -r' skopiuje cały katalog. 'mv' przenosi lub przemianowuje bez śladu. \
Ale 'rm' to Unicestwienie – raz użyte, nie ma odwołania! \
'ln -s' tworzy cień pliku w innym miejscu – zmień oryginał, cień też się zmieni. \
'file' zdradzi ci co naprawdę kryje się pod rozszerzeniem. \
A 'man' to wyrocznia wszelkiej wiedzy – pytaj ją zawsze, gdy się wahasz!" \
        "${BOLD_CYAN}"
    press_enter
}

level_02_encounter1() {
    ui_story "Wchodzisz w głąb jaskini. Kryształy rzucają niebieskie refleksy na ściany."
    ui_story "W powietrzu unosi się zapach ozone i spalonych danych."
    ui_story "Plikowy Fantom dryfuje ku tobie, niosąc pusty plik..."
    ui_story "Ciągle szepcze 'jak STWORZYĆ plik?' – jego głos jest jak szum zerowego bajtu."
    sleep 1

    enemy_set \
        "Plikowy Fantom" \
        50 \
        10 \
        "files" \
        "Półprzezroczysty duch dzierżący puste zwoje. Nie potrafi tworzyć plików i wrzeszczy na puste katalogi. Wirus Chaosu odebrał mu wiedzę o 'touch'." \
        "Fantom w końcu materializuje plik używając 'touch' i niknie, usatysfakcjonowany. W miejscu gdzie stał leży ledwo widoczna kałuża danych." \
        40 \
        15 \
        ""

    combat_start
}

level_02_encounter2() {
    ui_story "Korytarz jaskini zwęża się. Kryształy na ścianach mają porozłupywane oblicza."
    ui_story "Ktoś – albo coś – szalał tu niedawno, rozrzucając pliki na lewo i prawo."
    ui_story "W głębi jaskini Zepsuty Demon blokuje drogę."
    ui_story "Pomieszał wszystkie nazwy plików i gorączkowo je przenosi – byle gdzie, byle inaczej."
    ui_story "W jego oczach widać maniakalne zadowolenie z chaosu, który sieje."
    sleep 1

    enemy_set \
        "Zepsuty Demon" \
        70 \
        14 \
        "files" \
        "Demon zrodzony z nieudanego sprawdzania systemu plików. Przenosi pliki w losowe miejsca i rechocze maniakalnie. Służy Wirusowi Chaosu z namaszczeniem." \
        "Demon jest zmuszony przywrócić porządek, kładąc każdy plik na właściwym miejscu. Wyje z bólu, gdy musi używać 'mv' do naprawy zamiast do zniszczenia." \
        60 \
        20 \
        "Mikstura zdrowia"

    combat_start
}

level_02_encounter3() {
    ui_story "Główna komnata jaskini. Sufit sięga tak wysoko, że niknie w ciemności."
    ui_story "Jaskinia drży. Kamień kruszy się ze sklepienia."
    ui_story "Archiwalny Elemental przebudza się ze swojego wielowiekowego snu!"
    ui_story "Ta starożytna istota zbudowana jest w całości ze skompresowanych archiwów i zepsutych danych."
    ui_story "Każdy jego krok to grzechot twardych dowiązań, każdy oddech to strumień uszkodzonych metadanych."
    sleep 1

    enemy_set \
        "Archiwalny Elemental" \
        100 \
        18 \
        "files" \
        "Majestatyczne stworzenie ze spakowanych archiwów i dowiązań symbolicznych. Strzeże Traktatu Mistrzostwa Plików brutalnymi atakami usuwania. Jego skóra to warstwy skompresowanych tar.gz." \
        "Elemental rozsypuje się w stos dobrze zorganizowanych plików, każdy na swoim miejscu. Traktat Mistrzostwa Plików ląduje w twoich rękach!" \
        100 \
        30 \
        "Traktat Plików"

    combat_start
}

level_02_midpoint() {
    ui_story "Zatrzymujesz się w bocznej komnacie. Na ścianie widać wyryte przez poprzednich wędrowców ostrzeżenia."
    ui_story "Archiwista Pergamin wyłania się zza stalaktytu, trzymając stary zwój."
    echo
    ui_dialog "Archiwista Pergamin" \
        "Uwaga, wędrowcze! Zanim zmierzysz się z Archiwalnym Elementalem, przypomnij sobie: \
'stat' zdradzi ci każdy sekret pliku – rozmiar, uprawnienia, daty modyfikacji. \
'diff' pokaże co zmieniło się między dwoma wersjami pliku. \
'chmod +x' doda bit wykonywalności – bez niego żaden skrypt nie ruszy. \
A 'wc -l' powie ile linii kryje dany plik. Elemental ma wiele lat \
i wiele sztuczek – twoja wiedza to jedyna tarcza!" \
        "${BOLD_CYAN}"
    press_enter
}

level_02_encounter4() {
    ui_story "Podniosłeś Traktat – i nagle korytarz za ołtarzem pęka!"
    ui_story "Z głębin jaskini wypełza coś czego się nie spodziewałeś – Golem Danych!"
    ui_story "Jego ciało skute jest z twardych dowiązań i metadanych plików systemu."
    ui_story "Oczy płoną numerami i-węzłów. Warczy na ciebie numerami bitów uprawnień."
    sleep 1

    enemy_set \
        "Golem Danych" \
        115 \
        20 \
        "files" \
        "Masywny konstrukt z twardych dowiązań i metadanych. Każde jego uderzenie zmienia uprawnienia i atrybuty twoich plików. Jest ostatnim strażem Jaskini – stworzony by bronić jej do końca." \
        "Golem kruszy się na kupę zwykłych plików, wszystkie czytelne i nienaruszone. Wśród nich błyszczy Klucz Dostępu – rzadki łup ze skarbca jaskini!" \
        115 \
        35 \
        ""

    combat_start
}

level_02_complete() {
    ui_clear
    ui_header "Jaskinia Plików – Oczyszczona!"
    ui_story "Jaskinia skąpana jest teraz w ciepłej, zorganizowanej poświacie."
    ui_story "Kryształy na ścianach znów świecą równomiernie – bez fluktuacji chaosu."
    ui_story "Gdzieś w głębi słyszysz westchnienie ulgi, jakby sama jaskinia odetchnęła."
    echo
    ui_dialog "Archiwista Pergamin" \
        "Niezwykłe umiejętności! Oswoiłeś Jaskinię Plików. Zawsze pamiętaj \
o mocy, którą teraz dzierżysz: 'touch' by tworzyć, 'cat' by czytać, 'cp' by kopiować, \
'mv' by przenosić lub zmieniać nazwę, i 'rm' by usuwać. Używaj 'rm' mądrze – \
wielka moc rodzi wielką odpowiedzialność. W Bash nie ma kosza! \
Świątynia Tekstu leży na południu – tam Wirus zainfekował same strumienie danych." \
        "${BOLD_GREEN}"

    echo
    printf "  %b━━━ Opanowane Polecenia ━━━%b\n" "${BOLD_WHITE}" "${RESET}"
    printf "  %btouch%b  – utwórz plik / zaktualizuj datę\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %bcat%b    – wyświetl zawartość pliku\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %bcp%b     – kopiuj pliki/katalogi\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %bmv%b     – przenieś lub zmień nazwę pliku\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %brm%b     – usuń pliki (trwale!)\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %bln -s%b  – utwórz dowiązanie symboliczne\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %bfile%b   – określ typ pliku\n" "${COLOR_COMMAND}" "${RESET}"
    printf "  %bman%b    – czytaj podręcznik polecenia\n" "${COLOR_COMMAND}" "${RESET}"
    echo
    press_enter

    CURRENT_LEVEL=3
    save_game
}

run_level_02() {
    level_02_intro
    level_02_spellbook
    level_02_encounter1 || return 1
    if ! player_is_dead; then
        level_02_encounter2 || true
    fi
    if ! player_is_dead; then
        level_02_midpoint
        level_02_encounter3 || true
    fi
    if ! player_is_dead; then
        level_02_encounter4 || true
    fi
    if ! player_is_dead; then
        level_02_complete
    fi
}
