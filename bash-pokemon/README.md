# Pokémon: Bash Red

Wersja 1.3.0

Terminalowa adaptacja Pokémon Red w Bashu: podróż od laboratorium Oaka do Sali
Sławy, osiem spotkań z Blue, Team Rocket, osiem sal i epilog w Cerulean Cave.
Zawiera 54 połączone lokacje, 43 wydarzenia oraz dane 151 gatunków pierwszej
generacji. Wymaga Bash 4.4 lub nowszego. Nie wymaga ROM-u ani emulatora.

## Uruchomienie

Z głównego katalogu repozytorium:

```bash
bash bash-pokemon/bash_pokemon.sh
```

Windows: Git Bash lub WSL. macOS: użyj aktualnego Bash zamiast systemowego
Bash 3.2. Gra działa lokalnie, bez usług sieciowych i kluczy API.

Wybierz startera. Zaczynasz na polu wydarzenia w laboratorium. Naciśnij `e`,
wybierz pierwsze wydarzenie, a następnie potwierdź `t`. Do sąsiednich lokacji
przechodzisz przez `<` albo `>` i wybierasz drogę z listy. Następne uruchomienie
wczyta zapis automatycznie.

## Jeden plik do pobrania

Plik [`pokemon-red.sh`](pokemon-red.sh) zawiera cały kod, fabułę i dane gry.
Wystarczy skopiować go do dowolnego katalogu i uruchomić:

```bash
bash pokemon-red.sh
```

Nie potrzebuje pozostałych plików repozytorium, Pythona ani rozpakowywania
archiwum. Moduły i dane są osadzone w skrypcie i wczytywane do zmiennych Bash.
Na dysku gra tworzy zapis postępu, korzystając ze standardowych narzędzi
systemowych. Wymaga Bash 4.4+, na Windows dostępnego w Git Bash lub WSL.
Obsługuje te same opcje i zapisy co wersja modułowa.

ZIP nadaje się do przesyłania plików, ale jego otwarcie nie uruchamia gry
przenośnie na różnych systemach. Dystrybucją gry jest pojedynczy plik `.sh`.

Dla programisty źródłem pozostają moduły. Po ich zmianie odtwórz plik:

```bash
python3 bash-pokemon/tools/build_standalone.py
python3 bash-pokemon/tools/build_standalone.py --check
```

Generator używa wyłącznie biblioteki standardowej Python 3.10+. Wygenerowana
gra działa bez Pythona. `--check` wykrywa nieaktualny plik dystrybucyjny.

## Oprawa terminalowa

Interfejs retro ma kolorowe mapy, odrębne oznaczenia budynków i postaci,
ramki dialogów, widoczne odznaki oraz paski HP. Zielony, żółty i czerwony
pasek pokazuje poziom zdrowia. Ekran walki zawiera małe pixelowe sylwetki:
osobne projekty starterów, Pikachu i Mewtwo, a dla pozostałych gatunków
sylwetki według typu. Nazwa, poziom i HP zawsze odpowiadają faktycznemu gatunkowi.

Standardowy ekran mapy i walki mieści się w 80×24. W węższych terminalach
mapa używa jednej kolumny na pole, tekst się zawija, a ekran walki pomija
sylwetki. Zalecane minimum szerokości: 24 kolumny; większe okno poprawia czytelność.
Rozmiar jest odczytywany przy uruchomieniu. Nie wymaga fontów ikonowych
ani pakietów do obsługi terminala.

```bash
bash pokemon-red.sh                  # automatyczne kolory w terminalu
bash pokemon-red.sh --ascii          # zwykłe znaki zamiast ramek Unicode
bash pokemon-red.sh --no-color       # bez kolorów
bash pokemon-red.sh --plain          # prosty tekst bez sekwencji sterujących
bash pokemon-red.sh --color=always   # wymuś kolory, także w przekierowanym wyjściu
```

Zmienna `NO_COLOR` wyłącza kolory. Przy przekierowaniu wyjścia do pliku oraz
w terminalu `dumb` domyślnie używany jest zwykły tekst. Można też ustawić
`BASH_POKEMON_COLOR=auto|always|never`, `BASH_POKEMON_ASCII=1` lub
`BASH_POKEMON_STYLE=plain`. Ustawienia wyglądu nie zmieniają formatu zapisów.

## Sterowanie

Wpisz komendę i naciśnij Enter.

| Komenda | Działanie |
| --- | --- |
| `w`, `a`, `s`, `d` | Ruch po lokalnej mapie |
| `e` | Rozmowa lub akcja na bieżącym polu |
| `j` | Dziennik, lokalizacja zadań i wymagania |
| `i` | Plecak, pieniądze, kule, mikstury i kluczowe przedmioty |
| `m` | Lista lokacji Kanto |
| `k` | Pokédex, zarejestrowane gatunki |
| `p` | Drużyna, wybór aktywnego Pokémona |
| `r` | Wypuszczenie Pokémona po potwierdzeniu |
| `f` | Fly do odwiedzonych miast, wymaga HM02 i odznaki Surge |
| `h` | Pomoc |
| `q` | Zapisz i zakończ |

