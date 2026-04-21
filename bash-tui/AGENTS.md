# AGENTS.md — zasady pracy dla agentów AI (zakres: `bash-tui/`)

## Cel projektu
Tworzymy i rozwijamy prosty, stabilny oraz czytelny program typu TUI w Bashu do monitorowania stanu systemu.

## Wymagania językowe
- **Kod (nazwy zmiennych, funkcji, stałych, plików): w języku angielskim.**
- **Interfejs użytkownika, opisy i komentarze w kodzie: w języku polskim.**

## Standardy implementacyjne
1. Pisz kod modułowo (małe funkcje z jedną odpowiedzialnością).
2. Każda funkcja powinna mieć komentarz po polsku wyjaśniający cel.
3. Używaj bezpiecznych ustawień powłoki: `set -o errexit -o nounset -o pipefail`.
4. Unikaj zewnętrznych zależności, jeśli da się użyć narzędzi standardowych Linux/Bash.
5. Dbaj o poprawne sprzątanie terminala (przywrócenie kursora i trybu ekranu) przez `trap`.
6. Nie pogarszaj czytelności interfejsu — układ powinien być intuicyjny i spójny.
7. Gdy dodajesz funkcje interaktywne (np. instrukcje), zapewnij bezpieczny fallback dla środowisk bez `less`.

## Wersjonowanie
- Wersja ma być automatycznie zwiększana przy każdym commicie.
- Preferowane rozwiązanie: wyliczanie na podstawie liczby commitów Git (`git rev-list --count HEAD`).

## Zgodność platformowa
- Główna implementacja pozostaje w Bash (`system_tui.sh`).
- Dla Windows utrzymuj prosty launcher `.bat` (`system_tui.bat`) uruchamiający skrypt Bash przez Git for Windows.

## Weryfikacja zmian
Przed zakończeniem pracy uruchom co najmniej:
```bash
bash -n bash-tui/system_tui.sh
TERM=xterm bash-tui/system_tui.sh --snapshot
bash-tui/system_tui.sh --list-instructions
```

## Czego nie robić
- Nie mieszaj języków wbrew zasadom (np. polskie nazwy zmiennych).
- Nie dodawaj ciężkich frameworków TUI.
- Nie usuwaj informacji o autorach.
