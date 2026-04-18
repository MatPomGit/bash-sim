# bash-life

Interaktywny program terminalowy w Bashu symulujący 2D **Grę w życie Conwaya**.

## Uruchomienie

```bash
./bash-life/bash_life.sh
```

## Sterowanie

- `q` — wyjście z programu
- `p` — pauza / wznowienie
- `n` — pojedynczy krok (gdy pauza)
- `r` — ponowne losowanie planszy
- `c` — wyczyszczenie planszy
- `+` / `-` — zwiększanie / zmniejszanie szybkości symulacji

## Szczegóły implementacyjne

- Plansza dopasowuje się do aktualnego rozmiaru terminala.
- Ostatni wiersz jest paskiem statusu.
- Krawędzie planszy są zawijane (topologia torusa).
- Żywe komórki są rysowane znakiem `█`.