| Pole | Akcja przez `e` |
| --- | --- |
| `N` | Wydarzenia fabularne i rozmowy |
| `G` | Sala, dojo lub Liga; w Pallet laboratorium |
| `C` | Bezpłatne leczenie i ustawienie Centrum powrotu po omdleniu |
| `P` | PC, do 300 Pokémonów poza drużyną |
| `S` | Sklep, mikstury, kule, kamienie i wymiany ewolucyjne |
| `T` | Powtarzalna walka treningowa |
| `:` | Losowe spotkania podczas ruchu |
| `~` | Woda, wymaga Surf i odznaki Kogi |
| `<`, `>` | Wybór drogi do sąsiedniej lokacji |
| `#` | Przeszkoda |

Pola `N` są w centralnym korytarzu. Sale są nad nim. Centrum i sklep znajdują się
w miastach. Możesz wracać do wcześniejszych lokacji i trenować drużynę.

## Kampania

Poniższa tabela zawiera przebieg historii i nagrody. Dziennik w grze pokazuje,
które etapy są już zakończone i które można rozpocząć.

| Etap | Wydarzenia i wynik |
| --- | --- |
| Pallet i Viridian | Starter, pierwszy pojedynek z Blue, przesyłka dla Oaka, Pokédex, lekcja łapania |
| Viridian Forest i Pewter | Trenerzy owadów, Brock, otwarcie drogi do Mt. Moon |
| Mt. Moon | Rockets, badacz i wybór Helix albo Dome Fossil |
| Cerulean i Route 24–25 | Blue, Nugget Bridge, pomoc Billowi, bilet na statek, Rocket za okradzionym domem, Misty |
| Vermilion i S.S. Anne | Fan Club, voucher na rower, Blue na statku, pomoc kapitanowi, Cut, Lt. Surge; statek odpływa |
| Rock Tunnel i Lavender | Przejście tunelu, Blue na drugim piętrze wieży, nierozpoznany duch |
| Celadon | Erika, świeża woda dla strażników, plakat i kryjówka Rocket, Lift Key, Giovanni i Silph Scope |
| Pokemon Tower | Uspokojenie ducha matki Cubone, Rockets, uwolnienie Fuji, Poké Flute |
| Szlaki do Fuchsia | Dwa Snorlaxy, wschodnia droga albo Cycling Road; rower z Cerulean potrzebny na Cycling Road |
| Safari i Fuchsia | Secret House, Surf, Gold Teeth, strażnik i Strength, Koga |
| Saffron i Silph Co. | Bramy otwierane napojem, Card Key, Blue, Lapras, Giovanni, Master Ball, Sabrina |
| Cinnabar | Dzienniki badań Mew/Mewtwo w Mansion, Secret Key, Blaine, odtwarzanie skamielin |
| Viridian i Victory Road | Siedem odznak otwiera salę Giovanniego; ósma odznaka, Blue na Route 22, bramki Route 23, głazy Victory Road |
| Indigo Plateau | Lorelei, Bruno, Agatha, Lance, Blue jako mistrz, gratulacje Oaka i Sala Sławy |
| Epilog | Cerulean Cave i Mewtwo na poziomie 70; dalsza eksploracja i Pokédex |

Opcjonalne wydarzenia obejmują wczesne spotkanie z Blue na Route 22, Flash za
10 gatunków w Pokédexie, Fly, Eevee, dojo z wyborem Hitmonlee/Hitmonchan,
Old Amber i Aerodactyla oraz Articuno, Zapdosa i Moltresa. Legendarne ptaki mają
poziom 50. Moltres znajduje się w Victory Road.

Odznaki są niezależne: po otwarciu odpowiednich dróg można zmieniać kolejność
środkowych sal. Przegrana w pierwszej walce z Blue nie blokuje fabuły. Przegrana
w pozostałych wyzwaniach nie przyznaje odznaki ani nagrody. Ucieczka od Snorlaxa
nie otwiera drogi. Zakończone zadania nie wydają nagród ponownie.

## Walki i kolekcja

| Wybór w walce | Akcja |
| --- | --- |
| `1` | Atak normalny |
| `2` | Atak pierwszego typu |
| `7` | Atak drugiego typu, jeśli gatunek go ma |
| `3` | Poké Ball |
| `8` | Master Ball, jedna sztuka za uratowanie Silph |
| `4` | Mikstura, do 50 HP |
| `5` | Zmiana aktywnego Pokémona |
| `6` | Próba ucieczki z dzikiej walki |

Osłabienie zwiększa szansę złapania. Złapany Pokémon trafia do drużyny albo do
PC, gdy drużyna ma sześciu członków. Zmiana, mikstura i nieudana próba ucieczki
lub złapania zużywają turę. Niedostępna akcja nie zużywa tury. Pokémonów trenera
oraz ducha w wieży nie można łapać.

