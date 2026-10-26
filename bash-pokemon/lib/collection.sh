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
