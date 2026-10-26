#!/usr/bin/env bash
# Single-file distribution. Rebuild with tools/build_standalone.py.
# Pokémon: Bash Red 1.2.0. Bash 4.4+, no external game runtime.
if (( BASH_VERSINFO[0] < 4 || BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 4 )); then
    printf 'Wymagany Bash 4.4 lub nowszy\n' >&2
    exit 1
fi

VERSION=1.2.0
declare -a names types types2 evolutions evolve_at map
while IFS=$'\t' read -r id name type second evolution condition; do
    names[id]=$name types[id]=$type types2[id]=$second evolutions[id]=$evolution evolve_at[id]=$condition
done <<'POKEBASH_SPECIES_TSV'
1	Bulbasaur	grass	poison	2	16
2	Ivysaur	grass	poison	3	32
3	Venusaur	grass	poison	0	-
4	Charmander	fire	-	5	16
5	Charmeleon	fire	-	6	36
6	Charizard	fire	flying	0	-
7	Squirtle	water	-	8	16
8	Wartortle	water	-	9	36
9	Blastoise	water	-	0	-
10	Caterpie	bug	-	11	7
11	Metapod	bug	-	12	10
12	Butterfree	bug	flying	0	-
13	Weedle	bug	poison	14	7
14	Kakuna	bug	poison	15	10
15	Beedrill	bug	poison	0	-
16	Pidgey	normal	flying	17	18
17	Pidgeotto	normal	flying	18	36
18	Pidgeot	normal	flying	0	-
19	Rattata	normal	-	20	20
20	Raticate	normal	-	0	-
21	Spearow	normal	flying	22	20
22	Fearow	normal	flying	0	-
23	Ekans	poison	-	24	22
24	Arbok	poison	-	0	-
25	Pikachu	electric	-	26	stone:thunder
26	Raichu	electric	-	0	-
27	Sandshrew	ground	-	28	22
28	Sandslash	ground	-	0	-
29	Nidoran-F	poison	-	30	16
30	Nidorina	poison	-	31	stone:moon
31	Nidoqueen	poison	ground	0	-
32	Nidoran-M	poison	-	33	16
33	Nidorino	poison	-	34	stone:moon
34	Nidoking	poison	ground	0	-
35	Clefairy	normal	-	36	stone:moon
36	Clefable	normal	-	0	-
37	Vulpix	fire	-	38	stone:fire
38	Ninetales	fire	-	0	-
39	Jigglypuff	normal	-	40	stone:moon
40	Wigglytuff	normal	-	0	-
41	Zubat	poison	flying	42	22
42	Golbat	poison	flying	0	-
43	Oddish	grass	poison	44	21
44	Gloom	grass	poison	45	stone:leaf
45	Vileplume	grass	poison	0	-
46	Paras	bug	grass	47	24
47	Parasect	bug	grass	0	-
48	Venonat	bug	poison	49	31
49	Venomoth	bug	poison	0	-
50	Diglett	ground	-	51	26
51	Dugtrio	ground	-	0	-
52	Meowth	normal	-	53	28
53	Persian	normal	-	0	-
54	Psyduck	water	-	55	33
55	Golduck	water	-	0	-
56	Mankey	fighting	-	57	28
57	Primeape	fighting	-	0	-
58	Growlithe	fire	-	59	stone:fire
59	Arcanine	fire	-	0	-
60	Poliwag	water	-	61	25
61	Poliwhirl	water	-	62	stone:water
62	Poliwrath	water	fighting	0	-
63	Abra	psychic	-	64	16
64	Kadabra	psychic	-	65	trade
65	Alakazam	psychic	-	0	-
66	Machop	fighting	-	67	28
67	Machoke	fighting	-	68	trade
68	Machamp	fighting	-	0	-
69	Bellsprout	grass	poison	70	21
70	Weepinbell	grass	poison	71	stone:leaf
71	Victreebel	grass	poison	0	-
72	Tentacool	water	poison	73	30
73	Tentacruel	water	poison	0	-
74	Geodude	rock	ground	75	25
75	Graveler	rock	ground	76	trade
76	Golem	rock	ground	0	-
77	Ponyta	fire	-	78	40
78	Rapidash	fire	-	0	-
79	Slowpoke	water	psychic	80	37
80	Slowbro	water	psychic	0	-
81	Magnemite	electric	-	82	30
82	Magneton	electric	-	0	-
83	Farfetchd	normal	flying	0	-
84	Doduo	normal	flying	85	31
85	Dodrio	normal	flying	0	-
86	Seel	water	-	87	34
87	Dewgong	water	ice	0	-
88	Grimer	poison	-	89	38
89	Muk	poison	-	0	-
90	Shellder	water	-	91	stone:water
91	Cloyster	water	ice	0	-
92	Gastly	ghost	poison	93	25
93	Haunter	ghost	poison	94	trade
94	Gengar	ghost	poison	0	-
95	Onix	rock	ground	0	-
96	Drowzee	psychic	-	97	26
97	Hypno	psychic	-	0	-
98	Krabby	water	-	99	28
99	Kingler	water	-	0	-
100	Voltorb	electric	-	101	30
101	Electrode	electric	-	0	-
102	Exeggcute	grass	psychic	103	stone:leaf
103	Exeggutor	grass	psychic	0	-
104	Cubone	ground	-	105	28
105	Marowak	ground	-	0	-
106	Hitmonlee	fighting	-	0	-
107	Hitmonchan	fighting	-	0	-
108	Lickitung	normal	-	0	-
109	Koffing	poison	-	110	35
110	Weezing	poison	-	0	-
111	Rhyhorn	ground	rock	112	42
112	Rhydon	ground	rock	0	-
113	Chansey	normal	-	0	-
114	Tangela	grass	-	0	-
115	Kangaskhan	normal	-	0	-
116	Horsea	water	-	117	32
117	Seadra	water	-	0	-
118	Goldeen	water	-	119	33
119	Seaking	water	-	0	-
120	Staryu	water	-	121	stone:water
121	Starmie	water	psychic	0	-
122	Mr.Mime	psychic	-	0	-
123	Scyther	bug	flying	0	-
124	Jynx	ice	psychic	0	-
125	Electabuzz	electric	-	0	-
126	Magmar	fire	-	0	-
127	Pinsir	bug	-	0	-
128	Tauros	normal	-	0	-
129	Magikarp	water	-	130	20
130	Gyarados	water	flying	0	-
131	Lapras	water	ice	0	-
132	Ditto	normal	-	0	-
133	Eevee	normal	-	0	eevee
134	Vaporeon	water	-	0	-
135	Jolteon	electric	-	0	-
136	Flareon	fire	-	0	-
137	Porygon	normal	-	0	-
138	Omanyte	rock	water	139	40
139	Omastar	rock	water	0	-
140	Kabuto	rock	water	141	40
141	Kabutops	rock	water	0	-
142	Aerodactyl	rock	flying	0	-
143	Snorlax	normal	-	0	-
144	Articuno	ice	flying	0	-
145	Zapdos	electric	flying	0	-
146	Moltres	fire	flying	0	-
147	Dratini	dragon	-	148	30
148	Dragonair	dragon	-	149	55
149	Dragonite	dragon	flying	0	-
150	Mewtwo	psychic	-	0	-
151	Mew	psychic	-	0	-
POKEBASH_SPECIES_TSV
unset id name type second evolution condition
# Embedded module: world
# World graph. Each area has a compact local map and explicit connections.
declare -a towns terrain wild_pools wild_levels
while IFS='|' read -r id name kind level pool; do
    towns[id]=$name terrain[id]=$kind wild_levels[id]=$level wild_pools[id]=$pool
