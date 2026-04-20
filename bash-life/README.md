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
- `t` — wstawienie wzorca **toad**
- `l` — wstawienie wzorca **LWSS** (lekki statek kosmiczny)
- `a` — automatyczne zatrzymanie po wykryciu stabilizacji
- `+` / `-` — zmiana prędkości symulacji
- `h` — przełączanie rozszerzonej pomocy

## Parametry początkowe symulacji

Możesz uruchomić symulację z własnymi ustawieniami startowymi:

```bash
./bash-life/bash_life.sh \
  --width 80 \
  --height 30 \
  --density 18 \
  --delay 0.08 \
  --wrap torus \
  --paused \
  --pattern glider
```

Dostępne opcje:

- `--width N` — szerokość planszy (min. 20)
- `--height N` — wysokość planszy (min. 8)
- `--density N` — procent żywych komórek na starcie (0-100)
- `--delay X` — opóźnienie między krokami w sekundach
- `--wrap torus|border` — tryb krawędzi planszy
- `--paused` — start w trybie pauzy
- `--pattern glider|blinker|pulsar|toad|lwss` — gotowy wzorzec na starcie
- `--help` — pomoc parametrów

## Co zostało rozbudowane

- Wydzielenie logiki symulacji do osobnego modułu (`life_engine.sh`).
- Licznik generacji i liczba żywych komórek w pasku statusu.
- Dwa tryby brzegowe: zawijanie (torus) i twarde granice.
- Obsługa wstawiania gotowych wzorców do środka planszy.
- Konfigurowalne parametry startowe z linii poleceń.
- Automatyczne pauzowanie po wykryciu stabilizacji planszy.


## Uruchomienie na Windows

Aby uruchomić wersję terminalową z poziomu Windows, użyj:

```bat
start.bat
```

## Uruchomienie w przeglądarce

W katalogu `bash-life` znajduje się plik `index.html` z webową wersją symulacji.

Najprościej:

1. Otwórz `bash-life/index.html` w przeglądarce.
2. Użyj przycisków lub skrótów klawiszowych widocznych pod planszą.
