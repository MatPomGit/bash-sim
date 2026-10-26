#!/usr/bin/env bash
# Pokémon: Bash Red 1.0.0. Bash 4.0+, no external game runtime.
if (( BASH_VERSINFO[0] < 4 )); then
    printf 'Wymagany Bash 4 lub nowszy\n' >&2
    exit 1
fi

VERSION=1.0.0
declare -a names types evolutions evolve_at
# id|name|type|evolution id|evolution level
while IFS='|' read -r id name type evolution threshold; do
    names[id]=$name types[id]=$type evolutions[id]=$evolution evolve_at[id]=$threshold
done <<'SPECIES'
1|Bulbasaur|grass|2|16
2|Ivysaur|grass|3|32
3|Venusaur|grass|0|0
4|Charmander|fire|5|16
5|Charmeleon|fire|6|36
6|Charizard|fire|0|0
7|Squirtle|water|8|16
8|Wartortle|water|9|36
9|Blastoise|water|0|0
10|Caterpie|bug|11|7
11|Metapod|bug|12|10
12|Butterfree|bug|0|0
13|Weedle|bug|14|7
14|Kakuna|bug|15|10
15|Beedrill|bug|0|0
16|Pidgey|flying|17|18
17|Pidgeotto|flying|18|36
18|Pidgeot|flying|0|0
19|Rattata|normal|20|20
20|Raticate|normal|0|0
21|Pikachu|electric|0|0
22|Sandshrew|ground|23|22
23|Sandslash|ground|0|0
24|Nidoran|poison|25|16
25|Nidorino|poison|0|0
26|Clefairy|normal|0|0
27|Vulpix|fire|0|0
28|Jigglypuff|normal|0|0
29|Zubat|flying|30|22
30|Golbat|flying|0|0
31|Oddish|grass|32|21
32|Gloom|grass|0|0
33|Diglett|ground|34|26
34|Dugtrio|ground|0|0
35|Meowth|normal|36|28
36|Persian|normal|0|0
37|Psyduck|water|38|33
38|Golduck|water|0|0
39|Growlithe|fire|0|0
40|Abra|psychic|41|16
41|Kadabra|psychic|0|0
42|Machop|fighting|43|28
43|Machoke|fighting|0|0
44|Geodude|rock|45|25
45|Graveler|rock|0|0
46|Gastly|ghost|47|25
47|Haunter|ghost|0|0
48|Onix|rock|0|0
49|Drowzee|psychic|50|26
50|Hypno|psychic|0|0
51|Voltorb|electric|52|30
52|Electrode|electric|0|0
53|Cubone|ground|54|28
54|Marowak|ground|0|0
55|Koffing|poison|56|35
56|Weezing|poison|0|0
57|Rhyhorn|ground|58|42
58|Rhydon|ground|0|0
59|Horsea|water|60|32
60|Seadra|water|0|0
61|Staryu|water|0|0
62|Scyther|bug|0|0
63|Jynx|ice|0|0
64|Electabuzz|electric|0|0
65|Magmar|fire|0|0
66|Pinsir|bug|0|0
67|Tauros|normal|0|0
68|Magikarp|water|69|20
69|Gyarados|water|0|0
70|Lapras|ice|0|0
71|Eevee|normal|0|0
72|Snorlax|normal|0|0
73|Dratini|dragon|74|30
74|Dragonair|dragon|75|55
75|Dragonite|dragon|0|0
76|Mewtwo|psychic|0|0
SPECIES
unset id name type evolution threshold

towns=('Pallet Town' 'Pewter City' 'Cerulean City' 'Vermilion City' 'Celadon City' 'Fuchsia City' 'Saffron City' 'Cinnabar Island' 'Viridian City' 'Indigo Plateau')
leaders=('' Brock Misty 'Lt. Surge' Erika Koga Sabrina Blaine Giovanni)
gym_teams=('' '44:10 48:12' '37:16 61:18' '51:21 21:24' '32:27 3:29' '55:32 56:34' '50:37 41:39' '39:41 65:43' '54:45 58:47')
wild_pools=('10 13 16 19' '10 16 21 44 22' '31 37 40 24' '33 49 51 35' '27 71 62 66' '55 59 68 42' '46 53 63 64' '39 65 70 61' '57 67 72 73' '69 74 75')
# Each tile is one character; exit tiles are at (0,4) and (20,4).
map=(
    '#####################'
    '#...................#'
    '#.........G.........#'
    '#...................#'
    '<...C..........S....>'
    '#..::::...::::::....#'
    '#..::::...::::::....#'
    '#...................#'
    '#####################'
)
declare -a party_id party_lv party_xp party_hp
area=0 x=4 y=4 gold=500 balls=10 potions=5 badges=0 champion=0
active=0 message='' save_file=''