done <<'WORLD'
0|Pallet Town|town|3|16 19
1|Route 1|route|3|16 19
2|Viridian City|town|5|29 32
3|Route 2|route|5|10 13 16 19
4|Viridian Forest|forest|6|10 13 25
5|Pewter City|town|9|39 16
6|Route 3|route|9|21 39 56
7|Mt. Moon|cave|11|35 41 46 74
8|Route 4|route|11|21 23 56
9|Cerulean City|town|15|54 60
10|Route 24 / Nugget Bridge|route|15|43 63 69
11|Route 25 / Sea Cottage|route|16|43 48 63
12|Route 5|route|15|16 43 52
13|Underground Path (north-south)|tunnel|16|19 41
14|Route 6|route|16|16 43 52
15|Vermilion City|town|18|72 98
16|S.S. Anne|ship|19|129
17|Diglett Cave|cave|18|50 51
18|Route 11|route|18|21 23 96
19|Route 9|route|18|19 21 23
20|Rock Tunnel|cave|21|41 66 74 95
21|Lavender Town|town|22|92 96
22|Pokemon Tower|tower|24|92 93 104
23|Route 8|route|22|23 37 58 52
24|Underground Path (east-west)|tunnel|22|19 41
25|Route 7|route|22|37 43 58
26|Celadon City|town|25|37 58 133
27|Rocket Hideout|hideout|26|19 20 41 109
28|Route 16|route|26|21 84 20
29|Route 17 / Cycling Road|route|28|20 21 84
30|Fuchsia City|town|30|48 49
31|Safari Zone|safari|28|29 32 46 49 102 111 113 115 123 127 128 147
32|Route 12|coast|25|44 70 79
33|Saffron City|town|32|63 96
34|Silph Co.|hideout|33|42 82 97 110
35|Route 19|sea|32|72 73 116
36|Seafoam Islands|cave|32|54 79 86 90 124
37|Route 20|sea|33|72 73 116
38|Cinnabar Island|town|36|77 114
39|Pokemon Mansion|mansion|36|58 77 88 109 132
40|Route 21|sea|33|72 73 114
41|Route 22|route|5|19 21 29 32
42|Route 23|route|40|22 24 57 112
43|Victory Road|cave|43|42 67 74 75 95 105
44|Indigo Plateau|town|50|22 112
45|Cerulean Cave|cave|55|42 49 64 67 82 101 112 113 132
46|Power Plant|hideout|33|25 26 81 82 100 101 125
47|Route 10|route|20|21 100
48|Route 15|route|27|44 49 70 132
49|Route 14|route|26|44 49 70
50|Route 13|route|25|44 49 70
51|Route 18|route|28|20 22 84
52|Pewter Museum|museum|10|74
53|Fighting Dojo|dojo|30|56 66
WORLD
unset id name kind level pool
declare -A neighbors edge_requirements
connect() {
    neighbors[$1]="${neighbors[$1]:-} $2"
    neighbors[$2]="${neighbors[$2]:-} $1"
    if [[ -n ${3:-} ]]; then edge_requirements[$1:$2]=$3; edge_requirements[$2:$1]=$3; fi
}
connect 0 1 lab
connect 1 2
connect 2 3 pokedex
connect 3 4
connect 4 5
connect 5 6 b1
connect 6 7
connect 7 8 moon
connect 8 9
connect 9 10
connect 10 11 bridge
connect 9 12 stolen
connect 12 13
connect 13 14
connect 14 15
connect 15 16 bill
connect 15 17
connect 17 3
connect 15 18
connect 9 19 anne,b2
connect 19 47
connect 47 20
connect 20 21 tunnel
connect 21 22
connect 21 23
connect 23 24
connect 24 25
connect 25 26
connect 26 27
connect 26 28
connect 28 29 snorlax_west,bicycle
connect 29 51
connect 51 30
connect 18 32 snorlax_east
connect 32 50
connect 50 49
connect 49 48
connect 48 30
connect 30 31
connect 23 33 drink
connect 25 33 drink
connect 12 33 drink
connect 33 34
connect 33 53
connect 30 35 safari,b5
connect 35 36
connect 36 37 warden,b4
connect 37 38
connect 38 39
connect 38 40 safari,b5
connect 40 0
connect 2 41
connect 41 42 b8,rival22late
connect 42 43 warden
connect 43 44 victory
connect 9 45 champion,safari
connect 47 46 safari,b5
connect 5 52