Zwycięstwa dają doświadczenie i pieniądze. Ewolucje poziomowe następują przy
awansie. W sklepie wybierz ewolucję kamieniem (300 monet) albo wymianę
(bez opłaty), zależnie od gatunku. Eevee ma trzy ewolucje pierwszej generacji.
Pokédex zachowuje wpisy po ewolucji i wypuszczeniu Pokémona.

Omdlenie całej drużyny zabiera połowę pieniędzy i przenosi do ostatniego
odwiedzonego Centrum. Liga wymaga przygotowania zapasu mikstur: pomiędzy
jej pięcioma zespołami nie ma dostępu do Centrum ani PC. Przegrana lub wyjście
z rozpoczętej Ligi oznacza powtórzenie wyzwania od Lorelei.

## Zapis i migracja

Domyślnie: `${XDG_DATA_HOME:-$HOME/.local/share}/bash-pokemon/save.dat`.
Stan drużyny, PC, odznak, dziennika, Pokédexu i przedmiotów zapisuje się po
komendzie na mapie i zakończeniu wydarzenia. `q` oraz EOF zapisują grę.
Ctrl+C nie zapisuje aktualnej walki. Stan przeciwnika i rozpoczętej Ligi nie
jest zapisywany.

```bash
bash bash-pokemon/bash_pokemon.sh --new
bash bash-pokemon/bash_pokemon.sh --load
bash bash-pokemon/bash_pokemon.sh --save ./moja-gra.dat
bash bash-pokemon/bash_pokemon.sh --help
```

`--new` wymaga potwierdzenia zastąpienia istniejącego zapisu. Ścieżkę można też
ustawić zmienną `BASH_POKEMON_SAVE`. Używaj osobnego pliku dla równoczesnych gier.
Zapis jest walidowany jako dane, nigdy wykonywany jako kod. Błędny plik pozostaje
nienaruszony. Zastąpienie pliku jest atomowe, z uprawnieniami tylko dla właściciela.

Zapis wersji 1.0 jest importowany: gatunki otrzymują prawidłowe numery Pokédexu,
drużyna, pieniądze i odznaki pozostają zachowane. Nowa fabuła zaczyna się u Oaka
w Pallet. Następny zapis używa formatu 2. Przed importem możesz zachować kopię
starego pliku, jeśli chcesz wrócić do wersji 1.0.

## Zakres i dalsze prace

Główny wątek od Oaka do Sali Sławy oraz epilog są grywalne. Mapy są kompaktowymi
planszami terminalowymi. Piętra i zagadki budynków są reprezentowane przez
kolejne wydarzenia, z własnymi polskimi dialogami. Flash rozjaśnia tunel w opisie;
HM-y i odznaki otwierają drogi bez przypisywania HM do konkretnego Pokémona.

Pozostałe różnice względem pełnej mechaniki Game Boy: uproszczone statystyki,
ataki oparte na typach zamiast pełnych list ruchów, brak PP, statusów, TM,
oryginalnej grafiki i dźwięku, limity Safari i minigry Game Corner pominięte.
PC i wymiany ewolucyjne działają lokalnie. Katalog obejmuje 151 gatunków; Mew
nie ma zwykłego wydarzenia fabularnego, podobnie jak w oryginalnym Red.

Do wiernego odtworzenia pozostałych mechanik przewidziane są jeszcze 3–5
większych etapów: ruchy i statystyki, statusy i AI, rozbudowane wielopiętrowe mapy
oraz pozostałe aktywności i wymiany. Nie ma planu wdrażania backendu.

## Struktura i weryfikacja

- `bash_pokemon.sh`: uruchomienie, UI i silnik walki
- `lib/world.sh`: lokacje, mapy i połączenia
- `lib/story.sh`: wydarzenia, rywal, sale i Liga
- `lib/collection.sh`: drużyna, PC, ewolucje i przedmioty
- `lib/save.sh`: walidacja, zapis i migracja
- `lib/ui.sh`: kolory, mapy, ramki, paski HP i sylwetki
- `data/species.tsv`: numery Pokédexu, typy i ewolucje 151 gatunków
- `data/legacy_ids.tsv`: mapowanie gatunków z zapisu 1.0
- `pokemon-red.sh`: gotowa dystrybucja w jednym pliku
- `tools/build_standalone.py`: generator dystrybucji
- `tests/run_tests.sh`: testy lokalne

```bash
bash -n bash-pokemon/bash_pokemon.sh
bash bash-pokemon/tests/run_tests.sh
python3 bash-pokemon/tests/test_standalone.py
python3 bash-pokemon/tests/test_ui.py
```

Dane gatunków i warunki fabularne sprawdzono w referencyjnej rekonstrukcji
[pret/pokered, commit 171e2c2](https://github.com/pret/pokered/tree/171e2c204f9c1ff8e577ca387a4bbb009e130843),
w `data/pokemon/evos_moves.asm`, `data/pokemon/base_stats/`,
`constants/pokedex_constants.asm` oraz skryptach lokacji. Gra nie pobiera ani
nie dołącza ROM-u, skryptów czy zasobów tej rekonstrukcji.
