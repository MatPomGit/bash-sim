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
    while IFS=$'\t' read -r old new; do legacy[$old]=$new; done < "$GAME_ROOT/data/legacy_ids.tsv"
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