max_hp() { REPLY=$((20 + $1 * 3)); }
new_game() {
    local starter=$1
    area=0 x=4 y=4 gold=500 balls=10 potions=5 badges=0 champion=0 active=0
    party_id=("$starter") party_lv=(5) party_xp=(0) party_hp=(35)
    message='Profesor Oak: zdobądź osiem odznak i pokonaj Ligę!'
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
    gold=$((gold / 2)); x=4 y=4
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
        if (( next > 0 && party_lv[index] >= evolve_at[${party_id[index]}] )); then
            party_id[index]=$next
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
    local level=$1 attack_type=$2 defense_type=$3 power=$4 multiplier
    effectiveness "$attack_type" "$defense_type"; multiplier=$REPLY
    REPLY=$(((3 + level * power / 12 + RANDOM % 4) * multiplier / 2))
    if (( multiplier > 0 && REPLY == 0 )); then REPLY=1; fi
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
    max_hp "$level"; enemy_hp=$REPLY enemy_max=$REPLY
    if (( active < 0 || active >= ${#party_id[@]} )); then active=0; fi
    if (( party_hp[active] == 0 )); then
        first_alive || { blackout; return 1; }
    fi
    printf '\n%s, poziom %s!\n' "${names[foe]}" "$level"
    while (( enemy_hp > 0 )); do
        printf '\n%s HP %s/%s | %s HP %s\n' "${names[foe]}" "$enemy_hp" "$enemy_max" "${names[${party_id[active]}]}" "${party_hp[active]}"
        ask '[1] Atak [2] Atak typu [3] Kula [4] Mikstura [5] Zmiana [6] Ucieczka: ' || return 2
        choice=$REPLY
        case $choice in
            1|2)
                attack_type=normal power=8
                if [[ $choice == 2 ]]; then attack_type=${types[${party_id[active]}]}; power=10; fi
                damage "${party_lv[active]}" "$attack_type" "${types[foe]}" "$power"; hit=$REPLY
                enemy_hp=$((enemy_hp-hit)); (( enemy_hp < 0 )) && enemy_hp=0
                printf 'Atak (%s): %s obrażeń\n' "$attack_type" "$hit"
                ;;
            3)
                if [[ $mode != wild ]]; then printf 'Nie można łapać Pokémonów trenera\n'; continue; fi
                if (( ${#party_id[@]} == 6 )); then printf 'Drużyna pełna. Zwolnij miejsce poza walką [r]\n'; continue; fi
                if (( balls == 0 )); then printf 'Brak kul\n'; continue; fi
                balls=$((balls-1)); catch_chance "$enemy_hp" "$enemy_max"; chance=$REPLY
                if (( RANDOM % 100 < chance )); then
                    party_id+=("$foe"); party_lv+=("$level"); party_xp+=(0); party_hp+=("$enemy_hp")
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
                if (( RANDOM % 100 < 75 )); then message='Ucieczka udana'; return 0; fi
                printf 'Nie udało się uciec\n'
                ;;
            *) printf 'Wybierz 1–6\n'; continue ;;
        esac
        if (( enemy_hp == 0 )); then
            gain_xp "$active" "$((level*10))"
            gold=$((gold+level*15)); (( gold > 999999 )) && gold=999999
            message="Pokonano ${names[foe]}! +$((level*10)) XP, +$((level*15)) monet"
            printf '%s\n' "$message"; return 0
        fi
        damage "$level" "${types[foe]}" "${types[${party_id[active]}]}" 8; hit=$REPLY
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
gym() {
    local result
    if (( area == 0 )); then message='Laboratorium Oaka. Cel: osiem odznak, potem Liga'; return 0; fi
    if (( area == 9 )); then league; return $?; fi
    if (( badges >= area )); then message='Odznaka tej sali jest już Twoja'; return 0; fi
    if (( badges != area-1 )); then message='Najpierw zdobądź wcześniejsze odznaki'; return 0; fi
    ask "${leaders[area]}: podejmujesz wyzwanie? [t/n]: " || return 2
    [[ $REPLY == t ]] || return 0
    trainer_team "${gym_teams[area]}"; result=$?
    if (( result == 0 )); then badges=$((badges+1)); message="${leaders[area]} pokonany! Odznaki: $badges/8"; fi
    return "$result"
}
league() {
    local team result
    if (( champion )); then message='Jesteś mistrzem Kanto! Na trawie płaskowyżu czeka Mewtwo'; return 0; fi
    if (( badges < 8 )); then message='Liga wymaga ośmiu odznak'; return 0; fi
    ask 'Liga: pięć walk bez leczenia w Centrum. Zaczynamy? [t/n]: ' || return 2
    [[ $REPLY == t ]] || return 0
    for team in '63:48 70:50' '48:49 43:51' '47:50 30:52' '69:52 74:54 75:55' '18:54 58:55 41:56 9:57'; do
        trainer_team "$team"; result=$?
        (( result != 0 )) && return "$result"
    done
    champion=1; message='Gratulacje! Jesteś mistrzem Ligi Pokémon!'
}
shop() {
    local count price
    ask "Sklep | Monety: $gold | [1] 5 kul: 100 [2] Mikstura: 60 [0] Powrót: " || return 2
    case $REPLY in
        1) count=5 price=100; (( balls > 999994 )) && return 0 ;;
        2) count=1 price=60; (( potions >= 999999 )) && return 0 ;;
        *) return 0 ;;
    esac
    if (( gold < price )); then message='Za mało monet'; return 0; fi
    gold=$((gold-price))
    if (( count == 5 )); then balls=$((balls+5)); else potions=$((potions+1)); fi
    message='Zakup udany'
}
interact() {
    case ${map[y]:x:1} in
        C) heal_party; message='Drużyna wyleczona bez opłat' ;;
        S) shop; return $? ;;
        G) gym; return $? ;;
        *) message='Stań na C (Centrum), S (sklep) albo G (sala / Liga)' ;;
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
        '<')
            if (( area == 0 )); then message='Tu zaczyna się podróż'; return 0; fi
            area=$((area-1)); nx=19 ;;
        '>')
            if (( area == 9 )); then message='Koniec szlaku'; return 0; fi
            if (( area > 0 && badges < area )); then message='Pokonaj lidera tej sali, aby iść dalej'; return 0; fi
            area=$((area+1)); nx=1 ;;
    esac
    x=$nx y=$ny; message=''
    if [[ $tile == : ]] && (( RANDOM % 100 < 25 )); then
        read -r -a pool <<< "${wild_pools[area]}"
        foe=${pool[RANDOM % ${#pool[@]}]}
        level=$((3 + area*5 + RANDOM%4))
        (( champion && area == 9 && RANDOM % 4 == 0 )) && foe=76
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

save_game() {
    local dir tmp i
    [[ ! -d $save_file ]] || return 1
    dir=$(dirname -- "$save_file")
    mkdir -p -- "$dir" || return 1
    tmp=$(mktemp "$dir/.pokemon-save.XXXXXX") || return 1
    if ! {
        printf 'POKEBASH|1\n'
        printf '%s|%s|%s|%s|%s|%s|%s|%s\n' "$area" "$x" "$y" "$gold" "$balls" "$potions" "$badges" "$champion"
        for ((i=0; i<${#party_id[@]}; i++)); do
            printf '%s|%s|%s|%s\n' "${party_id[i]}" "${party_lv[i]}" "${party_xp[i]}" "${party_hp[i]}"
        done
    } > "$tmp"; then rm -f -- "$tmp"; return 1; fi
    if ! mv -f -- "$tmp" "$save_file"; then rm -f -- "$tmp"; return 1; fi
}
valid_number() { [[ $1 =~ ^(0|[1-9][0-9]{0,5})$ ]]; }
load_game() {
    local header state line value a sx sy g b p bd ch sid lv xp hp extra count=0
    local -a fields ids=() levels=() experience=() health=()
    [[ -f $save_file && -r $save_file ]] || return 1
    # Parse into temporary arrays. Never execute saved data; commit only after validation.
    {
        IFS= read -r header && [[ $header == 'POKEBASH|1' ]] || return 1
        IFS= read -r state || return 1
        [[ $state =~ ^[0-9]+(\|[0-9]+){7}$ ]] || return 1
        IFS='|' read -r -a fields <<< "$state"
        for value in "${fields[@]}"; do valid_number "$value" || return 1; done
        IFS='|' read -r a sx sy g b p bd ch <<< "$state"
        (( a<=9 && sx<=20 && sy<=8 && bd<=8 && ch<=1 && a<=bd+1 && (ch==0 || bd==8) )) || return 1
        [[ ${map[sy]:sx:1} != '#' ]] || return 1
        while IFS= read -r line || [[ -n $line ]]; do
            (( count < 6 )) || return 1
            [[ $line =~ ^[0-9]+(\|[0-9]+){3}$ ]] || return 1
            IFS='|' read -r sid lv xp hp extra <<< "$line"
            for value in "$sid" "$lv" "$xp" "$hp"; do valid_number "$value" || return 1; done
            (( sid>=1 && sid<=76 && lv>=1 && lv<=100 && xp<lv*12 && (lv<100 || xp==0) && hp<=20+lv*3 )) || return 1
            ids+=("$sid"); levels+=("$lv"); experience+=("$xp"); health+=("$hp"); count=$((count+1))
        done
    } < "$save_file"
    (( count > 0 )) || return 1
    local alive=0
    for hp in "${health[@]}"; do (( hp>0 )) && alive=1; done
    (( alive )) || return 1
    area=$a x=$sx y=$sy gold=$g balls=$b potions=$p badges=$bd champion=$ch
    party_id=("${ids[@]}") party_lv=("${levels[@]}") party_xp=("${experience[@]}") party_hp=("${health[@]}")
    first_alive; message='Wczytano zapis'
}
render() {
    local row text
    if [[ -t 1 && ${TERM:-dumb} != dumb && -z ${NO_COLOR:-} ]]; then printf '\033[2J\033[H'; fi
    printf '\nPOKÉMON: BASH RED %s | %s | Odznaki %s/8\n' "$VERSION" "${towns[area]}" "$badges"
    for ((row=0; row<${#map[@]}; row++)); do
        text=${map[row]}
        (( row == y )) && text="${text:0:x}@${text:x+1}"
        printf '%s\n' "$text"
    done
    printf '@ Ty | : trawa | C Centrum | S sklep | G sala | < > szlak\n'
    printf 'Monety %s | Kule %s | Mikstury %s\n%s\n' "$gold" "$balls" "$potions" "$message"
    printf 'WASD + Enter: ruch | e: akcja | p: drużyna | r: wypuść | h: pomoc | q: zapisz i wyjdź\n'
}
help_game() {
    printf '%s\n' 'Wybierz startera. Walcz w trawie, zdobywaj XP i łap Pokémony.' \
        'Osłab przeciwnika, aby zwiększyć szansę złapania. Drużyna: do 6 Pokémonów.' \
        'Atak 1 jest normalny, atak 2 korzysta z typu Twojego Pokémona.' \
        'Zmiana i mikstura zużywają turę. Nieudany rzut kulą też zużywa turę.' \
        'Centrum C leczy bez opłat. Stań na znaku i naciśnij e.' \
        'Pokonuj liderów po kolei. Przejście > prowadzi do następnego miasta.' \
        'Po ośmiu odznakach czeka Liga. Kup mikstury przed wejściem.' \
        'Postęp zapisuje się po każdej komendzie poza walką. EOF kończy grę z zapisem.'
}
main() {
    local mode=auto command result starter
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
            case $REPLY in 1) starter=1; break ;; 2) starter=4; break ;; 3) starter=7; break ;; *) printf 'Wybierz 1, 2 lub 3\n' ;; esac
        done
        new_game "$starter"
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
