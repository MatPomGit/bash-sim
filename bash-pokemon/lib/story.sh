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
    ui_dialog "${event_title[$key]}" "${event_text[$key]}"
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