requirements_met() {
    local need
    local -a needs
    IFS=',' read -r -a needs <<< "$1"
    for need in "${needs[@]}"; do
        case $need in
            ''|-) ;;
            b[1-8]) [[ ${flags[gym${need#b}]:-0} == 1 ]] || return 1 ;;
            champion) (( champion )) || return 1 ;;
            *) [[ ${flags[$need]:-0} == 1 ]] || return 1 ;;
        esac
    done
    return 0
}
set_map() {
    local row fill='.' i pos
    map=('#####################' '#...................#' '#...................#' '#...................#' '<...................>' '#...................#' '#...................#' '#...................#' '#####################')
    case ${terrain[area]} in
        forest|route|safari) fill=: ;;
        cave|tower|hideout|mansion|tunnel) fill=: ;;
        sea|coast) fill='~' ;;
    esac
    if [[ $fill != . ]]; then
        map[5]="#..${fill}${fill}${fill}${fill}...${fill}${fill}${fill}${fill}${fill}${fill}....#"
        map[6]=${map[5]}
    fi
    # Area-specific scenery stays off the central corridors.
    for ((i=0;i<3;i++)); do
        pos=$((2+(area*3+i*5)%17)); row=$((1+i*2))
        map[row]="${map[row]:0:pos}#${map[row]:pos+1}"
    done
    map[4]='<.........N.........>'
    case ${terrain[area]} in
        town) map[4]='<...C.....N....S....>' ;;
        ship) map[4]='<...C.....N.........>' ;;
    esac
    case $area in 0|2|5|9|15|26|30|33|38|44|53) map[2]='#.........G.........#' ;; esac
    if [[ ${terrain[area]} == town ]]; then map[2]='#.........G.....P...#'; fi
    if [[ ${terrain[area]} != town ]]; then map[2]='#...............T...#'; fi
    if (( area == 53 )); then map[2]='#.........G.....T...#'; fi
    # N is the story interaction point. T is repeatable training; P is storage.
    return 0
}
world_menu() {
    local dest choice i=0 need
    local -a exits
    read -r -a exits <<< "${neighbors[$area]:-}"
    printf '\nDrogi z %s (0: powrót)\n' "${towns[area]}"
    for dest in "${exits[@]}"; do
        i=$((i+1)); need=${edge_requirements[$area:$dest]:-}
        if requirements_met "$need"; then printf '%s. %s\n' "$i" "${towns[dest]}"
        else printf '%s. %s [wymagane: %s]\n' "$i" "${towns[dest]}" "$need"; fi
    done
    ask 'Droga: ' || return 2
    choice=$REPLY
    [[ $choice =~ ^[1-9][0-9]?$ ]] || return 0
    (( choice <= ${#exits[@]} )) || return 0
    dest=${exits[choice-1]}; if (( dest==16 )) && [[ ${flags[anne]:-0} == 1 ]]; then message="S.S. Anne już odpłynął"; return 0; fi; need=${edge_requirements[$area:$dest]:-}
    if ! requirements_met "$need"; then message="Przejście zamknięte. Dziennik [j]: $need"; return 0; fi
    area=$dest x=1 y=4; flags[visit$dest]=1; set_map
    message="Docierasz do ${towns[area]}"
}
world_overview() {
    local i
    printf '\nKANTO | Tu jesteś: %s\n' "${towns[area]}"
    for ((i=0;i<${#towns[@]};i++)); do printf '%2s %s\n' "$i" "${towns[i]}"; done
    printf 'Do sąsiednich lokacji przechodzisz przez < lub >. Dziennik: j\n'
}
# End module: world
# Embedded module: story
# Original Polish dialogue summaries; milestones are persistent, one-time events.
declare -a event_ids
# id -> location, requirements, title, dialogue, encounter team
# b1..b8 refer to specific badges, not the number of badges.
declare -A event_area event_need event_title event_text event_team flags
while IFS='|' read -r key location need title dialogue team; do
    event_ids+=("$key"); event_area[$key]=$location event_need[$key]=$need
    event_title[$key]=$title event_text[$key]=$dialogue event_team[$key]=$team
done <<'STORY'
lab|0|-|Laboratorium Oaka: pierwszy rywal|Oak zatrzymuje Cię przed wejściem w trawę. Otrzymujesz startera. Blue wybiera Pokémona z przewagą typu i proponuje pierwszą walkę.|rival:5
parcel|2|lab|Przesyłka dla profesora|Sprzedawca w Viridian rozpoznaje Pokémona Oaka. Prosi o dostarczenie przesyłki do laboratorium w Pallet.|-
pokedex|0|parcel|Powrót do Oaka i Pokédex|Oak odbiera przesyłkę. Tobie i Blue powierza Pokédex. Twoim zadaniem jest poznawanie gatunków, nie tylko wygrywanie walk.|-
oldman|2|pokedex|Lekcja łapania|Starszy trener pokazuje, jak osłabienie dzikiego Pokémona pomaga go złapać. Wypróbuj kule w trawie.|-
rival22early|41|pokedex|Blue na zachodnim szlaku|Blue sprawdza drogę do Ligi. Strażnicy jeszcze go nie przepuszczają. Zanim wróci do treningu, chce sprawdzić Twoją drużynę.|rival:9
forest|4|pokedex|Przez Viridian Forest|Las pełen jest trenerów owadów. Młody łapacz staje na ścieżce prowadzącej do Pewter.|13:7 10:7 11:8
moon|7|b1|Mt. Moon: Rocket i skamieliny|Ludzie Team Rocket przeszukują jaskinię. Pokonaj ich oraz badacza pilnującego skamielin. Jedną zabierzesz do późniejszego odtworzenia.|41:11 19:11 20:13 88:12 100:12 109:12
bridge_rival|10|moon|Blue przed Nugget Bridge|Blue wraca z wizyty u Billa. Chwali się nowymi Pokémonami i blokuje wejście na most kolejnym wyzwaniem.|rival:17
bridge|10|bridge_rival|Nugget Bridge: sześciu przeciwników|Po pięciu trenerach czeka człowiek oferujący miejsce w Team Rocket. Odmawiasz i stajesz z nim do walki.|10:14 13:14 16:14 43:14 19:14 23:15 56:18 23:15 41:15
bill|11|bridge|Bill w Sea Cottage|Eksperyment połączył Billa z Pokémonem. Uruchamiasz rozdzielacz i przywracasz mu ludzką postać. W podzięce otrzymujesz bilet na S.S. Anne.|-
stolen|9|bill|Okradziony dom|Rocket wychodzi tyłem z okradzionego domu. Po walce odzyskujesz zdobycz i otwierasz drogę na południe.|66:17 96:17
voucher|15|pokedex|Fan Club i voucher na rower|Przewodniczący Fan Clubu opowiada o swoim ulubieńcu. Za cierpliwość daje voucher do sklepu rowerowego w Cerulean.|-
bicycle|9|voucher|Rower z Cerulean|Sprzedawca przyjmuje voucher. Rower pozwoli skorzystać z Cycling Road.|-
anne_rival|16|bill|Blue na pokładzie S.S. Anne|Pasażerowie szykują się do rejsu. Blue wraca od kapitana i znów sprawdza postępy Twojej drużyny.|rival:20
anne|16|anne_rival|Kapitan i HM01 Cut|Kapitan cierpi na chorobę morską. Pomagasz mu dojść do siebie. Otrzymujesz Cut. Po opuszczeniu doku statek odpłynie.|-
flash|3|anne|Pomocnik Oaka: HM05 Flash|Pomocnik sprawdza Pokédex. Za co najmniej dziesięć zarejestrowanych gatunków daje Flash, który rozjaśnia Rock Tunnel.|-
oldamber|52|anne,b2|Stary bursztyn w muzeum|Boczne wejście do muzeum odsłania laboratorium. Badacz przekazuje bursztyn. Na Cinnabar można odtworzyć z niego dawnego Pokémona.|-
tunnel|20|anne,b2|Rock Tunnel|Bez Flash widzisz jedynie zarys korytarzy. Z Flash łatwiej rozpoznajesz drogę. Przed wyjściem do Lavender walczysz z wędrowcami.|74:21 95:21 66:22
rival_tower|22|tunnel|Blue w Pokemon Tower|Blue stoi wśród nagrobków. Pyta o Twój Pokédex, po czym proponuje walkę. Na wyższych piętrach pojawia się nierozpoznany duch.|rival:25
drink|26|tunnel|Dom towarowy i spragnieni strażnicy|Kupujesz świeżą wodę na dachu domu towarowego. Strażnik bramy Saffron dzieli się napojem z kolegami i otwiera przejścia.|-
eevee|26|tunnel|Eevee na poddaszu|Tylnym wejściem docierasz na poddasze Celadon Mansion. Czeka tam Eevee, który potrzebuje nowego opiekuna.|-
fly|28|anne,b2|Ustronny dom: HM02 Fly|Za drzewem spotykasz osobę ceniącą spokój. Otrzymujesz Fly. Z odznaką Surge możesz wracać do odwiedzonych miast.|-
liftkey|27|tunnel|Sekret automatu i Lift Key|Rocket w Game Corner strzeże plakatu. Odkrywasz przełącznik i schody do kryjówki. Jeden z przeciwników upuszcza klucz do windy.|20:21 41:21 109:21 96:21
scope|27|liftkey|Giovanni w Rocket Hideout|Winda prowadzi do gabinetu szefa Team Rocket. Giovanni traktuje Pokémony jak narzędzia zysku. Zwycięstwo pozwala odzyskać Silph Scope.|95:25 111:24 115:29
ghost|22|scope,rival_tower|Duch matki Cubone|Silph Scope rozpoznaje ducha Marowak. Nie możesz go złapać. Pokonanie zjawy przynosi jej spokój i otwiera drogę na ostatnie piętro.|105:30
fuji|22|ghost|Uwolnienie pana Fuji|Trzej Rockets więżą pana Fuji na szczycie wieży. Po zwycięstwie wracasz z nim do domu. W podzięce otrzymujesz Poké Flute.|41:25 42:25 109:26 96:26 41:23 19:23 20:23 41:23
snorlax_east|18|fuji|Snorlax przy Route 12|Grasz na Poké Flute. Snorlax budzi się i rozpoczyna walkę. Możesz go złapać albo pokonać, aby udrożnić wschodni szlak.|wild:143:30
snorlax_west|28|fuji|Snorlax przed Cycling Road|Drugi Snorlax blokuje drogę rowerową. Melodia fletu budzi olbrzyma. Ucieczka nie usuwa blokady.|wild:143:30
safari|31|fuji|Safari Zone: Secret House i Gold Teeth|Przechodzisz przez kolejne sektory rezerwatu. Odnajdujesz zgubione złote zęby oraz Secret House. Opiekun wręcza HM03 Surf.|-
warden|30|safari|Złote zęby strażnika|Oddajesz strażnikowi Gold Teeth. Znów może wyraźnie mówić. W nagrodę uczy Cię korzystania z HM04 Strength.|-
cardkey|34|drink,fuji|Silph Co.: Card Key|Saffron jest opanowane przez Team Rocket. W wieżowcu Silph odnajdujesz Card Key. Karta otwiera zamknięte biura i dostęp do teleportów.|97:33 104:33 42:33 109:33
silph_rival|34|cardkey|Blue i pracownik Silph|Za teleportem czeka Blue. Po walce pracownik firmy powierza Ci Laprasa. Do prezesa został już tylko ostatni oddział Rocket.|rival:37
silph|34|silph_rival|Ocalenie Silph Co.|Giovanni próbuje wymusić technologię firmy. Pokonujesz go i uwalniasz prezesa. W nagrodę otrzymujesz jedyną Master Ball. Rocket opuszcza Saffron.|111:37 115:35 31:41 112:37
dojo|53|drink|Fighting Dojo|Mistrz dojo chce sprawdzić Twoją technikę. Po zwycięstwie możesz przyjąć Hitmonlee albo Hitmonchana.|66:31 56:31 57:31 106:37 107:37
mansion|39|safari,b5|Sekret Pokemon Mansion|Odczytujesz dzienniki eksperymentów nad Mew i Mewtwo. Przełączniki w posągach otwierają drogę do podziemi. Odnajdujesz Secret Key do sali Blaine'a.|110:38 89:39
fossil|38|moon|Laboratorium Cinnabar|Badacze odtwarzają Pokémona z wybranej w Mt. Moon skamieliny. Dawne życie wraca do Twojej drużyny.|-
amber|38|oldamber|Odtworzenie Aerodactyla|Zespół laboratorium wykorzystuje bursztyn z muzeum w Pewter. Otrzymujesz Aerodactyla.|-
articuno|36|safari,warden,b4,b5|Articuno w Seafoam|Przesuwasz głazy do nurtu, zatrzymując prąd w podziemnej rzece. Na wysepce czeka lodowy ptak Articuno.|wild:144:50
zapdos|46|safari,b5|Zapdos w Power Plant|Za porzuconymi generatorami słyszysz trzask wyładowań. Legendarny Zapdos broni swojego schronienia.|wild:145:50
rival22late|41|b1,b2,b3,b4,b5,b6,b7,b8|Blue przed drogą do Ligi|Blue ma już wszystkie odznaki. Zapowiada, że zostanie mistrzem przed Tobą. To ostatni sprawdzian przed Victory Road.|rival:53
victory|43|rival22late,warden|Próba Victory Road|Strength pozwala ustawić głazy na przełącznikach. Przechodzisz kolejne komnaty i mierzysz się z trenerami gotowymi na Ligę.|28:43 67:43 75:43 97:43 99:43
moltres|43|victory|Moltres w Victory Road|Z bocznej komnaty bije gorąco. Płomienny Moltres czeka z dala od głównego szlaku.|wild:146:50
mewtwo|45|champion,safari|Mewtwo w Cerulean Cave|Po mistrzostwie strażnik wpuszcza Cię do jaskini. Na jej najgłębszym poziomie odnajdujesz Mewtwo, rezultat eksperymentów opisanych na Cinnabar.|wild:150:70
STORY
unset key location need title dialogue team

gym_areas=(5 9 15 26 30 33 38 2)
leaders=(Brock Misty 'Lt. Surge' Erika Koga Sabrina Blaine Giovanni)
gym_needs=(pokedex moon anne,b2 anne fuji silph mansion b1,b2,b3,b4,b5,b6,b7,silph)
gym_teams=('74:12 95:14' '120:18 121:21' '100:21 25:18 26:24' '71:29 114:24 45:29' '109:37 89:39 109:37 110:43' '64:38 122:37 49:38 65:43' '58:42 77:40 78:42 59:47' '111:45 51:42 31:44 34:45 112:50')

rival_team() {
    local level=$1 enemy=4
    case $starter in 1) enemy=4 ;; 4) enemy=7 ;; 7) enemy=1 ;; esac
    (( level >= 16 )) && enemy=$((enemy+1))
    (( level >= 36 )) && enemy=$((enemy+1))
    REPLY="$enemy:$level"
    (( level >= 9 )) && REPLY="16:$level $REPLY"
    (( level >= 17 )) && REPLY="17:$level 19:$((level-2)) 63:$((level-2)) $enemy:$((level+1))"
    (( level >= 25 )) && REPLY="17:$level 58:$level 64:$level 102:$level $enemy:$level"
    (( level >= 53 )) && REPLY="18:47 111:45 58:45 102:47 65:50 $enemy:53"
    return 0
}
run_story_event() {
    local key=$1 team result choice level id
    if [[ ${flags[$key]:-0} == 1 ]]; then message='To wydarzenie jest już zakończone'; return 0; fi
    if (( area != event_area[$key] )) || ! requirements_met "${event_need[$key]}"; then
        message="Wymagane: ${event_need[$key]}. Sprawdź dziennik [j]"; return 0
    fi
    if [[ $key == flash ]] && (( ${#owned[@]} < 10 )); then message='Pomocnik wymaga 10 złapanych gatunków'; return 0; fi
    if [[ $key == lab ]]; then heal_party; fi
    printf '\n%s\n%s\n' "${event_title[$key]}" "${event_text[$key]}"
    if [[ $key == mansion ]]; then
        printf '%s\n' 'Dziennik 1: Ekspedycja odkrywa nieznanego Pokémona w Ameryce Południowej.' \
            'Dziennik 2: Odkryty gatunek otrzymuje nazwę Mew.' \
            'Dziennik 3: Na świat przychodzi Mewtwo, związany z badaniami nad Mew.' \
            'Dziennik 4: Siła Mewtwo przewyższa kontrolę badaczy. Eksperyment wymyka się spod kontroli.'
    fi
    ask 'Rozpocząć? [t/n]: ' || return 2
    [[ $REPLY == t ]] || return 0
    team=${event_team[$key]}
    case $team in
        rival:*) rival_team "${team#*:}"; trainer_team "$REPLY"; result=$? ;;
        wild:*)
            id=${team#wild:}; level=${id#*:}; id=${id%:*}
            battle "$id" "$level" wild; result=$?
            if (( result == 0 )) && [[ $battle_result == fled ]]; then message='Pokémon nadal blokuje miejsce'; return 0; fi
            ;;
        -) result=0 ;;
        *) trainer_team "$team"; result=$? ;;
    esac
    if [[ $key == lab && $result == 1 ]]; then
        # Losing the tutorial is part of the story, not a softlock.
        heal_party; result=0
    fi
    (( result == 0 )) || return "$result"
    case $key in
        moon)
            ask 'Skamielina: [1] Helix (Omanyte) [2] Dome (Kabuto): ' || return 2
            case $REPLY in 1) fossil_id=138 ;; 2) fossil_id=140 ;; *) message='Wybór anulowany. Wróć do badacza'; return 0 ;; esac ;;
        dojo)
            ask 'Wybierz [1] Hitmonlee [2] Hitmonchan: ' || return 2
            case $REPLY in 1) id=106 ;; 2) id=107 ;; *) return 0 ;; esac
            add_pokemon "$id" 30 || return 0 ;;
        eevee) add_pokemon 133 25 || return 0 ;;
        silph_rival) add_pokemon 131 15 || return 0 ;;
        fossil) add_pokemon "$fossil_id" 30 || return 0 ;;
        amber) add_pokemon 142 30 || return 0 ;;
        silph) masterballs=1 ;;
        bridge) gold=$((gold+500)); (( gold>999999 )) && gold=999999 ;;
    esac
    flags[$key]=1
    message="Zakończono: ${event_title[$key]}"
    [[ $key == lab ]] && heal_party
    return 0
}
story_menu() {
    local key i=0 choice
    local -a options=()
    for key in "${event_ids[@]}"; do
        if (( event_area[$key] == area )) && [[ ${flags[$key]:-0} != 1 ]]; then
            options+=("$key"); i=$((i+1))
            printf '%s. %s' "$i" "${event_title[$key]}"
            if ! requirements_met "${event_need[$key]}"; then printf ' [wymagane: %s]' "${event_need[$key]}"; fi
            printf '\n'
        fi
    done
    if (( i == 0 )); then message="${towns[area]}: trenuj drużynę i sprawdź dziennik [j]"; return 0; fi
    ask 'Wydarzenie (0: powrót): ' || return 2
    choice=$REPLY
    [[ $choice =~ ^[1-9][0-9]?$ ]] || return 0
    (( choice <= i )) || return 0
    run_story_event "${options[choice-1]}"
}
journal() {
    local key status i
    printf '\nDZIENNIK | %s | odznaki %s/8\n' "${towns[area]}" "$badges"
    for key in "${event_ids[@]}"; do
        status='czeka'
        if [[ ${flags[$key]:-0} == 1 ]]; then status='gotowe'
        elif requirements_met "${event_need[$key]}"; then status='DOSTĘPNE'; fi
        printf '[%s] %s | %s | %s\n' "$status" "$key" "${towns[${event_area[$key]}]}" "${event_title[$key]}"
    done
    for ((i=0;i<8;i++)); do printf 'b%s: %s | %s\n' "$((i+1))" "${leaders[i]}" "${flags[gym$((i+1))]:-0}"; done
    printf 'Wydarzenia: stań na N i naciśnij e. Sale: G + e. Centrum/PC: C/P + e\n'
    if (( champion )); then printf 'Sala Sławy: mistrzostwo zapisane. Odkrywaj jaskinię Cerulean i uzupełniaj Pokédex\n'; fi
}
gym() {
    local i result flag
    if (( area == 0 )); then story_menu; return $?; fi
    if (( area == 44 )); then league; return $?; fi
    if (( area == 53 )); then run_story_event dojo; return $?; fi
    for ((i=0;i<8;i++)); do
        if (( gym_areas[i] != area )); then continue; fi
        flag=gym$((i+1))
        if [[ ${flags[$flag]:-0} == 1 ]]; then message='Masz już tę odznakę'; return 0; fi
        if ! requirements_met "${gym_needs[i]}"; then message="Sala: wymagane ${gym_needs[i]}"; return 0; fi
        ask "${leaders[i]}: walczymy? [t/n]: " || return 2
        [[ $REPLY == t ]] || return 0
        trainer_team "${gym_teams[i]}"; result=$?
        if (( result == 0 )); then
            flags[$flag]=1; badges=$((badges+1)); message="${leaders[i]} pokonany! Odznaka b$((i+1))"
            if (( i == 7 )); then message+=' Giovanni rozwiązuje Team Rocket i opuszcza salę'; fi
        fi
        return "$result"
    done
    message='Nie ma tu sali. Sprawdź wydarzenia na N'
}
league() {
    local team result enemy=6 i=0
    local -a elite_names=(Lorelei Bruno Agatha Lance Blue)
    if (( champion )); then message='Twoja drużyna jest w Sali Sławy. Cerulean Cave stoi otworem'; return 0; fi
    if (( badges != 8 )) || ! requirements_met victory; then message='Zdobądź osiem odznak i przejdź Victory Road'; return 0; fi
    ask 'Liga: pięć zespołów, bez Centrum i PC. Wejść? [t/n]: ' || return 2
    [[ $REPLY == t ]] || return 0
    case $starter in 1) enemy=6 ;; 4) enemy=9 ;; 7) enemy=3 ;; esac
    local extras='59:61 103:63'
    case $starter in 1) extras='103:61 130:63' ;; 4) extras='59:61 103:63' ;; 7) extras='130:61 59:63' ;; esac
    for team in '87:54 91:53 80:54 124:56 131:56' '95:53 107:55 106:55 95:56 68:58' '94:56 42:56 93:55 24:58 94:60' '130:58 148:56 148:56 142:60 149:62' "18:61 65:59 112:61 $extras $enemy:65"; do
        printf '\nELITA: %s\n' "${elite_names[i]}"
        if (( i == 4 )); then printf 'Blue wyprzedził Cię i został mistrzem. Teraz musisz pokonać jego pełną drużynę!\n'; fi
        trainer_team "$team"; result=$?
        (( result == 0 )) || return "$result"
        i=$((i+1))
    done
    champion=1
    message='Oak gratuluje więzi z drużyną. Wpis do Sali Sławy! Zostajesz mistrzem Kanto'
    printf '\n%s\nKONIEC GŁÓWNEJ HISTORII | Możesz kontynuować przygodę\n' "$message"
}
# End module: story
# Embedded module: collection
# Team, PC, Pokédex, and item/trade evolution.
declare -a box_id box_lv box_xp box_hp
declare -A owned
add_pokemon() {
    local sid=$1 level=$2 hp=${3:-} xp=${4:-0}
    if [[ -z $hp ]]; then max_hp "$level"; hp=$REPLY; fi
    if (( ${#party_id[@]} < 6 )); then
        party_id+=("$sid"); party_lv+=("$level"); party_xp+=("$xp"); party_hp+=("$hp")
        printf '%s dołącza do drużyny\n' "${names[sid]}"
    elif (( ${#box_id[@]} < 300 )); then
        box_id+=("$sid"); box_lv+=("$level"); box_xp+=("$xp"); box_hp+=("$hp")
        printf '%s trafia do PC\n' "${names[sid]}"
    else
        message='Drużyna i PC są pełne'; return 1
    fi
    owned[$sid]=1
}
remove_party_slot() {
    local index=$1
    unset 'party_id[index]' 'party_lv[index]' 'party_xp[index]' 'party_hp[index]'
    party_id=("${party_id[@]}") party_lv=("${party_lv[@]}") party_xp=("${party_xp[@]}") party_hp=("${party_hp[@]}")
    first_alive
}
can_remove_slot() {
    local index=$1 i
    (( ${#party_id[@]} > 1 )) || return 1
    for ((i=0;i<${#party_id[@]};i++)); do
        if (( i!=index && party_hp[i]>0 )); then return 0; fi
    done
    return 1
}
pc_menu() {
    local i index choice slot sid lv xp hp
    printf '\nPC: %s/300 | [1] Odłóż [2] Pobierz / zamień [0] Powrót\n' "${#box_id[@]}"
    ask '> ' || return 2
    choice=$REPLY
    case $choice in
        1)
            show_party; ask 'Numer do odłożenia (0: powrót): ' || return 2
            [[ $REPLY =~ ^[1-6]$ ]] || return 0
            index=$((REPLY-1)); (( index<${#party_id[@]} )) || return 0
            if (( ${#box_id[@]} >= 300 )) || ! can_remove_slot "$index"; then message='Nie możesz odłożyć tego Pokémona'; return 0; fi
            box_id+=("${party_id[index]}"); box_lv+=("${party_lv[index]}"); box_xp+=("${party_xp[index]}"); box_hp+=("${party_hp[index]}")
            remove_party_slot "$index"; message='Pokémon odłożony do PC' ;;
        2)
            for ((i=0;i<${#box_id[@]};i++)); do printf '%s. %s poz. %s\n' "$((i+1))" "${names[${box_id[i]}]}" "${box_lv[i]}"; done
            ask 'Numer z PC (0: powrót): ' || return 2
            [[ $REPLY =~ ^[1-9][0-9]{0,2}$ ]] || return 0
            index=$((REPLY-1)); (( index<${#box_id[@]} )) || return 0
            if (( ${#party_id[@]} == 6 )); then
                show_party; ask 'Zamień z numerem drużyny (0: powrót): ' || return 2
                [[ $REPLY =~ ^[1-6]$ ]] || return 0
                slot=$((REPLY-1))
                if (( box_hp[index]==0 )) && ! can_remove_slot "$slot"; then message='Zachowaj przytomnego Pokémona'; return 0; fi
                sid=${party_id[slot]} lv=${party_lv[slot]} xp=${party_xp[slot]} hp=${party_hp[slot]}
                party_id[slot]=${box_id[index]} party_lv[slot]=${box_lv[index]} party_xp[slot]=${box_xp[index]} party_hp[slot]=${box_hp[index]}
                box_id[index]=$sid box_lv[index]=$lv box_xp[index]=$xp box_hp[index]=$hp
            else
                party_id+=("${box_id[index]}"); party_lv+=("${box_lv[index]}"); party_xp+=("${box_xp[index]}"); party_hp+=("${box_hp[index]}")
                unset 'box_id[index]' 'box_lv[index]' 'box_xp[index]' 'box_hp[index]'
                box_id=("${box_id[@]}") box_lv=("${box_lv[@]}") box_xp=("${box_xp[@]}") box_hp=("${box_hp[@]}")
            fi
            first_alive; message='Zaktualizowano drużynę' ;;
    esac
    return 0
}
pokedex_menu() {
    local i
    printf '\nPOKÉDEX: %s/151 gatunków\n' "${#owned[@]}"
    for ((i=1;i<=151;i++)); do
        if [[ ${owned[$i]:-0} == 1 ]]; then printf '%03s %-12s %s / %s\n' "$i" "${names[i]}" "${types[i]}" "${types2[i]}"
        else printf '%03s ---\n' "$i"; fi
    done
}
evolution_menu() {
    local index condition next price=300
    show_party
    ask 'Kamień (300 monet) / wymiana (bez opłaty). Pokémon (0: powrót): ' || return 2
    [[ $REPLY =~ ^[1-6]$ ]] || return 0
    index=$((REPLY-1)); (( index<${#party_id[@]} )) || return 0
    condition=${evolve_at[${party_id[index]}]} next=${evolutions[${party_id[index]}]}
    case $condition in
        trade) price=0 ;;
        stone:*) ;;
        eevee)
            ask 'Kamień: [1] Thunder [2] Water [3] Fire [0] Powrót: ' || return 2
            case $REPLY in 1) next=135 ;; 2) next=134 ;; 3) next=136 ;; *) return 0 ;; esac ;;
        *) message='Ten Pokémon nie ewoluuje przez kamień ani wymianę'; return 0 ;;
    esac
    if (( gold<price )); then message='Za mało monet'; return 0; fi
    ask "Ewolucja w ${names[next]} za $price monet? [t/n]: " || return 2
    [[ $REPLY == t ]] || return 0
    gold=$((gold-price)); party_id[index]=$next; owned[$next]=1
    message="Ewolucja! ${names[next]}"
}
fly_menu() {
    local i dest choice
    local -a targets=()
    if ! requirements_met fly,b3; then message='Fly wymaga HM02 i odznaki Surge'; return 0; fi
    for ((i=0;i<${#towns[@]};i++)); do
        if [[ ${terrain[i]} == town && ${flags[visit$i]:-0} == 1 ]]; then
            targets+=("$i"); printf '%s. %s\n' "${#targets[@]}" "${towns[i]}"
        fi
    done
    ask 'Cel lotu (0: powrót): ' || return 2
    choice=$REPLY
    [[ $choice =~ ^[1-9][0-9]?$ ]] || return 0
    (( choice<=${#targets[@]} )) || return 0
    dest=${targets[choice-1]}; area=$dest x=4 y=4; set_map
    message="Przylot do ${towns[area]}"
}
bag_menu() {
    local key label
    printf '\nPLECAK | monety %s | kule %s | mikstury %s | Master Ball %s\n' "$gold" "$balls" "$potions" "$masterballs"
    while IFS='|' read -r key label; do
        [[ ${flags[$key]:-0} == 1 ]] && printf '%s\n' "$label"
    done <<'ITEMS'
pokedex|Pokédex
bill|S.S. Ticket
bicycle|Bicycle
anne|HM01 Cut (odznaka Misty)
fly|HM02 Fly (odznaka Surge)
safari|HM03 Surf (odznaka Kogi)
warden|HM04 Strength (odznaka Eriki)
flash|HM05 Flash (odznaka Brocka)
liftkey|Lift Key
scope|Silph Scope
fuji|Poké Flute
cardkey|Card Key
mansion|Secret Key
drink|Otwarte bramy Saffron
ITEMS
    if (( fossil_id>0 )) && [[ ${flags[fossil]:-0} != 1 ]]; then printf 'Skamielina: %s\n' "${names[fossil_id]}"; fi
    if [[ ${flags[oldamber]:-0} == 1 && ${flags[amber]:-0} != 1 ]]; then printf 'Old Amber\n'; fi
    return 0
}
# End module: collection
declare -a party_id party_lv party_xp party_hp
area=0 x=10 y=4 gold=500 balls=10 potions=5 badges=0 champion=0
active=0 starter=1 checkpoint=0 masterballs=0 fossil_id=0
message='' save_file='' battle_result=''

max_hp() { REPLY=$((20 + $1 * 3)); }
new_game() {
    starter=$1
    area=0 x=10 y=4 gold=500 balls=10 potions=5 badges=0 champion=0 active=0
    checkpoint=0 masterballs=0 fossil_id=0
    party_id=("$starter") party_lv=(5) party_xp=(0) party_hp=(35)
    box_id=() box_lv=() box_xp=() box_hp=() flags=() owned=()
    flags[visit0]=1; owned[$starter]=1; set_map
    message='Laboratorium Oaka: naciśnij e, wybierz wydarzenie i rozpocznij przygodę'
}
heal_party() {
    local i
    for ((i=0; i<${#party_id[@]}; i++)); do
        max_hp "${party_lv[i]}"; party_hp[i]=$REPLY
    done
}
first_alive() {
    local i
    for ((i=0; i<${#party_id[@]}; i++)); do
        if (( party_hp[i] > 0 )); then active=$i; return 0; fi
    done
    return 1
}
blackout() {
    gold=$((gold / 2)); area=$checkpoint x=4 y=4; set_map
    heal_party; active=0
    message='Drużyna omdlała. Centrum Pokémon pomogło. Tracisz połowę pieniędzy.'
}
gain_xp() {
    local index=$1 amount=$2 next
    party_xp[index]=$((party_xp[index] + amount))
    while (( party_lv[index] < 100 && party_xp[index] >= party_lv[index] * 12 )); do
        party_xp[index]=$((party_xp[index] - party_lv[index] * 12))
        party_lv[index]=$((party_lv[index] + 1))
        party_hp[index]=$((party_hp[index] + 3))
        printf '%s awansuje na poziom %s!\n' "${names[${party_id[index]}]}" "${party_lv[index]}"
        next=${evolutions[${party_id[index]}]}
        if [[ ${evolve_at[${party_id[index]}]} =~ ^[0-9]+$ ]] && (( next > 0 && party_lv[index] >= evolve_at[${party_id[index]}] )); then
            party_id[index]=$next; owned[$next]=1
            printf 'Ewolucja! Teraz to %s!\n' "${names[next]}"
        fi
    done
    (( party_lv[index] == 100 )) && party_xp[index]=0
    return 0
}
# Integer type effectiveness: 0=immune, 1=resistant, 2=neutral, 4=weak.
effectiveness() {
    local attack=$1 defend=$2
    REPLY=2
    case "$attack:$defend" in
        normal:ghost|fighting:ghost|ghost:normal|electric:ground|ground:flying) REPLY=0 ;;
        fire:grass|fire:bug|fire:ice|water:fire|water:rock|water:ground|grass:water|grass:rock|grass:ground|electric:water|electric:flying|ground:fire|ground:electric|ground:poison|ground:rock|rock:fire|rock:ice|rock:flying|rock:bug|psychic:poison|psychic:fighting|ice:grass|ice:ground|ice:flying|ice:dragon|bug:grass|bug:psychic|fighting:normal|fighting:rock|fighting:ice|poison:grass|flying:grass|flying:bug|flying:fighting|ghost:ghost|dragon:dragon) REPLY=4 ;;
        fire:fire|fire:water|fire:rock|fire:dragon|water:water|water:grass|water:dragon|grass:fire|grass:grass|grass:poison|grass:flying|grass:bug|grass:dragon|electric:electric|electric:grass|electric:dragon|normal:rock|ground:grass|ground:bug|psychic:psychic|ice:water|ice:ice|fighting:poison|fighting:flying|fighting:psychic|fighting:bug|bug:fire|bug:fighting|bug:flying|bug:ghost|poison:poison|poison:ground|poison:rock|poison:ghost|flying:electric|flying:rock|rock:fighting|rock:ground|ghost:psychic) REPLY=1 ;;
    esac
}
damage() {
    local level=$1 attack_type=$2 defense_type=$3 power=$4 second=${5:--} multiplier other=2
    effectiveness "$attack_type" "$defense_type"; multiplier=$REPLY
    if [[ $second != - ]]; then effectiveness "$attack_type" "$second"; other=$REPLY; fi
    REPLY=$(((3 + level * power / 12 + RANDOM % 4) * multiplier * other / 4))
    if (( multiplier > 0 && other > 0 && REPLY == 0 )); then REPLY=1; fi
}
ask() {
    printf '%s' "$1"
    IFS= read -r REPLY || return 2
}
show_party() {
    local i
    for ((i=0; i<${#party_id[@]}; i++)); do
        max_hp "${party_lv[i]}"
        printf '%s. %-12s poz. %-3s HP %s/%s XP %s/%s\n' "$((i+1))" "${names[${party_id[i]}]}" "${party_lv[i]}" "${party_hp[i]}" "$REPLY" "${party_xp[i]}" "$((party_lv[i]*12))"
    done
}
choose_active() {
    local choice
    show_party
    ask 'Wybierz numer Pokémona (0: powrót): ' || return 2
    choice=$REPLY
    case $choice in [1-6]) ;; *) return 1 ;; esac
    choice=$((choice-1))
    if (( choice >= ${#party_id[@]} || party_hp[choice] == 0 || choice == active )); then
        printf 'Wybierz innego, przytomnego Pokémona\n'; return 1
    fi
    active=$choice
}
use_potion() {
    if (( potions == 0 )); then printf 'Brak mikstur\n'; return 1; fi
    max_hp "${party_lv[active]}"
    if (( party_hp[active] == REPLY )); then printf 'Pełne HP\n'; return 1; fi
    potions=$((potions-1)); party_hp[active]=$((party_hp[active]+50))
    (( party_hp[active] > REPLY )) && party_hp[active]=$REPLY
    printf 'Mikstura przywraca do 50 HP\n'
    return 0
}
catch_chance() {
    # Wounded targets are easier to catch: 20..80 percent.
    REPLY=$((20 + ( $2 - $1 ) * 60 / $2))
}
battle() {
    local foe=$1 level=$2 mode=$3 enemy_hp enemy_max choice attack_type power hit chance result
    battle_result=ongoing
    max_hp "$level"; enemy_hp=$REPLY enemy_max=$REPLY
    if (( active < 0 || active >= ${#party_id[@]} )); then active=0; fi
    if (( party_hp[active] == 0 )); then
        first_alive || { blackout; return 1; }
    fi
    printf '\n%s, poziom %s!\n' "${names[foe]}" "$level"
    while (( enemy_hp > 0 )); do
        printf '\n%s HP %s/%s | %s HP %s\n' "${names[foe]}" "$enemy_hp" "$enemy_max" "${names[${party_id[active]}]}" "${party_hp[active]}"
        ask '[1] Atak [2] Atak typu [3] Kula [4] Mikstura [5] Zmiana [6] Ucieczka [7] Drugi typ [8] Master Ball: ' || return 2
        choice=$REPLY
        case $choice in
            1|2|7)
                attack_type=normal power=8
                if [[ $choice == 2 ]]; then attack_type=${types[${party_id[active]}]}; power=10; fi
                if [[ $choice == 7 ]]; then
                    attack_type=${types2[${party_id[active]}]}; power=10
                    if [[ $attack_type == - ]]; then printf 'Ten Pokémon ma jeden typ\n'; continue; fi
                fi
                damage "${party_lv[active]}" "$attack_type" "${types[foe]}" "$power" "${types2[foe]}"; hit=$REPLY
                enemy_hp=$((enemy_hp-hit)); (( enemy_hp < 0 )) && enemy_hp=0
                printf 'Atak (%s): %s obrażeń\n' "$attack_type" "$hit"
                ;;
            3|8)
                if [[ $mode != wild ]]; then printf 'Nie można łapać Pokémonów trenera\n'; continue; fi
                if (( ${#party_id[@]} == 6 && ${#box_id[@]} >= 300 )); then printf 'Drużyna i PC są pełne\n'; continue; fi
                if [[ $choice == 8 ]]; then
                    if (( masterballs == 0 )); then printf 'Brak Master Ball\n'; continue; fi
                    masterballs=0
                    add_pokemon "$foe" "$level" "$enemy_hp"; battle_result=caught; message="Złapano ${names[foe]}!"; return 0
                fi
                if (( balls == 0 )); then printf 'Brak kul\n'; continue; fi
                balls=$((balls-1)); catch_chance "$enemy_hp" "$enemy_max"; chance=$REPLY
                if (( RANDOM % 100 < chance )); then
                    add_pokemon "$foe" "$level" "$enemy_hp"; battle_result=caught
                    message="Złapano ${names[foe]}!"; printf '%s\n' "$message"; return 0
                fi
                printf 'Pokémon wydostał się z kuli!\n'
                ;;
            4) use_potion || continue ;;
            5)
                choose_active; result=$?
                (( result == 2 )) && return 2
                (( result != 0 )) && continue
                ;;
            6)
                if [[ $mode != wild ]]; then printf 'Nie można uciec z walki trenerskiej\n'; continue; fi
                if (( RANDOM % 100 < 75 )); then message='Ucieczka udana'; battle_result=fled; return 0; fi
                printf 'Nie udało się uciec\n'
                ;;
            *) printf 'Wybierz 1–8\n'; continue ;;
        esac
        if (( enemy_hp == 0 )); then
            battle_result=won
            gain_xp "$active" "$((level*10))"
            gold=$((gold+level*15)); (( gold > 999999 )) && gold=999999
            message="Pokonano ${names[foe]}! +$((level*10)) XP, +$((level*15)) monet"
            printf '%s\n' "$message"; return 0
        fi
        damage "$level" "${types[foe]}" "${types[${party_id[active]}]}" 8 "${types2[${party_id[active]}]}"; hit=$REPLY
        party_hp[active]=$((party_hp[active]-hit))
        (( party_hp[active] < 0 )) && party_hp[active]=0
        printf '%s zadaje %s obrażeń\n' "${names[foe]}" "$hit"
        if (( party_hp[active] == 0 )); then
            printf '%s omdlewa!\n' "${names[${party_id[active]}]}"
            first_alive || { blackout; return 1; }
        fi
    done
}
trainer_team() {
    local pair result
    local -a team
    read -r -a team <<< "$1"
    for pair in "${team[@]}"; do
        battle "${pair%:*}" "${pair#*:}" trainer; result=$?
        (( result != 0 )) && return "$result"
    done
    return 0
}
shop() {
    local count price
    ask "Sklep | Monety: $gold | [1] 5 kul: 100 [2] Mikstura: 60 [3] Ewolucja [0] Powrót: " || return 2
    case $REPLY in
        1) count=5 price=100; (( balls > 999994 )) && return 0 ;;
        2) count=1 price=60; (( potions >= 999999 )) && return 0 ;;
        3) evolution_menu; return $? ;;
        *) return 0 ;;
    esac
    if (( gold < price )); then message='Za mało monet'; return 0; fi
    gold=$((gold-price))
    if (( count == 5 )); then balls=$((balls+5)); else potions=$((potions+1)); fi
    message='Zakup udany'
}
interact() {
    case ${map[y]:x:1} in
        C)
            heal_party
            if [[ ${terrain[area]} == town ]]; then checkpoint=$area; fi
            message='Drużyna wyleczona. Punktem powrotu jest ostatnie miejskie Centrum' ;;
        S) shop; return $? ;;
        G) gym; return $? ;;
        N) story_menu; return $? ;;
        P) pc_menu; return $? ;;
        T) trainer_team "${wild_pools[area]%% *}:$((wild_levels[area]+2))"; return $? ;;
        *) message='Stań na N (historia), G (sala), C (Centrum), P (PC), S (sklep) lub T (trener)' ;;
    esac
    return 0
}
move_player() {
    local nx=$((x+$1)) ny=$((y+$2)) tile level foe
    local -a pool
    if (( nx < 0 || nx > 20 || ny < 0 || ny > 8 )); then message='Tędy nie przejdziesz'; return 0; fi
    tile=${map[ny]:nx:1}
    case $tile in
        '#') message='Droga zablokowana'; return 0 ;;
        '<'|'>') world_menu; return $? ;;
        '~') if ! requirements_met safari,b5; then message='Woda wymaga Surf i odznaki Kogi'; return 0; fi ;;
    esac
    x=$nx y=$ny; message=''
    if [[ $tile == : || $tile == '~' ]] && (( RANDOM % 100 < 25 )); then
        read -r -a pool <<< "${wild_pools[area]}"
        foe=${pool[RANDOM % ${#pool[@]}]}
        level=$((wild_levels[area] + RANDOM%4))
        battle "$foe" "$level" wild; return $?
    fi
    return 0
}
release_pokemon() {
    local index i
    if (( ${#party_id[@]} == 1 )); then message='Ostatni Pokémon zostaje z Tobą'; return 0; fi
    show_party
    ask 'Wypuść Pokémona: numer (0: powrót): ' || return 2
    case $REPLY in [1-6]) index=$((REPLY-1)) ;; *) return 0 ;; esac
    (( index < ${#party_id[@]} )) || return 0
    # Keep at least one conscious Pokémon in the team.
    for ((i=0; i<${#party_id[@]}; i++)); do
        if (( i != index && party_hp[i] > 0 )); then break; fi
    done
    if (( i == ${#party_id[@]} )); then message='To jedyny przytomny Pokémon'; return 0; fi
    ask "Wypuścić ${names[${party_id[index]}]}? [t/n]: " || return 2
    [[ $REPLY == t ]] || return 0
    unset 'party_id[index]' 'party_lv[index]' 'party_xp[index]' 'party_hp[index]'
    party_id=("${party_id[@]}") party_lv=("${party_lv[@]}") party_xp=("${party_xp[@]}") party_hp=("${party_hp[@]}")
    first_alive; message='Pokémon wrócił na wolność'
}

# Embedded module: save
# Versioned, validated data files. No saved text is evaluated as shell code.
valid_number() { [[ $1 =~ ^(0|[1-9][0-9]{0,5})$ ]]; }
valid_monster() {
    local sid=$1 lv=$2 xp=$3 hp=$4 value
    for value in "$@"; do valid_number "$value" || return 1; done
    (( sid>=1 && sid<=151 && lv>=1 && lv<=100 && xp<lv*12 && (lv<100 || xp==0) && hp<=20+lv*3 ))
}
write_save_data() {
    local i key
    printf 'POKEBASH|2\n' || return 1
    printf 'STATE|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n' "$area" "$x" "$y" "$gold" "$balls" "$potions" "$badges" "$champion" "$active" "$starter" "$checkpoint" "$masterballs" "$fossil_id" || return 1
    for key in "${!flags[@]}"; do
        if [[ ${flags[$key]} == 1 ]]; then printf 'F|%s\n' "$key" || return 1; fi
    done
    for key in "${!owned[@]}"; do printf 'D|%s\n' "$key" || return 1; done
    for ((i=0;i<${#party_id[@]};i++)); do printf 'P|%s|%s|%s|%s\n' "${party_id[i]}" "${party_lv[i]}" "${party_xp[i]}" "${party_hp[i]}" || return 1; done
    for ((i=0;i<${#box_id[@]};i++)); do printf 'B|%s|%s|%s|%s\n' "${box_id[i]}" "${box_lv[i]}" "${box_xp[i]}" "${box_hp[i]}" || return 1; done
    return 0
}
save_game() {
    local dir tmp
    [[ ! -d $save_file ]] || return 1
    dir=$(dirname -- "$save_file")
    mkdir -p -- "$dir" || return 1
    tmp=$(mktemp "$dir/.pokemon-save.XXXXXX") || return 1
    if ! write_save_data > "$tmp"; then rm -f -- "$tmp"; return 1; fi
    if ! mv -f -- "$tmp" "$save_file"; then rm -f -- "$tmp"; return 1; fi
}
valid_flag() {
    local key=$1 index
    [[ $key =~ ^[a-z][a-z0-9_]{0,31}$ ]] || return 1
    if [[ -n ${event_area[$key]+exists} ]]; then return 0; fi
    [[ $key =~ ^gym[1-8]$ ]] && return 0
    if [[ $key =~ ^visit(0|[1-9][0-9]?)$ ]]; then
        index=${key#visit}; (( index<${#towns[@]} )); return $?
    fi
    return 1
}
valid_position() (
    area=$1 x=$2 y=$3
    set_map
    [[ ${map[y]:x:1} != '#' ]]
)
load_v2() {
    local state line tag key sid lv xp hp value rows=0 alive=0 badge_count=0 i
    local a sx sy g b p bd ch ac st cp mb fossil
    local -a fields ids=() levels=() experience=() health=() bids=() blvs=() bxps=() bhps=()
    local -A fs=() ds=()
    IFS= read -r state || return 1
    [[ $state =~ ^STATE(\|[0-9]+){13}$ ]] || return 1
    IFS='|' read -r -a fields <<< "$state"
    for value in "${fields[@]:1}"; do valid_number "$value" || return 1; done
    IFS='|' read -r tag a sx sy g b p bd ch ac st cp mb fossil <<< "$state"
    (( a<${#towns[@]} && sx<=20 && sy<=8 && bd<=8 && ch<=1 && ac<6 && cp<${#towns[@]} && mb<=1 )) || return 1
    [[ $st == 1 || $st == 4 || $st == 7 ]] || return 1
    [[ $fossil == 0 || $fossil == 138 || $fossil == 140 ]] || return 1
    [[ ${terrain[cp]} == town ]] || return 1
    valid_position "$a" "$sx" "$sy" || return 1
    while IFS= read -r line || [[ -n $line ]]; do
        rows=$((rows+1)); (( rows<=700 && ${#line}<=128 )) || return 1
        case $line in
            F\|*)
                key=${line#F|}; valid_flag "$key" || return 1
                [[ -z ${fs[$key]+exists} ]] || return 1
                fs[$key]=1 ;;
            D\|*)
                key=${line#D|}; valid_number "$key" || return 1
                (( key>=1 && key<=151 )) || return 1
                [[ -z ${ds[$key]+exists} ]] || return 1
                ds[$key]=1 ;;
            P\|*|B\|*)
                [[ $line =~ ^[PB](\|[0-9]+){4}$ ]] || return 1
                IFS='|' read -r tag sid lv xp hp <<< "$line"
                valid_monster "$sid" "$lv" "$xp" "$hp" || return 1
                if [[ $tag == P ]]; then
                    (( ${#ids[@]}<6 )) || return 1
                    ids+=("$sid"); levels+=("$lv"); experience+=("$xp"); health+=("$hp")
                    (( hp>0 )) && alive=1
                else
                    (( ${#bids[@]}<300 )) || return 1
                    bids+=("$sid"); blvs+=("$lv"); bxps+=("$xp"); bhps+=("$hp")
                fi ;;
            *) return 1 ;;
        esac
    done
    (( alive && ac<${#ids[@]} )) || return 1
    for sid in "${ids[@]}" "${bids[@]}"; do [[ ${ds[$sid]:-0} == 1 ]] || return 1; done
    for ((i=1;i<=8;i++)); do [[ ${fs[gym$i]:-0} == 1 ]] && badge_count=$((badge_count+1)); done
    (( badge_count==bd && (ch==0 || bd==8) )) || return 1
    if [[ ${fs[moon]:-0} == 1 ]] && (( fossil==0 )); then return 1; fi
    # Only now mutate live state.
    area=$a x=$sx y=$sy gold=$g balls=$b potions=$p badges=$bd champion=$ch active=$ac starter=$st checkpoint=$cp masterballs=$mb fossil_id=$fossil
    party_id=("${ids[@]}") party_lv=("${levels[@]}") party_xp=("${experience[@]}") party_hp=("${health[@]}")
    box_id=("${bids[@]}") box_lv=("${blvs[@]}") box_xp=("${bxps[@]}") box_hp=("${bhps[@]}")
    flags=() owned=()
    for key in "${!fs[@]}"; do flags[$key]=1; done
    for key in "${!ds[@]}"; do owned[$key]=1; done
    if (( party_hp[active]==0 )); then first_alive; fi
    set_map; message='Wczytano drużynę, PC i dziennik'
}
load_v1() {
    local state line value old new sid lv xp hp a sx sy g b p bd ch count=0 alive=0 i
    local -a fields ids=() levels=() experience=() health=()
    local -A legacy=()
    while IFS=$'\t' read -r old new; do legacy[$old]=$new; done <<'POKEBASH_LEGACY_IDS_TSV'
1	1
2	2
3	3
4	4
5	5
6	6
7	7
8	8
9	9
10	10
11	11
12	12
13	13
14	14
15	15
16	16
17	17
18	18
19	19
20	20
21	25
22	27
23	28
24	32
25	33
26	35
27	37
28	39
29	41
30	42
31	43
32	44
33	50
34	51
35	52
36	53
37	54
38	55
39	58
40	63
41	64
42	66
43	67
44	74
45	75
46	92
47	93
48	95
49	96
50	97
51	100
52	101
53	104
54	105
55	109
56	110
57	111
58	112
59	116
60	117
61	120
62	123
63	124
64	125
65	126
66	127
67	128
68	129
69	130
70	131
71	133
72	143
73	147
74	148
75	149
76	150
POKEBASH_LEGACY_IDS_TSV
    IFS= read -r state || return 1
    [[ $state =~ ^[0-9]+(\|[0-9]+){7}$ ]] || return 1
    IFS='|' read -r -a fields <<< "$state"
    for value in "${fields[@]}"; do valid_number "$value" || return 1; done
    IFS='|' read -r a sx sy g b p bd ch <<< "$state"
    (( a<=9 && sx<=20 && sy<=8 && bd<=8 && ch<=1 && a<=bd+1 && (ch==0 || bd==8) )) || return 1
    (( sy>0 && sy<8 && (sx>0 && sx<20 || sy==4) )) || return 1
    while IFS= read -r line || [[ -n $line ]]; do
        (( count<6 )) || return 1
        [[ $line =~ ^[0-9]+(\|[0-9]+){3}$ ]] || return 1
        IFS='|' read -r sid lv xp hp <<< "$line"
        valid_monster "$sid" "$lv" "$xp" "$hp" || return 1
        (( sid<=76 )) || return 1
        ids+=("${legacy[$sid]}"); levels+=("$lv"); experience+=("$xp"); health+=("$hp"); count=$((count+1))
        (( hp>0 )) && alive=1
    done
    (( count>0 && alive )) || return 1
    area=0 x=10 y=4 gold=$g balls=$b potions=$p badges=$bd champion=$ch active=0 checkpoint=0 masterballs=0 fossil_id=0 starter=1
    party_id=("${ids[@]}") party_lv=("${levels[@]}") party_xp=("${experience[@]}") party_hp=("${health[@]}")
    if (( party_id[0]<=9 )); then starter=$(( (party_id[0]-1)/3*3+1 )); fi
    flags=() owned=() box_id=() box_lv=() box_xp=() box_hp=()
    flags[visit0]=1
    for ((i=1;i<=bd;i++)); do flags[gym$i]=1; done
    for sid in "${ids[@]}"; do owned[$sid]=1; done
    first_alive; set_map
    message='Zaimportowano zapis 1.0. Drużyna i odznaki zachowane. Nowa fabuła zaczyna się u Oaka'
}
load_game() {
    local header
    [[ -f $save_file && -r $save_file ]] || return 1
    {
        IFS= read -r header || return 1
        case $header in
            'POKEBASH|2') load_v2; return $? ;;
            'POKEBASH|1') load_v1; return $? ;;
            *) return 1 ;;
        esac
    } < "$save_file"
}
# End module: save
render() {
    local row text
    if [[ -t 1 && ${TERM:-dumb} != dumb && -z ${NO_COLOR:-} ]]; then printf '\033[2J\033[H'; fi
    printf '\nPOKÉMON: BASH RED %s | %s | Odznaki %s/8\n' "$VERSION" "${towns[area]}" "$badges"
    for ((row=0; row<${#map[@]}; row++)); do
        text=${map[row]}
        (( row == y )) && text="${text:0:x}@${text:x+1}"
        printf '%s\n' "$text"
    done
    printf '@ Ty | : trawa | N historia | C Centrum | P PC | S sklep | G sala | T trener | < > drogi\n'
    printf 'Monety %s | Kule %s | Mikstury %s\n%s\n' "$gold" "$balls" "$potions" "$message"
    printf 'WASD + Enter: ruch | e: akcja | p: drużyna | r: wypuść | j: dziennik | m: Kanto | k: Pokédex | i: plecak | f: Fly | h: pomoc | q: zapisz i wyjdź\n'
}
help_game() {
    printf '%s\n' 'WASD + Enter: ruch. < i >: wybór sąsiedniej lokacji.' \
        'Stań na N i naciśnij e, aby porozmawiać i rozpocząć wydarzenie.' \
        'j: dziennik; m: lokacje; k: Pokédex; i: plecak; f: Fly.' \
        'G: sale i Liga. C: leczenie. P: PC. S: sklep i ewolucje. T: trening.' \
        'Walka: 1 normalny atak, 2 pierwszy typ, 7 drugi typ, 3 kula, 8 Master Ball.' \
        '4 mikstura, 5 zmiana, 6 ucieczka (tylko dzikie walki).' \
        'Przy pełnej drużynie złapany Pokémon trafia do PC.' \
        'Zapis po każdej komendzie i etapie fabuły. q: zapisz i zakończ.'
}
main() {
    local mode=auto command result selected
    save_file=${BASH_POKEMON_SAVE:-${XDG_DATA_HOME:-$HOME/.local/share}/bash-pokemon/save.dat}
    while (( $# )); do
        case $1 in
            --new) mode=new ;;
            --load) mode=load ;;
            --save) shift; if (( $# == 0 )) || [[ -z $1 ]]; then printf 'Podaj ścieżkę zapisu\n' >&2; return 1; fi; save_file=$1 ;;
            --help|-h) printf 'Użycie: bash bash_pokemon.sh [--new|--load] [--save PLIK]\n'; help_game; return 0 ;;
            --version) printf '%s\n' "$VERSION"; return 0 ;;
            *) printf 'Nieznana opcja: %s\n' "$1" >&2; return 1 ;;
        esac
        shift
    done
    if [[ $mode != new && -e $save_file ]]; then
        if ! load_game; then printf 'Nieprawidłowy zapis: %s. Zachowano plik. Użyj --new, aby zacząć od nowa\n' "$save_file" >&2; return 1; fi
    elif [[ $mode == load ]]; then
        printf 'Nie znaleziono zapisu: %s\n' "$save_file" >&2; return 1
    else
        if [[ -e $save_file ]]; then
            ask 'Zastąpić istniejący zapis nową grą? [t/n]: ' || return 0
            [[ $REPLY == t ]] || return 0
        fi
        printf 'POKÉMON: BASH RED\n[1] Bulbasaur (trawa) [2] Charmander (ogień) [3] Squirtle (woda)\n'
        while :; do
            ask 'Wybierz startera: ' || return 0
            case $REPLY in 1) selected=1; break ;; 2) selected=4; break ;; 3) selected=7; break ;; *) printf 'Wybierz 1, 2 lub 3\n' ;; esac
        done
        new_game "$selected"
    fi
    save_game || { printf 'Nie można zapisać gry: %s\n' "$save_file" >&2; return 1; }
    while :; do
        render
        ask '> ' || break
        command=$REPLY result=0
        case $command in
            w|W) move_player 0 -1; result=$? ;;
            s|S) move_player 0 1; result=$? ;;
            a|A) move_player -1 0; result=$? ;;
            d|D) move_player 1 0; result=$? ;;
            e|E) interact; result=$? ;;
            p|P) choose_active; result=$? ;;
            r|R) release_pokemon; result=$? ;;
            j|J) journal; ask 'Enter: powrót ' || result=2 ;;
            m|M) world_overview; ask 'Enter: powrót ' || result=2 ;;
            k|K) pokedex_menu; ask 'Enter: powrót ' || result=2 ;;
            i|I) bag_menu; ask 'Enter: powrót ' || result=2 ;;
            f|F) fly_menu; result=$? ;;
            h|H) help_game; ask 'Enter: powrót ' || result=2 ;;
            q|Q) break ;;
            *) message='Nieznana komenda. h: pomoc' ;;
        esac
        save_game || { printf 'Błąd zapisu: %s\n' "$save_file" >&2; return 1; }
        (( result == 2 )) && break
    done
    save_game || { printf 'Błąd zapisu: %s\n' "$save_file" >&2; return 1; }
    printf '\nZapisano grę: %s\n' "$save_file"
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    set -uo pipefail
    main "$@"
fi
