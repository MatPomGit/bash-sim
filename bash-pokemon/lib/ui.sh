# Terminal presentation. Rendering must not change game state or consume RANDOM.
UI_WIDTH=70 UI_COLOR=0 UI_UNICODE=0
UI_RESET='' UI_BASE='' UI_FRAME='' UI_TITLE='' UI_DIM='' UI_GOOD='' UI_WARN='' UI_BAD=''
ui_style=${BASH_POKEMON_STYLE:-retro}
ui_color_mode=${BASH_POKEMON_COLOR:-auto}
ui_ascii=${BASH_POKEMON_ASCII:-0}
ui_init() {
    local columns=${COLUMNS:-80} locale_name=${LC_ALL:-${LC_CTYPE:-${LANG:-}}}
    local size rows
    if [[ -t 1 ]] && command -v stty >/dev/null 2>&1; then
        size=$(stty size 2>/dev/null < /dev/tty) || size=''
        read -r rows columns <<< "$size"
    fi
    [[ $columns =~ ^[0-9]{1,4}$ ]] || columns=80
    (( columns<24 )) && columns=24
    UI_WIDTH=$((columns-2)); (( UI_WIDTH>70 )) && UI_WIDTH=70
    (( UI_WIDTH<23 )) && UI_WIDTH=23
    UI_COLOR=0 UI_UNICODE=0
    if [[ $ui_style != plain && -z ${NO_COLOR:-} ]]; then
        if [[ $ui_color_mode == always ]] || { [[ $ui_color_mode == auto && -t 1 && ${TERM:-dumb} != dumb ]]; }; then UI_COLOR=1; fi
        if [[ $ui_ascii != 1 && $locale_name == *[Uu][Tt][Ff]*8* ]] && { [[ -t 1 ]] || (( UI_COLOR )); }; then UI_UNICODE=1; fi
    fi
    UI_RESET='' UI_BASE='' UI_FRAME='' UI_TITLE='' UI_DIM='' UI_GOOD='' UI_WARN='' UI_BAD=''
    if (( UI_COLOR )); then
        UI_RESET=$'\033[0m' UI_BASE=$'\033[0;40;37m' UI_FRAME=$'\033[0;40;32m'
        UI_TITLE=$'\033[0;40;1;92m' UI_DIM=$'\033[0;40;90m'
        UI_GOOD=$'\033[0;40;92m' UI_WARN=$'\033[0;40;93m' UI_BAD=$'\033[0;40;91m'
    fi
    return 0
}
ui_clear() {
    if [[ -t 1 ]] && (( UI_COLOR )); then printf '\033[2J\033[H'; fi
    return 0
}
ui_repeat() {
    local count=$1 symbol=$2 spaces
    printf -v spaces '%*s' "$count" ''
    printf '%s' "${spaces// /$symbol}"
}
ui_rule() {
    local kind=${1:-mid} left='+' right='+' horizontal='-'
    if (( UI_UNICODE )); then
        horizontal='─'
        case $kind in top) left='┌' right='┐' ;; bottom) left='└' right='┘' ;; *) left='├' right='┤' ;; esac
    fi
    printf '%s%s' "$UI_FRAME" "$left"; ui_repeat "$((UI_WIDTH-2))" "$horizontal"
    printf '%s%s\n' "$right" "$UI_RESET"
}
ui_edge() { if (( UI_UNICODE )); then printf '│'; else printf '|'; fi; }
ui_row() {
    local text=$1 style=${2:-$UI_BASE} width=$((UI_WIDTH-4)) chunk
    while (( ${#text}>width )); do
        chunk=${text:0:width}
        [[ $chunk == *' '* && -n ${chunk% *} ]] && chunk=${chunk% *}
        printf '%s' "$UI_FRAME"; ui_edge
        printf ' %s%s' "$style" "$chunk"; ui_repeat "$((width-${#chunk}))" ' '
        printf '%s ' "$UI_FRAME"; ui_edge; printf '%s\n' "$UI_RESET"
        text=${text:${#chunk}}; text=${text# }
    done
    printf '%s' "$UI_FRAME"; ui_edge
    printf ' %s%s' "$style" "$text"; ui_repeat "$((width-${#text}))" ' '
    printf '%s ' "$UI_FRAME"; ui_edge; printf '%s\n' "$UI_RESET"
}
ui_heading() {
    ui_rule top; ui_row "$1" "$UI_TITLE"
    [[ -z ${2:-} ]] || ui_row "$2" "$UI_DIM"
    ui_rule
}
ui_hp() {
    local hp=$1 maximum=$2 length=${3:-14} filled style=$UI_GOOD full='#' empty='.'
    (( hp<0 )) && hp=0; (( hp>maximum )) && hp=$maximum
    filled=$(((hp*length+maximum-1)/maximum))
    if (( hp*100<=maximum*20 )); then style=$UI_BAD
    elif (( hp*100<=maximum*50 )); then style=$UI_WARN; fi
    if (( UI_UNICODE )); then full='█' empty='░'; fi
    printf '%s[' "$style"; ui_repeat "$filled" "$full"; ui_repeat "$((length-filled))" "$empty"
    printf ']%s %s/%s' "$UI_BASE" "$hp" "$maximum"
}
ui_tile() {
    local tile=$1 width=$2 glyph color=$UI_BASE
    case $tile in
        '@') glyph='@' color=$'\033[0;1;97;41m' ;;
        N) glyph='!' color=$'\033[0;1;93;40m' ;;
        C) glyph='C' color=$'\033[0;1;97;41m' ;;
        S) glyph='S' color=$'\033[0;1;30;43m' ;;
        G) glyph='G' color=$'\033[0;1;97;45m' ;;
        P) glyph='P' color=$'\033[0;1;97;44m' ;;
        T) glyph='T' color=$'\033[0;1;93;40m' ;;
        '<'|'>') glyph=$tile color=$'\033[0;1;97;40m' ;;
        ':') glyph=',' color=$'\033[0;32;40m'; (( UI_UNICODE )) && glyph='░' ;;
        '~') glyph='~' color=$'\033[0;96;44m'; (( UI_UNICODE )) && glyph='≈' ;;
        '#')
            color=$'\033[0;32;40m'; glyph='#'
            case ${terrain[area]} in
                cave|tower|hideout|mansion|tunnel) color=$'\033[0;90;40m'; (( UI_UNICODE )) && glyph='▓' ;;
                forest|route|safari|town) (( UI_UNICODE )) && glyph='♣' ;;
                *) (( UI_UNICODE )) && glyph='█' ;;
            esac ;;
        *)
            glyph='.' color=$'\033[0;90;40m'
            (( UI_UNICODE )) && glyph='·'
            case ${terrain[area]} in forest|route|safari) color=$'\033[0;32;40m' ;; esac ;;
    esac
    (( UI_COLOR )) || color=''
    printf '%s%s' "$color" "$glyph"
    if (( width==2 )); then
        case $tile in '#'|':'|'~') printf '%s' "$glyph" ;; *) printf ' ' ;; esac
    fi
    return 0
}
ui_map() {
    local row col tile scale=2 indent used
    (( UI_WIDTH<46 )) && scale=1
    used=$((21*scale)); indent=$(((UI_WIDTH-2-used)/2))
    for ((row=0;row<9;row++)); do
        printf '%s' "$UI_FRAME"; ui_edge; printf '%s' "$UI_BASE"; ui_repeat "$indent" ' '
        for ((col=0;col<21;col++)); do
            tile=${map[row]:col:1}
            if (( row==y && col==x )); then tile=@; fi
            ui_tile "$tile" "$scale"
        done
        printf '%s' "$UI_BASE"; ui_repeat "$((UI_WIDTH-2-indent-used))" ' '
        printf '%s' "$UI_FRAME"; ui_edge; printf '%s\n' "$UI_RESET"
    done
}
ui_badges() {
    local i text='ODZNAKI '
    for ((i=1;i<=8;i++)); do
        if (( UI_WIDTH<46 )); then
            if [[ ${flags[gym$i]:-0} == 1 ]]; then text+='*'; else text+='.'; fi
        elif [[ ${flags[gym$i]:-0} == 1 ]]; then text+="[$i]"; else text+='[.]'; fi
    done
    ui_row "$text" "$UI_WARN"
}
ui_status_message() {
    local text=$1 width=$((UI_WIDTH-4))
    if (( ${#text}>width )); then text="${text:0:width-3}..."; fi
    ui_row "$text" "$UI_WARN"
}
ui_world() {
    local hp_max=$((20+party_lv[active]*3)) line length=14
    ui_clear
    ui_heading "BASH RED $VERSION | ${towns[area]}"
    ui_map; ui_rule
    if (( UI_WIDTH<46 )); then
        ui_row "${names[${party_id[active]}]} Lv.${party_lv[active]}" "$UI_TITLE"
    else
        ui_row "${names[${party_id[active]}]}  Lv.${party_lv[active]}  /  ${types[${party_id[active]}]}" "$UI_TITLE"
    fi
    length=$((UI_WIDTH-20)); (( length>14 )) && length=14; (( length<4 )) && length=4
    printf '%s' "$UI_FRAME"; ui_edge; printf ' %sHP ' "$UI_BASE"; ui_hp "${party_hp[active]}" "$hp_max" "$length"
    printf -v line 'HP [%*s] %s/%s' "$length" '' "${party_hp[active]}" "$hp_max"
    ui_repeat "$((UI_WIDTH-4-${#line}))" ' '; printf ' %s' "$UI_FRAME"; ui_edge; printf '%s\n' "$UI_RESET"
    ui_badges
    if (( UI_WIDTH<46 )); then ui_row "Monety $gold B:$balls P:$potions" "$UI_DIM"
    else ui_row "Monety $gold   Kule $balls   Mikstury $potions" "$UI_DIM"; fi
    ui_rule
    if [[ -n $message ]]; then ui_status_message "$message"; else ui_status_message 'Wybierz drogę lub wydarzenie. Dziennik: j'; fi
    ui_rule
    if (( UI_WIDTH<46 )); then
        ui_row 'WASD ruch  E akcja'
        ui_row 'J zadania  H pomoc'
        ui_row 'Q zapisz i wyjdź'
    else
        ui_row 'WASD ruch | E akcja | P drużyna | J zadania | H pomoc'
        ui_row 'I plecak | K dex | M mapa | F lot | Q zapisz i wyjdź'
    fi
    ui_rule bottom
}
# Twelve-by-eight pixel silhouettes. Named designs for starters and Pikachu;
# other species use a silhouette of their primary type, with their actual name.
ui_sprite() {
    local sid=$1 kind=${types[$1]}
    case $sid in 1|2|3) kind=bulbasaur ;; 4|5|6) kind=charmander ;; 7|8|9) kind=squirtle ;; 25|26) kind=pikachu ;; 150) kind=mewtwo ;; esac
    case $kind in
        pikachu) SPRITE=(010000000010 012000000210 012100001210 001222222100 012321123210 012242242210 001222222100 000112211000) ;;
        bulbasaur) SPRITE=(000011110000 001122221100 012222222210 012132213210 012222222210 001221122100 001100001100 000000000000) ;;
        charmander|fire) SPRITE=(000000111000 000001222100 000001231100 014001222100 144102222100 014112222100 001222221000 000110011000) ;;
        squirtle) SPRITE=(000001110000 000012221000 000012321000 001112221100 012221122210 012223322210 001222222100 000110011000) ;;
        mewtwo|psychic) SPRITE=(000010010000 000012210000 000013310000 001112211100 012012210210 010012210010 000122221000 001100001100) ;;
        ghost|poison) SPRITE=(000001110000 000012221000 000123232100 001222222210 012221122210 122222222221 011111111110 000000000000) ;;
        water|ice) SPRITE=(000000000000 000001110000 010012221000 121122232110 122222222221 011122221110 000001110000 000000000000) ;;
        flying|dragon) SPRITE=(010000000010 121001100121 122112211221 012222222210 001223322100 000122221000 000011110000 000110011000) ;;
        grass|bug) SPRITE=(000010010000 000012210000 001112211100 012213312210 012222222210 001122221100 000011110000 000110011000) ;;
        rock|ground|fighting) SPRITE=(000011110000 000122221000 001232232100 011222222110 122222222221 011222222110 001122221100 000110011000) ;;
        *) SPRITE=(001100001100 012210012210 012221122210 001232232100 001222222100 000122221000 000112211000 001100001100) ;;
    esac
}
ui_pixel_row() {
    local data=$1 type=$2 pixel glyph='#' style base=$'\033[0;32;40m' bright=$'\033[0;92;40m'
    if (( UI_UNICODE )); then glyph='█'; fi
    case $type in
        fire) base=$'\033[0;31;40m' bright=$'\033[0;91;40m' ;;
        water|ice) base=$'\033[0;36;40m' bright=$'\033[0;96;40m' ;;
        electric) base=$'\033[0;33;40m' bright=$'\033[0;93;40m' ;;
        psychic|ghost|poison) base=$'\033[0;35;40m' bright=$'\033[0;95;40m' ;;
        normal|rock|ground|fighting|flying|dragon) base=$'\033[0;37;40m' bright=$'\033[0;97;40m' ;;
    esac
    for ((pixel=0;pixel<${#data};pixel++)); do
        case ${data:pixel:1} in
            0) printf '%s  ' "$UI_BASE"; continue ;;
            1) style=$UI_DIM ;;
            2) style=$base ;;
            3) style=$bright ;;
            4) style=$UI_WARN; [[ $type == electric ]] && style=$UI_BAD ;;
        esac
        if (( !UI_UNICODE )); then
            case ${data:pixel:1} in 1) glyph='#' ;; 2) glyph='o' ;; 3) glyph='.' ;; 4) glyph='*' ;; esac
        fi
        (( UI_COLOR )) || style=''
        printf '%s%s%s' "$style" "$glyph" "$glyph"
    done
}
ui_battle() {
    local foe=$1 level=$2 hp=$3 maximum=$4 mode=$5 log=${6:-} row label='DZIKI POKEMON'
    local -a yours enemy
    [[ $mode == wild ]] || label='WALKA Z TRENEREM'
    ui_clear; ui_heading "$label"
    ui_row "RYWAL: ${names[foe]}  Lv.$level  /  ${types[foe]} ${types2[foe]}" "$UI_TITLE"
    if (( UI_WIDTH>=58 )); then
        ui_sprite "${party_id[active]}"; yours=("${SPRITE[@]}")
        ui_sprite "$foe"; enemy=("${SPRITE[@]}")
        for ((row=0;row<8;row++)); do
            printf '%s' "$UI_FRAME"; ui_edge; printf '%s' "$UI_BASE"; ui_repeat "$(((UI_WIDTH-2-52)/2))" ' '
            ui_pixel_row "${yours[row]}" "${types[${party_id[active]}]}"
            printf '%s    ' "$UI_BASE"; ui_pixel_row "${enemy[row]}" "${types[foe]}"
            printf '%s' "$UI_BASE"; ui_repeat "$((UI_WIDTH-2-52-(UI_WIDTH-2-52)/2))" ' '
            printf '%s' "$UI_FRAME"; ui_edge; printf '%s\n' "$UI_RESET"
        done
    fi
    ui_rule
    ui_battle_hp "$hp" "$maximum"
    ui_row "TY: ${names[${party_id[active]}]}  Lv.${party_lv[active]}" "$UI_TITLE"
    ui_battle_hp "${party_hp[active]}" "$((20+party_lv[active]*3))"
    ui_rule
    [[ -z $log ]] || { ui_status_message "$log"; ui_rule; }
    ui_row '1 Atak     2 Pierwszy typ    7 Drugi typ'
    ui_row '3 Kula     8 Master Ball    4 Mikstura'
    ui_row '5 Zmiana   6 Ucieczka' "$UI_DIM"
    ui_rule bottom
}
ui_battle_hp() {
    local hp=$1 maximum=$2 length=14 line
    length=$((UI_WIDTH-16)); (( length>14 )) && length=14; (( length<4 )) && length=4
    printf '%s' "$UI_FRAME"; ui_edge; printf ' %s' "$UI_BASE"
    ui_hp "$hp" "$maximum" "$length"
    printf -v line '[%*s] %s/%s' "$length" '' "$hp" "$maximum"
    ui_repeat "$((UI_WIDTH-4-${#line}))" ' '
    printf ' %s' "$UI_FRAME"; ui_edge; printf '%s\n' "$UI_RESET"
}
ui_party() {
    local i maximum marker
    ui_heading 'TWOJA DRUŻYNA' "Pokemony ${#party_id[@]}/6  |  PC ${#box_id[@]}/300"
    for ((i=0;i<${#party_id[@]};i++)); do
        maximum=$((20+party_lv[i]*3)); marker=' '
        (( i==active )) && marker='>'
        ui_row "$marker $((i+1)). ${names[${party_id[i]}]}  Lv.${party_lv[i]}  XP ${party_xp[i]}/$((party_lv[i]*12))" "$UI_TITLE"
        ui_battle_hp "${party_hp[i]}" "$maximum"
        (( i==${#party_id[@]}-1 )) || ui_rule
    done
    ui_rule bottom
}
ui_dialog() {
    ui_heading "$1" 'KANTO / HISTORIA'
    ui_row "$2"; ui_rule bottom
}
ui_starters() {
    ui_clear; ui_heading 'POKEMON / BASH RED' 'NOWA PRZYGODA W KANTO'
    ui_row 'Profesor Oak: wybierz swojego pierwszego Pokemona' "$UI_TITLE"
    ui_rule
    ui_row '1  BULBASAUR   trawa / trucizna' "$UI_GOOD"
    ui_row '2  CHARMANDER  ogień' "$UI_BAD"
    ui_row '3  SQUIRTLE    woda' "$UI_BASE"
    ui_rule bottom
}
