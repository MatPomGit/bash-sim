# Pokémon: Bash Red

Wersja 1.0.0

Gra terminalowa w Bashu, inspirowana Pokémon Red. Wybierz startera, łap Pokémony,
rozwijaj drużynę i zdobądź tytuł mistrza Kanto. Wymaga Bash 4.0 lub nowszego.
Nie wymaga ROM-u, emulatora, Pythona ani pobierania zasobów.

## Uruchomienie

Z głównego katalogu repozytorium:

```bash
bash bash-pokemon/bash_pokemon.sh
```

Windows: uruchom tę komendę w Git Bash lub WSL. macOS: użyj Bash 4+ zamiast
systemowego Bash 3.2.

Przy pierwszym uruchomieniu wybierz Bulbasaura, Charmandera albo Squirtle'a.
Kolejne uruchomienie automatycznie wczyta postęp.

## Sterowanie

Wpisz komendę i naciśnij Enter.

| Komenda | Działanie |
| --- | --- |
| `w`, `a`, `s`, `d` | Ruch po mapie |
| `e` | Akcja na bieżącym polu |
| `p` | Pokaż drużynę i wybierz aktywnego Pokémona |
| `r` | Wypuść Pokémona po potwierdzeniu |
| `h` | Pomoc |
| `q` | Zapisz i zakończ |

| Pole | Znaczenie |
| --- | --- |
| `@` | Gracz |
| `:` | Trawa, szansa na dzikiego Pokémona |
| `C` | Centrum Pokémon, bezpłatne leczenie przez `e` |
| `S` | Sklep, kupowanie kul i mikstur przez `e` |
| `G` | Laboratorium, sala lub Liga, wejście przez `e` |
| `<`, `>` | Przejście do sąsiedniego miasta |
| `#` | Przeszkoda |

Centrum startowe znajduje się pod graczem. Do pierwszego miasta idź w prawo.
Trawa jest poniżej głównej drogi. Sala znajduje się nad nią, w kolumnie 11.
Po każdej odznace otwiera się przejście do kolejnego miasta.

## Walki i rozwój

- `1`: atak normalny, `2`: silniejszy atak typu Pokémona
- `3`: rzut kulą, dostępny tylko w dzikiej walce
- `4`: mikstura, przywraca do 50 HP aktywnego Pokémona
- `5`: zmiana aktywnego Pokémona, `6`: próba ucieczki z dzikiej walki

Osłabiony Pokémon ma większą szansę złapania (20–80%). Drużyna mieści sześć
Pokémonów. Przy pełnej drużynie wypuść jednego poza walką, aby zrobić miejsce.
Zmiana, mikstura, nieudana ucieczka i nieudany rzut kulą zużywają turę.
Niedostępna akcja ani błędny wybór nie zużywają tury.

Pokonany przeciwnik daje doświadczenie i pieniądze. Awans podnosi HP, a wybrane
gatunki ewoluują na określonym poziomie. Omdlenie całej drużyny przenosi do
Centrum i zabiera połowę pieniędzy. Można trenować na wcześniejszych trasach.

Droga do mistrzostwa: Brock, Misty, Lt. Surge, Erika, Koga, Sabrina, Blaine,
Giovanni, następnie Liga na Indigo Plateau. Liga obejmuje pięć kolejnych
zespołów. W trakcie wyzwania nie można korzystać z Centrum, ale można używać
mikstur. Po zdobyciu mistrzostwa w trawie płaskowyżu może pojawić się Mewtwo.

## Zapis

Domyślny plik to `${XDG_DATA_HOME:-$HOME/.local/share}/bash-pokemon/save.dat`.
Gra zapisuje stan po komendach na mapie i przy zwykłym zakończeniu, także po
końcu wejścia (EOF). Nie zapisuje stanu przeciwnika ani etapu rozpoczętej Ligi.
Przerwanie procesu przez Ctrl+C nie zapisuje trwającej walki.

```bash
bash bash-pokemon/bash_pokemon.sh --new       # nowa gra, potwierdzenie nadpisania
bash bash-pokemon/bash_pokemon.sh --load      # wymagaj istniejącego zapisu
bash bash-pokemon/bash_pokemon.sh --save ./moja-gra.dat
bash bash-pokemon/bash_pokemon.sh --help
```

Ścieżkę można też ustawić zmienną `BASH_POKEMON_SAVE`. Gra odrzuca błędny zapis
bez jego nadpisywania. Plik zawiera dane tekstowe, nigdy polecenia Bash.
Zapis jest zastępowany atomowo i ma uprawnienia dostępne tylko właścicielowi.
Używaj osobnego pliku zapisu dla każdej równoczesnej rozgrywki.

## Zakres adaptacji

Wersja zawiera 76 gatunków, trzy startery, ewolucje poziomowe, pojedyncze typy,
uproszczone zależności typów, dziesięć obszarów i ośmiu liderów. Mapy, dialogi,
statystyki i zespoły są skrócone i opracowane dla terminala. To adaptacja
mechaniki pierwszej generacji, a nie pełne odwzorowanie oryginalnej gry.

Nie ma wszystkich 151 gatunków, oryginalnej fabuły i map, PC, wymiany,
ewolucji kamieniami, podwójnych typów, PP, statusów, TM/HM ani dźwięku.
Kolejny etap: zróżnicowane mapy i fabuła z rywalem, następnie PC oraz ruchy z PP.

## Weryfikacja

```bash
bash -n bash-pokemon/bash_pokemon.sh
bash bash-pokemon/tests/run_tests.sh
```

Testy używają katalogu tymczasowego. Sprawdzają walki, ewolucje, odznaki,
przejścia, Ligę i odrzucanie niepoprawnych zapisów. Nie uruchamiają Actions.
