# bash-tui

Interaktywny terminalowy interfejs użytkownika (TUI) napisany w Bashu, pokazujący najważniejsze informacje systemowe.

## Funkcje
- Rozbudowana kolorystyka z progami stanu (zielony/żółty/czerwony) dla najważniejszych metryk.
- Tryb pełnoekranowy (alt-screen + próba maksymalizacji okna terminala przy starcie).
- Czytelny panel z metrykami: CPU, RAM, SWAP, dyski (`/`, `/home`), uptime, load average, host, kernel, IP, procesy, użytkownicy, ruch sieciowy oraz proces o największym użyciu CPU.
- Informacja o wersji automatycznie zwiększana przy każdym commicie (na podstawie `git rev-list --count HEAD`).
- Informacja o autorach: **KIA, Katedra Informatyki i Automatyki, Politechnika Rzeszowska**.
- Sterowanie klawiaturą: `q` (wyjście), `r` (natychmiastowe odświeżenie), `h` (interaktywne instrukcje).
- Interaktywne instrukcje: wybór i podgląd plików tekstowych (`*.md`, `*.txt`) przez wbudowany wybór i `less`.

## Uruchomienie (Linux / macOS / WSL)
```bash
cd bash-tui
./system_tui.sh
```

## Uruchomienie (Windows)
```bat
cd bash-tui
system_tui.bat
```

## Tryby pomocnicze
Tryb jednorazowy (snapshot), przydatny do testów CI:

```bash
./system_tui.sh --snapshot
```

Lista wykrytych plików instrukcji:

```bash
./system_tui.sh --list-instructions
```
