#!/usr/bin/env bash
# ============================================================
# NDP LAB TESTER - z debuggerem, materiałami i indeksem
# Narzedzia dla Programistow
# ============================================================

HISTORY_FILE="/tmp/ndplab_tester_results_$$.txt"
STUDENT_ID=""

# Kolory ANSI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# ------------------------------------------------------------
# MAKSYMALIZACJA OKNA TERMINALA
# ------------------------------------------------------------
maximize_terminal() {
    # Sekwencja escape xterm: maksymalizuj okno (działa w wielu terminalach)
    printf '\e[9;1t' 2>/dev/null
    # Alternatywnie dla gnome-terminal, konsole, itp. – często działa
    sleep 0.2  # krótkie opóźnienie, aby terminal zdążył zareagować
}

# ------------------------------------------------------------
# ANIMOWANE LOGO (mniejsze, stały obszar 9 linii)
# ------------------------------------------------------------
animate_logo() {
    # Logo skrócone do 9 linii (usunięto dwie ramki górną i dolną oraz uproszczono)
    local logo_lines=(
        '   ███╗   ██╗██████╗ ██████╗     ██╗      █████╗ ██████╗'
        '   ████╗  ██║██╔══██╗██╔══██╗    ██║     ██╔══██╗██╔══██╗'
        '   ██╔██╗ ██║██║  ██║██████╔╝    ██║     ███████║██████╔╝'
        '   ██║╚██╗██║██║  ██║██╔══██╗    ██║     ██╔══██║██╔══██╗'
        '   ██║ ╚████║██████╔╝██████╔╝    ███████╗██║  ██║██████╔╝'
        '   ╚═╝  ╚═══╝╚═════╝ ╚═════╝     ╚══════╝╚═╝  ╚═╝╚═════╝'
        '                                                          '
        '               NARZEDZIA DLA PROGRAMISTOW                 '
        '                   INTERAKTYWNY TESTER                    '
    )

    local colors=("$CYAN" "$PURPLE" "$BLUE" "$GREEN" "$YELLOW")
    local color_idx=0
    local logo_height=${#logo_lines[@]}  # = 9

    printf "\033[2J\033[H"

    # Rysowanie linia po linii (efekt pisania)
    for line in "${logo_lines[@]}"; do
        echo -e "${colors[$color_idx]}${line}${NC}"
        color_idx=$(( (color_idx + 1) % ${#colors[@]} ))
        sleep 0.08
    done
    sleep 0.4

    # Pulsowanie (przerysowanie całego logo w różnych kolorach)
    for _ in {1..5}; do
        printf "\033[${logo_height}A"  # przesuń kursor na górę logo
        for line in "${logo_lines[@]}"; do
            echo -e "${colors[$color_idx]}${line}${NC}"
            color_idx=$(( (color_idx + 1) % ${#colors[@]} ))
        done
        sleep 0.25
    done

    # Kursor na dół logo (przesuwamy o logo_height linii w dół)
    printf "\033[${logo_height}B"
}

# ------------------------------------------------------------
# DEFINICJE TESTOW
# ------------------------------------------------------------
test1_name="Podstawy Basha"
test1_questions=(
    "Jakie polecenie wyswietla biezacy katalog roboczy?"
    "Jaki znak sluzy do komentowania w bashu?"
    "Jaka skladnia przypiszesz wartosc 'Jan' do zmiennej imie?"
    "Ktore polecenie sluzy do wyswietlenia zawartosci pliku?"
    "Jak wywolac ostatnio wykonane polecenie?"
)
test1_types=("text" "text" "text" "text" "text")
test1_answers=("pwd" "#" "imie=jan" "cat" "!!")

test2_name="Zaawansowany Bash"
test2_questions=(
    "Jaki zapis w bashu generuje liczby od 1 do 5? (np. {..})"
    "Ktorego operatora uzyjesz w warunku if, aby sprawdzic, czy plik istnieje? (np. -?)"
    "Co robi polecenie 'grep'?"
    "Jaki kod powrotu (exit code) oznacza sukces?"
    "Jak nadac uprawnienia wykonania plikowi skryptu?"
)
test2_types=("text" "text" "text" "text" "text")
test2_answers=("{1..5}" "-f" "wyszukuje tekst" "0" "chmod +x")

test3_name="Tworzenie skryptow"
test3_questions=(
    "Jaki jest shebang dla skryptu bash?"
    "Jak uzyskac dostep do pierwszego argumentu skryptu?"
    "Ktora opcja wlaczona w shebangu lub w linii polecen powoduje debugowanie (wyswietlanie polecen)?"
    "Co robi polecenie 'exit 1' w skrypcie?"
    "Jak przekierowac standardowe wyjscie bledu (stderr) do pliku error.log? (uzyj przekierowania)"
)
test3_types=("text" "text" "text" "text" "text")
test3_answers=("#!/bin/bash" "\$1" "-x" "exit 1" "2> error.log")

test4_name="Debugowanie Basha"
test4_questions=(
    "Ktora opcja wlaczona przy uruchomieniu bash powoduje wyswietlanie kazdego polecenia przed wykonaniem?"
    "Jaka zmienna srodowiskowa kontroluje format prompta debugowania (set -x)?"
    "Ktore polecenie wbudowane sluzy do ustawiania opcji debugowania (wlacz/wylacz)?"
    "Jaki sygnal mozna przechwycic za pomoca trap, aby wykonac funkcje przed kazdym poleceniem?"
    "Ktory program jest zewnetrznym debuggerem dla bash (podobnym do gdb)?"
)
test4_types=("text" "text" "text" "text" "text")
test4_answers=("-x" "ps4" "set" "debug" "bashdb")

declare -A test_ids=(
    ["1"]="test1"
    ["2"]="test2"
    ["3"]="test3"
    ["4"]="test4"
)

# ------------------------------------------------------------
# FUNKCJE POMOCNICZE
# ------------------------------------------------------------
clear_screen() {
    printf "\033[2J\033[H"
}

print_header() {
    local text="$1"
    echo ""
    printf "%s\n" "============================================================"
    printf " %-60s\n" "$text"
    printf "%s\n" "============================================================"
}

wait_for_enter() {
    read -p "Nacisnij Enter, aby kontynuowac..."
}

get_student_id() {
    if [[ -z "$STUDENT_ID" ]]; then
        clear_screen
        display_static_logo
        print_header "IDENTYFIKACJA"
        echo ""
        read -p "Podaj swoj numer indeksu: " STUDENT_ID
        if [[ -z "$STUDENT_ID" ]]; then
            STUDENT_ID="ANONIM"
        fi
        echo -e "${GREEN}Witaj, $STUDENT_ID!${NC}"
        sleep 1
    fi
}

# ------------------------------------------------------------
# MATERIAŁY DYDAKTYCZNE
# ------------------------------------------------------------
show_learning_materials() {
    clear_screen
    display_static_logo
    print_header "MATERIALY DYDAKTYCZNE - NAUKA DO TESTU"
    echo ""
    echo -e "${BOLD}1. PODSTAWY Basha${NC}"
    echo "   - pwd, ls, cd, echo"
    echo "   - Zmienne: nazwa=wartosc, odczyt: \$nazwa"
    echo "   - Komentarze: #"
    echo "   - Powtorka ostatniego polecenia: !! "
    echo ""
    echo -e "${BOLD}2. ZAAWANSOWANY BASH${NC}"
    echo "   - Generowanie sekwencji: {1..10}"
    echo "   - Sprawdzanie plikow: if [ -f plik ]; then ..."
    echo "   - grep - wyszukiwanie"
    echo "   - Kody wyjscia: 0 = sukces"
    echo "   - Uprawnienia: chmod +x"
    echo ""
    echo -e "${BOLD}3. TWORZENIE SKRYPTÓW${NC}"
    echo "   - Shebang: #!/bin/bash"
    echo "   - Argumenty: \$1, \$2, \$#"
    echo "   - Debugowanie: bash -x skrypt.sh lub set -x"
    echo "   - exit 1 - zakonczenie z bledem"
    echo "   - Przekierowanie bledow: 2> error.log"
    echo ""
    echo -e "${BOLD}4. DEBUGOWANIE BASH (BASH Debugger)${NC}"
    echo "   - Uruchomienie z trace: bash -x skrypt"
    echo "   - Wewnatrz skryptu: set -x (wlacz), set +x (wylacz)"
    echo "   - Zmienna PS4 kontroluje prompt w trace (domyslnie '+ ')"
    echo "   - Przechwytywanie sygnalu DEBUG: trap 'polecenie' DEBUG"
    echo "   - Przyklad: trap 'echo \"Wykonuje: \$BASH_COMMAND\"' DEBUG"
    echo "   - Zewnetrzny debugger: bashdb (instalacja: sudo apt install bashdb)"
    echo "   - Uruchomienie bashdb: bashdb skrypt.sh"
    echo ""
    echo -e "${BOLD}PRZYKLADOWY SKRYPT DO DEBUGOWANIA${NC}"
    echo "---"
    echo "#!/bin/bash"
    echo "set -x  # wlaczenie sledzenia"
    echo "zmienna=10"
    echo "for i in {1..3}; do"
    echo "    echo \"Iteracja \$i\""
    echo "    wynik=\$((zmienna * i))"
    echo "done"
    echo "set +x  # wylaczenie"
    echo "---"
    echo ""
    echo -e "${YELLOW}Rada: Uzyj 'bash -x skrypt.sh' aby zobaczyc kazde polecenie.${NC}"
    wait_for_enter
}

# ------------------------------------------------------------
# PRAKTYCZNY DEBUGGER (krok po kroku)
# ------------------------------------------------------------
run_practical_debugger() {
    clear_screen
    display_static_logo
    print_header "PRAKTYCZNY DEBUGGER - KROK PO KROKU"
    echo ""
    echo "Przeanalizujemy dzialanie prostego skryptu z wlaczonym trybem debugowania."
    echo "Naciskaj Enter, aby wykonac kolejne polecenie."
    echo ""

    local tmp_script="/tmp/debug_me_$$.sh"
    cat > "$tmp_script" << 'EOF'
#!/bin/bash
# Prosty skrypt do demonstracji debuggera
zmienna=5
echo "Poczatek"
for i in 1 2 3; do
    wynik=$((zmienna * i))
    echo "$i * $zmienna = $wynik"
done
echo "Koniec"
EOF
    chmod +x "$tmp_script"

    echo -e "${BOLD}Skrypt do debugowania:${NC}"
    echo "----------------------------------------"
    cat "$tmp_script"
    echo "----------------------------------------"
    echo ""
    echo -e "${YELLOW}Uruchomimy go z 'bash -x' aby zobaczyc kazde polecenie:${NC}"
    wait_for_enter

    clear_screen
    display_static_logo
    print_header "TRYB KROKOWY (symulacja debuggera)"
    echo ""
    echo -e "${BOLD}Kazde polecenie zostanie wyswietlone przed wykonaniem.${NC}"
    echo "Naciskaj Enter, aby przejsc dalej."
    echo ""

    local trace_file="/tmp/debug_trace_$.txt"
    bash -x "$tmp_script" >"$trace_file" 2>&1

    local line_num=0
    while IFS= read -r line; do
        ((line_num+=1))
        echo -e "${GREEN}Krok $line_num:${NC} $line"
        read -r -p "Nacisnij Enter, aby przejsc dalej..."
    done < "$trace_file"

    echo -e "${YELLOW}Koniec demonstracji. Trace pochodzi z rzeczywistego uruchomienia bash -x.${NC}"
    rm -f "$tmp_script" "$trace_file"
    wait_for_enter
}

# ------------------------------------------------------------
# PRZEPROWADZANIE TESTU (z zapisem indeksu)
# ------------------------------------------------------------
run_test() {
    local test_id="$1"
    local prefix="${test_ids[$test_id]}"
    local test_name_var="${prefix}_name"
    local questions_var="${prefix}_questions[@]"
    local types_var="${prefix}_types[@]"
    local answers_var="${prefix}_answers[@]"

    local test_name="${!test_name_var}"
    local questions=("${!questions_var}")
    local types=("${!types_var}")
    local answers=("${!answers_var}")

    local total=${#questions[@]}
    local score=0

    # Przed testem upewnij się, że znamy indeks
    get_student_id

    clear_screen
    animate_logo
    print_header "ROZPOCZECIE TESTU: $test_name"
    echo "Indeks: $STUDENT_ID"
    echo "Liczba pytan: $total"
    echo ""

    for (( i=0; i<total; i++ )); do
        local qnum=$((i+1))
        echo -e "${CYAN}Pytanie $qnum/$total: ${questions[$i]}${NC}"

        read -p "Twoja odpowiedz: " user_answer
        user_answer=$(echo "$user_answer" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr '[:upper:]' '[:lower:]')
        local correct_answer="${answers[$i]}"

        if [[ "$user_answer" == "$correct_answer" ]]; then
            echo -e "${GREEN} Poprawnie!${NC}"
            ((score++))
        else
            echo -e "${RED} Bladnie. Poprawna odpowiedz: $correct_answer${NC}"
        fi
        echo ""
        if [[ $i -lt $((total-1)) ]]; then
            sleep 0.8
        fi
    done

    local percent
    percent=$(awk -v score="$score" -v total="$total" 'BEGIN { printf "%.1f", score * 100 / total }')
    print_header "WYNIKI"
    echo "Poprawne odpowiedzi: $score/$total"
    printf "Wynik procentowy: %.1f%%\n" "$percent"
    if (( score * 100 >= 70 * total )); then
        echo -e "${GREEN}Gratulacje! Zdajesz test.${NC}"
    else
        echo -e "${YELLOW}Mozesz jeszcze popracowac. Sprobuj ponownie!${NC}"
    fi
    wait_for_enter

    echo "$(date '+%Y-%m-%d %H:%M:%S') | $STUDENT_ID | $test_name | $score/$total | ${percent}%" >> "$HISTORY_FILE"
}

# ------------------------------------------------------------
# HISTORIA WYNIKÓW
# ------------------------------------------------------------
show_results() {
    clear_screen
    display_static_logo
    print_header "HISTORIA WYNIKOW (biezaca sesja)"

    if [[ ! -f "$HISTORY_FILE" ]] || [[ ! -s "$HISTORY_FILE" ]]; then
        echo -e "\nBrak zapisanych wynikow. Przeprowadz jakis test najpierw."
    else
        printf "\n%-20s %-15s %-35s %-10s %-8s\n" "Data" "Indeks" "Test" "Wynik" "%"
        echo "--------------------------------------------------------------------------------------------"
        while IFS= read -r line; do
            IFS='|' read -r datetime indeks test wynik procent <<< "$line"
            datetime=$(echo "$datetime" | xargs)
            indeks=$(echo "$indeks" | xargs)
            test=$(echo "$test" | xargs)
            wynik=$(echo "$wynik" | xargs)
            procent=$(echo "$procent" | xargs)
            printf "%-20s %-15s %-35s %-10s %-8s\n" "$datetime" "$indeks" "$test" "$wynik" "$procent"
        done < "$HISTORY_FILE"
    fi
    wait_for_enter
}

# ------------------------------------------------------------
# STATYCZNE LOGO (mniejsze)
# ------------------------------------------------------------
display_static_logo() {
    echo -e "${CYAN}"
    echo '   ███╗   ██╗██████╗ ██████╗     ██╗      █████╗ ██████╗'
    echo '   ████╗  ██║██╔══██╗██╔══██╗    ██║     ██╔══██╗██╔══██╗'
    echo '   ██╔██╗ ██║██║  ██║██████╔╝    ██║     ███████║██████╔╝'
    echo '   ██║╚██╗██║██║  ██║██╔══██╗    ██║     ██╔══██║██╔══██╗'
    echo '   ██║ ╚████║██████╔╝██████╔╝    ███████╗██║  ██║██████╔╝'
    echo '   ╚═╝  ╚═══╝╚═════╝ ╚═════╝     ╚══════╝╚═╝  ╚═╝╚═════╝'
    echo '                                                          '
    echo '               NARZEDZIA DLA PROGRAMISTOW                 '
    echo '                   INTERAKTYWNY TESTER                    '
    echo -e "${NC}"
}

# ------------------------------------------------------------
# MENU GŁÓWNE
# ------------------------------------------------------------
display_main_menu() {
    clear_screen
    animate_logo
    print_header "SYSTEM TESTOWY - MENU GLOWNE"
    echo ""
    echo "   Dostepne testy:"
    echo "      1. Podstawy Basha"
    echo "      2. Zaawansowany Bash"
    echo "      3. Tworzenie skryptow"
    echo "      4. Debugowanie Basha (BASH Debugger)"
    echo ""
    echo "      5. Materialy dydaktyczne i nauka do testu"
    echo "      6. Praktyczny debugger (krok po kroku)"
    echo "      7. Pokaz wyniki tej sesji"
    echo "      0. Wyjscie z programu"
    echo ""
    printf "%s\n" "------------------------------------------------------------"
}

# ------------------------------------------------------------
# GŁÓWNA PĘTLA
# ------------------------------------------------------------
main() {
    # Maksymalizacja okna terminala
    maximize_terminal

    rm -f "$HISTORY_FILE"

    # Pobranie indeksu na starcie
    get_student_id

    while true; do
        display_main_menu
        read -p "Wybierz opcje (0-7): " choice
        case "$choice" in
            0)
                clear_screen
                echo "Dziekujemy za korzystanie z NDP LAB Tester. Do widzenia!"
                rm -f "$HISTORY_FILE"
                exit 0
                ;;
            7)
                show_results
                ;;
            5)
                show_learning_materials
                ;;
            6)
                run_practical_debugger
                ;;
            1|2|3|4)
                run_test "$choice"
                ;;
            *)
                echo -e "\n${RED}Nieprawidlowy wybor. Wybierz liczbe od 0 do 7.${NC}"
                sleep 1
                ;;
        esac
    done
}

# ------------------------------------------------------------
# URUCHOMIENIE
# ------------------------------------------------------------
main