# bash-tui

Interaktywny terminalowy interfejs użytkownika (TUI) napisany w Bashu, pokazujący najważniejsze informacje systemowe.

## Funkcje
- Tryb pełnoekranowy (alt-screen + próba maksymalizacji okna terminala przy starcie).
- Czytelny panel z metrykami: CPU, RAM, dysk `/`, uptime, load average, host, kernel, IP.
- Informacja o wersji automatycznie zwiększana przy każdym commicie (na podstawie `git rev-list --count HEAD`).
- Informacja o autorach: **KIA, Katedra Informatyki i Automatyki, Politechnika Rzeszowska**.
- Sterowanie klawiaturą: `q` (wyjście), `r` (natychmiastowe odświeżenie).

## Uruchomienie
```bash
cd bash-tui
./system_tui.sh
```

## Tryb jednorazowy (snapshot)
Przydatny do testów CI lub szybkiego podglądu bez wejścia w pętlę interaktywną:

```bash
./system_tui.sh --snapshot
```
