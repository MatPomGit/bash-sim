# bash-life

Interaktywna, terminalowa symulacja 2D **Gry w życie Conwaya** napisana w Bashu.

## Struktura

- `bash_life.sh` — interfejs terminalowy i obsługa wejścia użytkownika.
- `life_engine.sh` — moduł silnika (reguły, plansza, wzorce).

## Uruchomienie

```bash
./bash-life/bash_life.sh
```

## Sterowanie

- `q` — wyjście
- `p` — pauza / wznowienie
- `n` — pojedynczy krok (gdy pauza)
- `r` — losowanie nowej planszy
- `c` — czyszczenie planszy
- `w` — przełączanie krawędzi (`TORUS`/`BORDER`)
- `g` — wstawienie wzorca **glider**
- `b` — wstawienie wzorca **blinker**
- `u` — wstawienie wzorca **pulsar**
- `+` / `-` — zmiana prędkości symulacji
- `h` — przełączanie rozszerzonej pomocy

## Co zostało rozbudowane

- Wydzielenie logiki symulacji do osobnego modułu (`life_engine.sh`).
- Licznik generacji i liczba żywych komórek w pasku statusu.
- Dwa tryby brzegowe: zawijanie (torus) i twarde granice.
- Obsługa wstawiania gotowych wzorców do środka planszy.
