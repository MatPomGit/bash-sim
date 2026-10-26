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
