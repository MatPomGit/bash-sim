#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT
passed=0
check() {
    local name=$1
    shift
    printf 'TEST %s\n' "$name"
    ( set -e; "$@" )
    printf 'PASS %s\n' "$name"; passed=$((passed+1))
}
# shellcheck source=../bash_pokemon.sh
source "$ROOT/bash_pokemon.sh"
save_file=$TMP/save.dat

test_starters() {
    local starter
    for starter in 1 4 7; do
        new_game "$starter"
        [[ ${party_id[0]} == "$starter" && ${party_hp[0]} == 35 && $badges == 0 ]]
    done
}
test_evolution() {
    new_game 1
    party_lv[0]=15 party_hp[0]=65
    gain_xp 0 180 >/dev/null
    [[ ${party_lv[0]} == 16 && ${party_id[0]} == 2 && ${party_hp[0]} == 68 ]]
    party_lv[0]=99 party_xp[0]=0 party_hp[0]=317
    gain_xp 0 10000 >/dev/null
    [[ ${party_lv[0]} == 100 && ${party_xp[0]} == 0 && ${party_hp[0]} == 320 ]]
}
test_types() {
    effectiveness fire grass; [[ $REPLY == 4 ]]
    effectiveness water grass; [[ $REPLY == 1 ]]
    damage 50 electric ground 10; [[ $REPLY == 0 ]]
    damage 1 normal rock 1; (( REPLY >= 1 ))
    catch_chance 100 100; [[ $REPLY == 20 ]]
    catch_chance 1 100; [[ $REPLY == 79 ]]
}
test_roundtrip() {
    new_game 7
    party_id+=(21) party_lv+=(12) party_xp+=(50) party_hp+=(19)
    area=2 badges=1 gold=123 x=7 y=6
    save_game
    new_game 4
    load_game
    [[ $area == 2 && $badges == 1 && $gold == 123 && $x == 7 && $y == 6 ]]
    [[ ${party_id[*]} == '7 21' && ${party_hp[*]} == '35 19' && ${party_xp[1]} == 50 ]]
    [[ $(stat -c '%a' "$save_file" 2>/dev/null || stat -f '%Lp' "$save_file") == 600 ]]
}
test_bad_saves() {
    local record before
    new_game 1
    before="${party_id[*]}:$area:$gold"
    for record in \
        '1|01|4|500|10|5|0|0' '1|1|4|500|10|5|9|0' \
        '9|1|4|500|10|5|0|0' '1|1|0|500|10|5|0|0' \
        '0|1|4|500|10|5|0|1' '0|1|4|500|10|5|0|0|0'; do
        printf 'POKEBASH|1\n%s\n1|5|0|35\n' "$record" > "$save_file"
        if load_game; then return 1; fi
        [[ "${party_id[*]}:$area:$gold" == "$before" ]]
    done
    for record in '77|5|0|35' '1|0|0|35' '1|5|0|999' '1|5|60|35' \
        '1|100|1|320' '1|5|0|0' '1|5|0|35|' '1|5|0|035' \
        '1|5|0|35; touch SHOULD_NOT_EXIST' '$(touch SHOULD_NOT_EXIST)|5|0|35'; do
        printf 'POKEBASH|1\n0|4|4|500|10|5|0|0\n%s\n' "$record" > "$save_file"
        if load_game; then return 1; fi
        [[ "${party_id[*]}:$area:$gold" == "$before" ]]
    done
    [[ ! -e SHOULD_NOT_EXIST ]]
    printf 'POKEBASH|1\n0|4|4|500|10|5|0|0\n' > "$save_file"
    if load_game; then return 1; fi
    local i
    for ((i=0;i<7;i++)); do printf '1|5|0|35\n' >> "$save_file"; done
    if load_game; then return 1; fi
    return 0
}
test_map() {
    local row
    for row in "${map[@]}"; do [[ ${#row} == 21 ]]; done
    new_game 1
    x=1 y=1; move_player -1 0
    [[ $x == 1 && $y == 1 ]]
    x=19 y=4; move_player 1 0
    [[ $area == 1 && $x == 1 ]]
    x=19; move_player 1 0
    [[ $area == 1 && $x == 19 ]]
    badges=1; move_player 1 0
    [[ $area == 2 && $x == 1 ]]
    move_player -1 0
    [[ $area == 1 && $x == 19 ]]
}
test_potion_blackout() {
    new_game 1
    party_hp[0]=2 potions=1
    use_potion >/dev/null
    [[ ${party_hp[0]} == 35 && $potions == 0 ]]
    if use_potion >/dev/null; then return 1; fi
    gold=101; party_hp[0]=0
    blackout
    [[ $gold == 50 && ${party_hp[0]} == 35 && $x == 4 && $y == 4 ]]
}
test_real_battle() {
    new_game 7
    party_lv[0]=40; heal_party
    # A level-40 water move defeats this level-5 fire foe in one hit.
    battle 4 5 wild <<< 2 >/dev/null
    [[ ${party_xp[0]} == 50 && $gold == 575 ]]
    new_game 1
    # Opponent wins before any possible second turn.
    battle 6 100 trainer <<< 1 >/dev/null && return 1
    [[ ${party_hp[0]} == 35 && $gold == 250 ]]
}
test_battle_inputs() {
    new_game 1
    # Bad actions do not consume turns. EOF must propagate instead of looping.
    if battle 4 5 trainer <<< $'3\n6\nxxx' >/dev/null; then return 1; else [[ $? == 2 ]]; fi
    [[ $balls == 10 && ${party_hp[0]} == 35 ]]
    if battle 4 5 wild < /dev/null >/dev/null; then return 1; else [[ $? == 2 ]]; fi
    party_id+=(7) party_lv+=(5) party_xp+=(0) party_hp+=(35)
    active=1
    if battle 4 5 wild < /dev/null >/dev/null; then return 1; else [[ $? == 2 ]]; fi
    [[ $active == 1 ]]
}
test_catch() {
    new_game 1
    # Deterministic random sequence; enough attempts, foe cannot damage us.
    damage() { REPLY=0; }
    RANDOM=123
    local choices='' i
    for ((i=0;i<10;i++)); do choices+=$'3\n'; done
    battle 21 5 wild <<< "$choices" >/dev/null
    [[ ${#party_id[@]} == 2 && ${party_id[1]} == 21 && $balls -lt 10 ]]
    party_id=(1 4 7 10 13 16) party_lv=(5 5 5 5 5 5) party_xp=(0 0 0 0 0 0) party_hp=(35 35 35 35 35 35)
    local before=$balls
    if battle 21 5 wild <<< 3 >/dev/null; then return 1; else [[ $? == 2 ]]; fi
    [[ $balls == "$before" ]]
}
test_gym_campaign() {
    new_game 7
    party_lv[0]=100; heal_party
    # Real gym/league orchestration, deterministic victory in each battle.
    battle() { return 0; }
    local i
    for ((i=1;i<=8;i++)); do
        area=$i; gym <<< t >/dev/null
        [[ $badges == "$i" ]]
        gym <<< t >/dev/null; [[ $badges == "$i" ]]
    done
    area=9; league <<< t >/dev/null
    [[ $champion == 1 ]]
    new_game 7; area=2; gym <<< t >/dev/null
    [[ $badges == 0 ]]
    league <<< t >/dev/null; [[ $champion == 0 ]]
    # Losing or EOF must not award an unearned badge.
    area=1; battle() { return 1; }
    if gym <<< t >/dev/null; then return 1; fi
    [[ $badges == 0 ]]
    battle() { return 2; }
    if gym <<< t >/dev/null; then return 1; else [[ $? == 2 ]]; fi
    [[ $badges == 0 ]]
}
test_shop_release() {
    new_game 1
    shop <<< 1 >/dev/null
    [[ $balls == 15 && $gold == 400 ]]
    gold=0; shop <<< 2 >/dev/null
    [[ $potions == 5 ]]
    party_id+=(4) party_lv+=(5) party_xp+=(0) party_hp+=(0)
    release_pokemon <<< $'1\nt' >/dev/null
    [[ ${#party_id[@]} == 2 ]]
    release_pokemon <<< $'2\nt' >/dev/null
    [[ ${#party_id[@]} == 1 && ${party_id[0]} == 1 ]]
}
test_cli() {
    local file="$TMP/cli save.dat"
    printf '2\nd\ne\np\n0\nq\n' | bash "$ROOT/bash_pokemon.sh" --new --save "$file" > "$TMP/cli.out"
    save_file=$file; load_game
    [[ ${party_id[0]} == 4 && $x == 5 ]]
    bash "$ROOT/bash_pokemon.sh" --load --save "$file" < /dev/null > "$TMP/resume.out"
    cmp "$TMP/cli.out" "$TMP/resume.out" >/dev/null && return 1
    printf 'n\n' | bash "$ROOT/bash_pokemon.sh" --new --save "$file" >/dev/null
    load_game; [[ ${party_id[0]} == 4 ]]
    printf 'CORRUPT\n' > "$file"
    if bash "$ROOT/bash_pokemon.sh" --save "$file" < /dev/null >/dev/null 2>&1; then return 1; fi
    [[ $(cat "$file") == CORRUPT ]]
    if bash "$ROOT/bash_pokemon.sh" --save >/dev/null 2>&1; then return 1; fi
    if bash "$ROOT/bash_pokemon.sh" --load --save "$TMP/missing" >/dev/null 2>&1; then return 1; fi
    if printf 't\n1\n' | bash "$ROOT/bash_pokemon.sh" --new --save "$TMP" >/dev/null 2>&1; then return 1; fi
    bash "$ROOT/bash_pokemon.sh" --help >/dev/null
}
check 'three starters' test_starters
check 'level, evolution and level cap' test_evolution
check 'type immunity, resistance and catching probability' test_types
check 'save roundtrip and permissions' test_roundtrip
check 'reject malformed and executable save data without state changes' test_bad_saves
check 'walls, travel and badge gates' test_map
check 'healing and blackout' test_potion_blackout
check 'real battle victory and defeat' test_real_battle
check 'battle invalid input and EOF' test_battle_inputs
check 'catching and full party' test_catch
check 'eight gyms, league, losses and EOF' test_gym_campaign
check 'shop and release safeguards' test_shop_release
check 'CLI new game, resume, EOF and invalid save' test_cli
printf '\n%s test groups passed\n' "$passed"
