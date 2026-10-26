#!/usr/bin/env bash
# Local regression tests. Each group runs in an isolated shell state.
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT
source "$ROOT/bash_pokemon.sh"
save_file=$TMP/save.dat
passed=0
check() {
    local label=$1
    shift
    printf 'TEST %s\n' "$label"
    ( set -e; "$@" )
    passed=$((passed+1)); printf 'PASS %s\n' "$label"
}
eq() { [[ $1 == "$2" ]] || { printf 'Expected <%s>, got <%s>\n' "$2" "$1" >&2; return 1; }; }
expect_status() {
    local expected=$1 result=0
    shift
    "$@" || result=$?
    eq "$result" "$expected"
}
snapshot() {
    declare -p area x y gold balls potions badges champion active starter checkpoint masterballs fossil_id \
        party_id party_lv party_xp party_hp box_id box_lv box_xp box_hp flags owned map
}
fill_party() {
    local sid
    for sid in 4 7 10 13 16; do add_pokemon "$sid" 5 >/dev/null; done
}

species_test() {
    local id name first second next condition count=0 old new previous=0 seen next_id n
    declare -A legacy=()
    eq "${#names[@]}" 151
    while IFS=$'\t' read -r id name first second next condition; do
        count=$((count+1)); eq "$id" "$count"
        [[ $name != *' '* && -n $name ]]
        for seen in "$first" "$second"; do
            case $seen in normal|fire|water|grass|electric|ice|fighting|poison|ground|flying|psychic|bug|rock|ghost|dragon|-) ;; *) return 1 ;; esac
        done
        (( next>=0 && next<=151 && next!=id ))
        if (( next>0 )); then [[ -n ${names[next]} ]]; fi
        case $condition in -|trade|eevee|stone:fire|stone:water|stone:leaf|stone:moon|stone:thunder) ;; *) [[ $condition =~ ^[1-9][0-9]?$ ]] ;; esac
        seen=","; next_id=$id
        for ((n=0;n<151;n++)); do
            [[ $seen != *",$next_id,"* ]]; seen+="$next_id,"
            next_id=${evolutions[next_id]}; (( next_id==0 )) && break
        done
        eq "$next_id" 0
    done < "$ROOT/data/species.tsv"
    eq "$count" 151
    while IFS=$'\t' read -r old new; do
        eq "$old" "$((previous+1))"; previous=$old
        (( new>=1 && new<=151 )); legacy[$old]=$new
    done < "$ROOT/data/legacy_ids.tsv"
    eq "$previous" 76; eq "${legacy[21]}" 25; eq "${legacy[24]}" 32; eq "${legacy[76]}" 150
    eq "${types[81]}:${types2[81]}" electric:-
    eq "${types[35]}:${types2[35]}" normal:-
}
starters_test() {
    local s
    for s in 1 4 7; do
        new_game "$s"
        eq "${party_id[*]}" "$s"; eq "${party_hp[*]}" 35; eq "$starter" "$s"
        eq "${owned[$s]}:${flags[visit0]}" 1:1
        eq "$badges:$champion:${#box_id[@]}" 0:0:0
    done
}
evolution_test() {
    new_game 1; party_lv[0]=15 party_hp[0]=65
    gain_xp 0 180 >/dev/null
    eq "${party_id[0]}:${party_lv[0]}:${party_hp[0]}:${owned[2]}" 2:16:68:1
    party_lv[0]=99 party_hp[0]=317 party_xp[0]=0
    gain_xp 0 10000 >/dev/null
    eq "${party_id[0]}:${party_lv[0]}:${party_hp[0]}:${party_xp[0]}" 3:100:320:0
    new_game 1; add_pokemon 25 5 >/dev/null
    evolution_menu <<< $'2\nt' >/dev/null
    eq "${party_id[1]}:$gold:${owned[26]}" 26:200:1
    add_pokemon 64 16 >/dev/null
    evolution_menu <<< $'3\nt' >/dev/null
    eq "${party_id[2]}:$gold:${owned[65]}" 65:200:1
    add_pokemon 133 25 >/dev/null; gold=500
    evolution_menu <<< $'4\n2\nt' >/dev/null
    eq "${party_id[3]}:$gold:${owned[134]}" 134:200:1
    add_pokemon 37 15 >/dev/null
    evolution_menu <<< $'5\nt' >/dev/null
    eq "${party_id[4]}:$gold" 37:200
    gold=500; evolution_menu <<< $'5\nn' >/dev/null
    eq "${party_id[4]}:$gold" 37:500
}
types_test() {
    effectiveness fire grass; eq "$REPLY" 4
    effectiveness water grass; eq "$REPLY" 1
    damage 50 electric ground 10 flying; eq "$REPLY" 0
    damage 50 ground rock 10 flying; eq "$REPLY" 0
    local high low
    RANDOM=123; damage 50 ice dragon 10 flying; high=$REPLY
    RANDOM=123; damage 50 ice water 10 ice; low=$REPLY
    (( high>=16*low && low>0 ))
    damage 1 normal rock 1; (( REPLY>=1 ))
    catch_chance 100 100; eq "$REPLY" 20
    catch_chance 1 100; eq "$REPLY" 79
}
real_battle_test() {
    new_game 7; party_lv[0]=40; heal_party
    battle 4 5 wild <<< 2 >/dev/null
    eq "$battle_result:${party_xp[0]}:$gold" won:50:575
    new_game 1
    expect_status 1 battle 6 100 trainer <<< 1 >/dev/null
    eq "${party_hp[0]}:$gold:$area" 35:250:0
}
battle_input_test() {
    new_game 1
    expect_status 2 battle 4 5 trainer <<< $'3\n6\nxxx\n8' >/dev/null
    eq "$balls:${party_hp[0]}" 10:35
    add_pokemon 7 5 >/dev/null; active=1
    expect_status 2 battle 4 5 wild < /dev/null >/dev/null
    eq "$active" 1
    party_hp[1]=0
    expect_status 2 battle 4 5 wild < /dev/null >/dev/null
    eq "$active" 0
    # A missing second type and exhausted items do not consume a turn.
    new_game 7; balls=0 potions=0
    expect_status 2 battle 4 5 wild <<< $'7\n3\n4\n8\nxxx' >/dev/null
    eq "${party_hp[0]}" 35
}
capture_test() {
    new_game 1; fill_party; masterballs=1
    battle 150 70 wild <<< 8 >/dev/null
    eq "$battle_result:$masterballs:${#party_id[@]}:${box_id[0]}:${owned[150]}" caught:0:6:150:1
    # A guaranteed capture exercises the regular-ball branch without probabilistic failure.
    catch_chance() { REPLY=100; }
    battle 25 5 wild <<< 3 >/dev/null
    eq "$battle_result:$balls:${box_id[1]}" caught:9:25
    local i
    box_id=() box_lv=() box_xp=() box_hp=()
    for ((i=0;i<300;i++)); do add_pokemon 19 5 >/dev/null; done
    masterballs=1
    expect_status 2 battle 25 5 wild <<< $'3\n8' >/dev/null
    eq "$balls:$masterballs:${#box_id[@]}" 9:1:300
}
pc_test() {
    new_game 1
    pc_menu <<< $'1\n1' >/dev/null
    eq "${party_id[*]}:${#box_id[@]}" 1:0
    add_pokemon 4 5 >/dev/null; party_hp[1]=0
    pc_menu <<< $'1\n1' >/dev/null
    eq "${#party_id[@]}:${#box_id[@]}" 2:0
    pc_menu <<< $'1\n2' >/dev/null
    eq "${party_id[*]}:${box_id[*]}:${box_hp[*]}" 1:4:0
    pc_menu <<< $'2\n1' >/dev/null
    eq "${party_id[*]}:${#box_id[@]}" '1 4:0'
    new_game 1; fill_party; add_pokemon 25 10 >/dev/null
    pc_menu <<< $'2\n1\n2' >/dev/null
    eq "${party_id[1]}:${box_id[0]}:${#party_id[@]}" 25:4:6
    party_hp=(35 0 0 0 0 0); box_hp[0]=0
    pc_menu <<< $'2\n1\n1' >/dev/null
    eq "${party_id[0]}:${box_id[0]}" 1:4
    local before
    before=$(snapshot)
    pc_menu <<< $'2\n999' >/dev/null
    eq "$(snapshot)" "$before"
}
map_test() {
    local a row col index next pos nx ny tile
    declare -A visited=()
    local -a queue
    eq "${#towns[@]}" 54
    for ((a=0;a<${#towns[@]};a++)); do
        area=$a; set_map
        eq "${#map[@]}" 9
        for row in "${map[@]}"; do eq "${#row}" 21; done
        visited=([10:4]=1); queue=(10:4); index=0
        while (( index<${#queue[@]} )); do
            pos=${queue[index]}; col=${pos%:*}; row=${pos#*:}; index=$((index+1))
            for next in "$((col-1)):$row" "$((col+1)):$row" "$col:$((row-1))" "$col:$((row+1))"; do
                nx=${next%:*}; ny=${next#*:}
                (( nx>=0 && nx<=20 && ny>=0 && ny<=8 )) || continue
                [[ ${map[ny]:nx:1} != '#' && ${visited[$next]:-0} != 1 ]] || continue
                visited[$next]=1; queue+=("$next")
            done
        done
        for ((row=0;row<9;row++)); do
            for ((col=0;col<21;col++)); do
                tile=${map[row]:col:1}
                case $tile in N|C|S|P|G|T|'<'|'>') eq "${visited[$col:$row]:-0}" 1 ;; esac
            done
        done
        eq "${map[4]:10:1}" N
    done
}
gates_test() {
    new_game 1
    expect_status 1 requirements_met lab
    expect_status 1 requirements_met b2
    flags[gym5]=1; badges=1
    expect_status 1 requirements_met b2
    requirements_met b5
    flags[lab]=1; requirements_met lab
    local test_answer=1
    ask() { REPLY=$test_answer; }
    area=5; set_map
    world_menu >/dev/null; eq "$area" 4
    area=5; test_answer=2; set_map
    world_menu >/dev/null; eq "$area" 5
    flags[gym1]=1
    world_menu >/dev/null; eq "$area" 6
    area=15; flags[anne]=1; flags[bill]=1; test_answer=2; set_map
    world_menu >/dev/null; eq "$area" 15
}

fly_bag_water_test() {
    new_game 1
    area=5; set_map
    fly_menu <<< 1 >/dev/null; eq "$area" 5
    flags[fly]=1 flags[gym3]=1 flags[visit9]=1
    fly_menu <<< 2 >/dev/null; eq "$area:$x:$y" 9:4:4
    flags[anne]=1 flags[safari]=1 flags[scope]=1 flags[mansion]=1
    local output
    output=$(bag_menu)
    [[ $output == *'HM01 Cut'* && $output == *'HM03 Surf'* && $output == *'Silph Scope'* && $output == *'Secret Key'* ]]
    battle() { battle_result=won; return 0; }
    area=35 x=3 y=4; set_map
    move_player 0 1 >/dev/null
    eq "$x:$y" 3:4
    flags[gym5]=1
    move_player 0 1 >/dev/null
    eq "$x:$y" 3:5
}

# Travel with the real world menu through a BFS path containing only unlocked edges.
travel_to() {
    local target=$1 current=$area head=0 node next cursor choice step
    local -a queue=("$area") path=()
    local -A seen=([$area]=1) previous=()
    while (( head<${#queue[@]} )); do
        node=${queue[head]}; head=$((head+1))
        (( node==target )) && break
        for next in ${neighbors[$node]:-}; do
            [[ ${seen[$next]:-0} != 1 ]] || continue
            (( next==16 )) && [[ ${flags[anne]:-0} == 1 ]] && continue
            requirements_met "${edge_requirements[$node:$next]:-}" || continue
            seen[$next]=1; previous[$next]=$node; queue+=("$next")
        done
    done
    [[ ${seen[$target]:-0} == 1 ]] || return 1
    cursor=$target
    while (( cursor!=current )); do path=("$cursor" "${path[@]}"); cursor=${previous[$cursor]}; done
    for step in "${path[@]}"; do
        choice=0
        for next in ${neighbors[$area]:-}; do
            choice=$((choice+1)); (( next==step )) && break
        done
        travel_choice=$choice
        world_menu >/dev/null || return 1
        [[ $area == "$step" ]] || return 1
    done
    return 0
}
campaign_test() {
    new_game 1
    local key i rounds=0 progress remaining sid
    # Flash needs ten registered catches; grant real collection entries, not quest flags.
    for sid in 4 7 10 13 16 19 21 23 25; do add_pokemon "$sid" 5 >/dev/null; done
    battle() { battle_result=won; return 0; }
    ask() {
        case $1 in
            'Droga: '*) REPLY=$travel_choice ;;
            'Skamielina:'*|'Wybierz [1]'*) REPLY=1 ;;
            *) REPLY=t ;;
        esac
    }
    while (( rounds<30 )); do
        rounds=$((rounds+1)); progress=0
        for key in "${event_ids[@]}"; do
            [[ ${flags[$key]:-0} != 1 ]] || continue
            requirements_met "${event_need[$key]}" || continue
            if travel_to "${event_area[$key]}"; then
                run_story_event "$key" >/dev/null
                eq "${flags[$key]:-0}" 1; progress=1
            fi
        done
        for ((i=0;i<8;i++)); do
            [[ ${flags[gym$((i+1))]:-0} != 1 ]] || continue
            requirements_met "${gym_needs[i]}" || continue
            if travel_to "${gym_areas[i]}"; then
                gym >/dev/null
                eq "${flags[gym$((i+1))]:-0}" 1; progress=1
            fi
        done
        if (( !champion && badges==8 )) && requirements_met victory && travel_to 44; then
            league >/dev/null; eq "$champion" 1; progress=1
        fi
        (( progress>0 )) || break
    done
    remaining=''
    for key in "${event_ids[@]}"; do
        [[ ${flags[$key]:-0} == 1 ]] || remaining+=" $key"
    done
    [[ -z $remaining ]] || { printf 'Unreachable story events:%s\n' "$remaining" >&2; return 1; }
    eq "$badges:$champion" 8:1
    for ((i=0;i<${#towns[@]};i++)); do
        if [[ ${flags[visit$i]:-0} != 1 ]]; then travel_to "$i"; fi
        eq "${flags[visit$i]:-0}" 1
    done
    # Finished rewards and final battles cannot be repeated.
    local before
    before=$(snapshot)
    run_story_event silph >/dev/null
    eq "$(snapshot)" "$before"
    save_file=$TMP/campaign.dat; save_game
    new_game 4; load_game
    eq "$badges:$champion:${flags[mewtwo]}:${flags[gym8]}" 8:1:1:1
}
event_failures_test() {
    new_game 1; flags[lab]=1 flags[parcel]=1 flags[pokedex]=1 flags[gym1]=1
    area=7; set_map
    battle() { battle_result=ongoing; return 1; }
    expect_status 1 run_story_event moon <<< t >/dev/null
    eq "${flags[moon]:-0}:$fossil_id" 0:0
    battle() { battle_result=ongoing; return 2; }
    expect_status 2 run_story_event moon <<< t >/dev/null
    eq "${flags[moon]:-0}:$fossil_id" 0:0
    battle() { battle_result=won; return 0; }
    expect_status 2 run_story_event moon <<< t >/dev/null
    eq "${flags[moon]:-0}:$fossil_id" 0:0
    run_story_event moon <<< $'t\nx' >/dev/null
    eq "${flags[moon]:-0}:$fossil_id" 0:0
    area=18; flags[fuji]=1; set_map
    battle() { battle_result=fled; return 0; }
    run_story_event snorlax_east <<< t >/dev/null
    eq "${flags[snorlax_east]:-0}" 0
    area=34; flags[silph_rival]=1; set_map; masterballs=0
    battle() { return 1; }
    expect_status 1 run_story_event silph <<< t >/dev/null
    eq "${flags[silph]:-0}:$masterballs" 0:0
    # Losing the tutorial is the one intentional exception.
    new_game 7; battle() { party_hp[0]=0; return 1; }
    expect_status 0 run_story_event lab <<< t >/dev/null
    eq "${flags[lab]}:${party_hp[0]}" 1:35
}
gym_failures_order_test() {
    new_game 1; flags[moon]=1; area=9; set_map
    battle() { return 1; }
    expect_status 1 gym <<< t >/dev/null
    eq "$badges:${flags[gym2]:-0}" 0:0
    battle() { return 2; }
    expect_status 2 gym <<< t >/dev/null
    eq "$badges:${flags[gym2]:-0}" 0:0
    # Badge identity matters; Koga and Sabrina can be visited in either order.
    flags[fuji]=1 flags[silph]=1
    battle() { battle_result=won; return 0; }
    area=33; gym <<< t >/dev/null
    eq "$badges:${flags[gym6]}:${flags[gym5]:-0}" 1:1:0
    area=30; gym <<< t >/dev/null
    eq "$badges:${flags[gym6]}:${flags[gym5]}" 2:1:1
    gym <<< t >/dev/null; eq "$badges" 2
    new_game 1; flags[fuji]=1 flags[silph]=1
    area=30; gym <<< t >/dev/null
    area=33; gym <<< t >/dev/null
    eq "$badges:${flags[gym5]}:${flags[gym6]}" 2:1:1
    area=2; gym <<< t >/dev/null
    eq "${flags[gym8]:-0}" 0
}
save_roundtrip_test() {
    new_game 7; add_pokemon 25 12 19 50 >/dev/null; active=1
    flags[lab]=1 flags[gym2]=1 flags[visit9]=1 flags[moon]=1
    badges=1 area=9 x=7 y=6 checkpoint=9 masterballs=1 fossil_id=138 gold=123
    fill_party >/dev/null
    eq "${#box_id[@]}" 1
    owned[151]=1; set_map
    save_file=$TMP/roundtrip.dat; save_game
    local before
    before=$(snapshot)
    new_game 4; load_game
    eq "$(snapshot)" "$before"
    eq "$(head -n1 "$save_file")" 'POKEBASH|2'
    eq "$(stat -c '%a' "$save_file" 2>/dev/null || stat -f '%Lp' "$save_file")" 600
}
save_corruption_test() {
    new_game 1
    save_file=$TMP/corrupt.dat
    local baseline="$(snapshot)" content bad
    local good=$'POKEBASH|2\nSTATE|0|10|4|500|10|5|0|0|0|1|0|0|0\nF|visit0\nD|1\nP|1|5|0|35\n'
    for bad in \
        "${good/STATE|0/STATE|054}" \
        "${good/|500|/|0500|}" \
        "${good/STATE|0|10|4/STATE|0|0|0}" \
        "${good/P|1|5|0|35/P|152|5|0|35}" \
        "${good/P|1|5|0|35/P|1|5|0|999}" \
        "${good/P|1|5|0|35/P|1|5|0|0}" \
        "${good/P|1|5|0|35/P|1|5|60|35}" \
        "${good/F|visit0/F|visit99}" \
        "${good/F|visit0/F|execute_command}" \
        "${good/F|visit0/F|\$(touch SHOULD_NOT_EXIST)}" \
        "${good/D|1/D|01}" \
        "${good/D|1/D|2}" \
        "$good"$'F|visit0\n' \
        "$good"$'D|1\n' \
        "$good"$'F|gym1\n' \
        "$good"$'F|moon\n' \
        "$good"$'GARBAGE\n'; do
        printf '%s' "$bad" > "$save_file"
        if load_game; then printf 'Accepted invalid save: %s\n' "$bad" >&2; return 1; fi
        eq "$(snapshot)" "$baseline"
    done
    [[ ! -e SHOULD_NOT_EXIST ]]
    save_file=$TMP; expect_status 1 save_game
}
legacy_test() {
    save_file=$TMP/legacy.dat
    printf 'POKEBASH|1\n2|7|6|123|14|8|1|0\n7|16|42|60\n21|12|50|19\n76|70|0|230\n' > "$save_file"
    load_game
    eq "$area:$x:$y:$gold:$balls:$potions:$badges:$champion:$starter" 0:10:4:123:14:8:1:0:7
    eq "${party_id[*]}:${party_xp[*]}:${flags[gym1]}:${flags[visit0]}" '7 25 150:42 50 0:1:1'
    save_game; new_game 4; load_game
    eq "${party_id[*]}:$badges" '7 25 150:1'
    printf 'POKEBASH|1\n0|4|4|500|10|5|0|0\n77|5|0|35\n' > "$save_file"
    expect_status 1 load_game
}
cli_test() {
    local file="$TMP/cli save.dat"
    printf '2\nd\nj\n\np\n0\nq\n' | bash "$ROOT/bash_pokemon.sh" --new --save "$file" > "$TMP/cli.out"
    save_file=$file; load_game
    eq "${party_id[0]}:$x:$starter" 4:11:4
    bash "$ROOT/bash_pokemon.sh" --load --save "$file" < /dev/null > "$TMP/resume.out"
    grep -q 'Wczytano' "$TMP/resume.out"
    printf 'n\n' | bash "$ROOT/bash_pokemon.sh" --new --save "$file" >/dev/null
    load_game; eq "${party_id[0]}" 4
    printf 'CORRUPT\n' > "$file"
    expect_status 1 bash "$ROOT/bash_pokemon.sh" --save "$file" < /dev/null >/dev/null 2>&1
    eq "$(cat "$file")" CORRUPT
    expect_status 1 bash "$ROOT/bash_pokemon.sh" --save >/dev/null 2>&1
    expect_status 1 bash "$ROOT/bash_pokemon.sh" --load --save "$TMP/missing" >/dev/null 2>&1
    expect_status 1 bash "$ROOT/bash_pokemon.sh" --unknown >/dev/null 2>&1
    expect_status 1 bash "$ROOT/bash_pokemon.sh" --new --save "$TMP" <<< $'t\n1' >/dev/null 2>&1
    bash "$ROOT/bash_pokemon.sh" --help >/dev/null
    eq "$(bash "$ROOT/bash_pokemon.sh" --version)" 1.1.0
}
check '151 species, Gen I types, evolution graph and 76 legacy IDs' species_test
check 'three starters and clean new-game state' starters_test
check 'level, stone, Eevee and trade evolutions; level cap' evolution_test
check 'dual-type damage, immunity and catch probability' types_test
check 'real battle victory and defeat' real_battle_test
check 'invalid actions, EOF and active Pokémon' battle_input_test
check 'captures into PC, Master Ball and full capacity' capture_test
check 'PC deposits, withdrawals, swaps and conscious-party safeguards' pc_test
check '54 map dimensions and reachable interaction tiles' map_test
check 'specific badge gates and ship departure' gates_test
check 'Fly destinations, key-item bag and Surf badge gate' fly_bag_water_test
check 'reachable full campaign, every event, eight gyms, League and postgame' campaign_test
check 'event failure, EOF, cancelled reward and escape' event_failures_test
check 'gym losses, EOF, identity and non-linear badge order' gym_failures_order_test
check 'save v2 roundtrip of team, PC, flags, dex, active and checkpoint' save_roundtrip_test
check 'corrupt saves rejected without state mutation' save_corruption_test
check 'legacy v1 migration and v2 rewrite' legacy_test
ship_healing_test() {
    new_game 1
    area=15 x=4 y=4; set_map; interact
    eq "$checkpoint" 15
    area=16; set_map; party_hp[0]=1; interact
    eq "$checkpoint:${party_hp[0]}" 15:35
    save_file=$TMP/ship.dat; save_game
    new_game 4; load_game
    eq "$area:$checkpoint" 16:15
    flags[anne]=1; blackout
    eq "$area:$checkpoint" 15:15
    save_game; new_game 4; load_game
    eq "$area:$checkpoint" 15:15
}
save_write_failure_test() {
    new_game 1; save_file=$TMP/keep.dat; save_game
    local original
    original=$(cat "$save_file")
    write_save_data() { printf 'incomplete'; return 1; }
    expect_status 1 save_game
    eq "$(cat "$save_file")" "$original"
    shopt -s nullglob
    local -a unfinished=("$TMP"/.pokemon-save.*)
    eq "${#unfinished[@]}" 0
}
check 'failed save write preserves the existing file and removes temporary data' save_write_failure_test
check 'ship healing keeps a loadable city checkpoint after departure' ship_healing_test
check 'CLI new game, resume, EOF and errors' cli_test
printf '\n%s test groups passed\n' "$passed"
