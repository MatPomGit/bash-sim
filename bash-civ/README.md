# bash-civ

Eksperymentalna symulacja rozwoju cywilizacji. Repozytorium zawiera dwie warstwy projektu:

- `index.html` — prosty wariant przeglądarkowy,
- `wersja1/` — terminalowa gra turowa napisana w Pythonie.

## Wersja terminalowa

Wymagania:

- Python 3.8 lub nowszy,
- terminal z obsługą ANSI.

Uruchomienie:

```bash
cd bash-civ/wersja1
python3 main.py
```

Rozgrywka obejmuje generowanie mapy, miasta, populację, surowce, technologie, zdarzenia losowe oraz opcjonalną automatyzację decyzji.

## Struktura

- `main.py` — punkt wejścia,
- `game.py` — przebieg gry i tury,
- `civilization.py` — stan i logika cywilizacji,
- `city.py` — model miasta,
- `terrain.py` — typy terenu,
- `map_generator.py` — generator mapy,
- `automation.py` — automatyczne decyzje,
- `ui.py` — terminalowy interfejs użytkownika.

Projekt ma charakter dydaktyczny i eksperymentalny.
