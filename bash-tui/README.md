# bash-tui

Interaktywny terminalowy interfejs użytkownika (TUI) napisany w Bashu, pokazujący najważniejsze informacje systemowe.

## Funkcje
- Rozbudowana kolorystyka z progami stanu (zielony/żółty/czerwony) dla najważniejszych metryk.
- Tryb pełnoekranowy (alt-screen + próba maksymalizacji okna terminala przy starcie).
- Czytelny panel z metrykami: CPU, RAM, SWAP, dyski (`/`, `/home`), uptime, load average, host, kernel, IP, procesy, użytkownicy, ruch sieciowy, temperatura CPU, liczba aktywnych połączeń TCP oraz proces o największym użyciu CPU.
- Informacja o wersji automatycznie zwiększana przy każdym commicie (na podstawie `git rev-list --count HEAD`).
- Informacja o autorach: **KIA, Katedra Informatyki i Automatyki, Politechnika Rzeszowska**.
- Sterowanie klawiaturą: strzałki `←/→` (nawigacja po polach akcji), strzałki `↑/↓` (przejście do listy materiałów i wybór pliku), `Enter` (aktywacja zaznaczonego pola/pliku), `q` (powrót/wyjście), `r` (natychmiastowe odświeżenie), `+`/`-` (zmiana częstotliwości odświeżania).
- Częstotliwość odświeżania ograniczona do poziomów: `0.2Hz`, `0.5Hz`, `1Hz`, `2Hz`, `3Hz`, `4Hz`, `5Hz`, `10Hz`.
- Moduły instrukcji laboratoryjnych 1–6 na osobnych stronach, ładowane z plików Markdown `materials/lab_01.md` ... `materials/lab_06.md`.
- Sekcja materiałów w interfejsie: automatyczne wykrywanie plików instrukcji i dodatkowych plików tekstowych (`*.txt`) z katalogu `materials/` i podgląd przez `less` (z fallbackiem bez `less`).

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

## Katalog materiałów
Pliki do podglądu umieszczaj w katalogu:

```bash
bash-tui/materials/
```
