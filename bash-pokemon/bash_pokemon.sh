#!/usr/bin/env bash
# Pokémon: Bash Red 1.1.0. Bash 4.4+, no external game runtime.
if (( BASH_VERSINFO[0] < 4 || BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 4 )); then
    printf 'Wymagany Bash 4.4 lub nowszy\n' >&2
    exit 1
fi

VERSION=1.1.0
GAME_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
declare -a names types types2 evolutions evolve_at map
while IFS=$'\t' read -r id name type second evolution condition; do
    names[id]=$name types[id]=$type types2[id]=$second evolutions[id]=$evolution evolve_at[id]=$condition
done < "$GAME_ROOT/data/species.tsv"
unset id name type second evolution condition
source "$GAME_ROOT/lib/world.sh"
source "$GAME_ROOT/lib/story.sh"
source "$GAME_ROOT/lib/collection.sh"
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

source "$GAME_ROOT/lib/save.sh"
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
