#!/usr/bin/env bash

# Bash TUI prezentujący najważniejsze informacje systemowe.
# Interfejs i komentarze są w języku polskim, zgodnie z wymaganiami projektu.

set -o errexit
set -o nounset
set -o pipefail

readonly APP_NAME="bash-tui"
readonly VERSION_PREFIX="1.1"
readonly AUTHORS="KIA, Katedra Informatyki i Automatyki, Politechnika Rzeszowska"
readonly BAR_WIDTH=28
readonly REFRESH_HZ_LEVELS=("0.2" "0.5" "1" "2" "3" "4" "5" "10")
readonly REFRESH_TIMEOUT_LEVELS=("5" "2" "1" "0.5" "0.333" "0.25" "0.2" "0.1")
readonly ACTION_LABELS=("Instrukcje" "Wolniej" "Szybciej" "Odśwież" "Wyjście")

# Definicja kolorów ANSI dla czytelniejszego interfejsu.
readonly COLOR_RESET=$'\033[0m'
readonly COLOR_BORDER=$'\033[38;5;39m'
readonly COLOR_TITLE=$'\033[1;38;5;45m'
readonly COLOR_LABEL=$'\033[1;38;5;81m'
readonly COLOR_VALUE=$'\033[38;5;230m'
readonly COLOR_INFO=$'\033[38;5;159m'
readonly COLOR_OK=$'\033[1;38;5;82m'
readonly COLOR_WARN=$'\033[1;38;5;220m'
readonly COLOR_CRIT=$'\033[1;38;5;196m'

# Zwraca automatycznie zwiększaną wersję opartą o liczbę commitów w repozytorium.
get_version() {
    local commit_count
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        commit_count="$(git rev-list --count HEAD 2>/dev/null || echo 0)"
    else
        commit_count=0
    fi
    printf "%s.%s" "$VERSION_PREFIX" "$commit_count"
}

# Uwalnia terminal po wyjściu z programu.
cleanup_terminal() {
    tput cnorm || true
    tput rmcup || true
    stty sane || true
}

# Zwiększa częstotliwość odświeżania do kolejnego dostępnego poziomu.
increase_refresh_rate() {
    local current_index="$1"
    local max_index=$(( ${#REFRESH_HZ_LEVELS[@]} - 1 ))

    if (( current_index < max_index )); then
        echo $((current_index + 1))
    else
        echo "$current_index"
    fi
}

# Zmniejsza częstotliwość odświeżania do poprzedniego dostępnego poziomu.
decrease_refresh_rate() {
    local current_index="$1"

    if (( current_index > 0 )); then
        echo $((current_index - 1))
    else
        echo "$current_index"
    fi
}

# Przełącza terminal w tryb „pełnoekranowy” (alt-screen + próba maksymalizacji okna).
setup_terminal() {
    printf '\e[9;1t' || true
    tput smcup || true
    tput civis || true
    clear || true
}

# Dobiera kolor stanu na podstawie wartości procentowej.
get_status_color() {
    local percent="$1"
    if (( percent < 60 )); then
        printf "%s" "$COLOR_OK"
    elif (( percent < 85 )); then
        printf "%s" "$COLOR_WARN"
    else
        printf "%s" "$COLOR_CRIT"
    fi
}

# Zwraca obciążenie CPU w procentach.
get_cpu_usage() {
    local cpu_line total busy total2 busy2 total_diff busy_diff

    cpu_line="$(grep '^cpu ' /proc/stat)"
    read -r _ user nice system idle iowait irq softirq steal _ <<<"$cpu_line"
    total=$((user + nice + system + idle + iowait + irq + softirq + steal))
    busy=$((total - idle - iowait))

    sleep 0.2

    cpu_line="$(grep '^cpu ' /proc/stat)"
    read -r _ user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2 _ <<<"$cpu_line"
    total2=$((user2 + nice2 + system2 + idle2 + iowait2 + irq2 + softirq2 + steal2))
    busy2=$((total2 - idle2 - iowait2))

    total_diff=$((total2 - total))
    busy_diff=$((busy2 - busy))

    if (( total_diff == 0 )); then
        echo "0"
    else
        echo $((100 * busy_diff / total_diff))
    fi
}

# Buduje kolorowy pasek postępu dla wartości procentowej.
build_progress_bar() {
    local percent="$1"
    local width="$BAR_WIDTH"
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    local bar_color

    bar_color="$(get_status_color "$percent")"

    printf "%s[" "$bar_color"
    printf "%${filled}s" "" | tr ' ' '█'
    printf "%s" "$COLOR_BORDER"
    printf "%${empty}s" "" | tr ' ' '░'
    printf "%s] %3s%%%s" "$bar_color" "$percent" "$COLOR_RESET"
}

# Zwraca wykorzystanie pamięci RAM i SWAP w procentach oraz MB.
get_memory_stats() {
    local mem_total mem_available mem_used mem_percent
    local swap_total swap_free swap_used swap_percent

    mem_total="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"
    mem_available="$(awk '/MemAvailable/ {print $2}' /proc/meminfo)"
    mem_used=$((mem_total - mem_available))
    mem_percent=$((100 * mem_used / mem_total))

    swap_total="$(awk '/SwapTotal/ {print $2}' /proc/meminfo)"
    swap_free="$(awk '/SwapFree/ {print $2}' /proc/meminfo)"
    if (( swap_total > 0 )); then
        swap_used=$((swap_total - swap_free))
        swap_percent=$((100 * swap_used / swap_total))
    else
        swap_used=0
        swap_percent=0
    fi

    printf "%s;%s;%s;%s;%s;%s\n" \
        "$mem_percent" "$((mem_used / 1024))" "$((mem_total / 1024))" \
        "$swap_percent" "$((swap_used / 1024))" "$((swap_total / 1024))"
}

# Zwraca wykorzystanie systemu plików dla wskazanego punktu montowania.
get_disk_stats() {
    local mount_point="$1"
    df -P "$mount_point" | awk 'NR==2 {gsub("%", "", $5); printf "%s;%s;%s", $5, $4, $2}'
}

# Zwraca nazwę modelu CPU i liczbę rdzeni logicznych.
get_cpu_info() {
    local cpu_model cpu_cores
    cpu_model="$(awk -F': ' '/model name/ {print $2; exit}' /proc/cpuinfo)"
    cpu_cores="$(nproc --all 2>/dev/null || echo "?")"
    printf "%s;%s" "${cpu_model:-nieznany}" "$cpu_cores"
}

# Zwraca liczbę procesów oraz aktualnie zalogowanych użytkowników.
get_process_and_users() {
    local process_count user_count
    process_count="$(ps -e --no-headers 2>/dev/null | wc -l | tr -d ' ')"
    user_count="$(who 2>/dev/null | wc -l | tr -d ' ')"
    printf "%s;%s" "$process_count" "$user_count"
}

# Zwraca informacje o transferze sieciowym (RX/TX w MB) na pierwszym aktywnym interfejsie.
get_network_stats() {
    local default_if rx_bytes tx_bytes
    default_if="$(ip route 2>/dev/null | awk '/default/ {print $5; exit}')"
    if [[ -z "$default_if" ]]; then
        echo "brak;0;0"
        return
    fi

    read -r rx_bytes tx_bytes < <(awk -F '[: ]+' -v iface="$default_if" '$1 == iface {print $3, $11}' /proc/net/dev)
    printf "%s;%s;%s" "$default_if" "$((rx_bytes / 1024 / 1024))" "$((tx_bytes / 1024 / 1024))"
}

# Zwraca nazwę procesu o najwyższym użyciu CPU.
get_top_cpu_process() {
    ps -eo comm,%cpu --sort=-%cpu --no-headers 2>/dev/null | awk '$1 != "ps" && $1 != "awk" {print $1 " (" $2 "%)"; exit}'
}

# Zwraca temperaturę CPU na podstawie danych thermal_zone (jeśli dostępne).
get_cpu_temperature() {
    local temp_raw
    temp_raw="$(awk '{print $1; exit}' /sys/class/thermal/thermal_zone*/temp 2>/dev/null || true)"

    if [[ -z "$temp_raw" ]]; then
        echo "brak"
        return
    fi

    awk -v raw="$temp_raw" 'BEGIN {printf "%.1f°C", raw / 1000}'
}

# Zwraca liczbę aktywnych połączeń TCP w stanie ESTABLISHED.
get_established_tcp_connections() {
    local tcp4_count tcp6_count
    tcp4_count="$(awk 'NR > 1 && $4 == "01" {count++} END {print count + 0}' /proc/net/tcp 2>/dev/null || echo 0)"
    tcp6_count="$(awk 'NR > 1 && $4 == "01" {count++} END {print count + 0}' /proc/net/tcp6 2>/dev/null || echo 0)"
    echo $((tcp4_count + tcp6_count))
}

# Wyszukuje pliki instrukcji obsługiwane przez podgląd interaktywny.
discover_material_files() {
    local materials_dir
    materials_dir="$(dirname "$0")/materials"

    if [[ ! -d "$materials_dir" ]]; then
        return
    fi

    find "$materials_dir" -maxdepth 1 -type f \( -iname '*.md' -o -iname '*.txt' \) | sort
}

# Odczytuje pojedynczy klawisz (w tym strzałki i Enter) z opcjonalnym timeoutem.
read_input_key() {
    local timeout="${1:-0}"
    local key sequence

    if ! read -r -s -n 1 -t "$timeout" key; then
        return 1
    fi

    if [[ "$key" == $'\e' ]]; then
        if read -r -s -n 2 -t 0.01 sequence; then
            key+="$sequence"
        fi
    fi

    case "$key" in
        $'\e[A') printf "UP\n" ;;
        $'\e[B') printf "DOWN\n" ;;
        $'\e[C') printf "RIGHT\n" ;;
        $'\e[D') printf "LEFT\n" ;;
        "") printf "ENTER\n" ;;
        $'\n'|$'\r') printf "ENTER\n" ;;
        *) printf "%s\n" "$key" ;;
    esac
}

# Zwraca indeks po przesunięciu w lewo lub prawo w zakresie 0..(count-1).
move_selection() {
    local current_index="$1"
    local direction="$2"
    local count="$3"

    if [[ "$direction" == "left" ]]; then
        if (( current_index > 0 )); then
            echo $((current_index - 1))
        else
            echo "$current_index"
        fi
    else
        if (( current_index < count - 1 )); then
            echo $((current_index + 1))
        else
            echo "$current_index"
        fi
    fi
}

# Renderuje poziomy pasek akcji z podświetleniem aktualnie wybranego pola.
render_action_bar() {
    local focused_index="$1"
    local idx

    printf "%sPola (strzałki):%s " "$COLOR_INFO" "$COLOR_RESET"
    for idx in "${!ACTION_LABELS[@]}"; do
        if (( idx == focused_index )); then
            printf "%s> %s <%s " "$COLOR_TITLE" "${ACTION_LABELS[$idx]}" "$COLOR_RESET"
        else
            printf "%s[ %s ]%s " "$COLOR_LABEL" "${ACTION_LABELS[$idx]}" "$COLOR_RESET"
        fi
    done
}

# Wyświetla interaktywny wybór i podgląd instrukcji tekstowych.
show_instructions() {
    local instruction_files=()
    local selected_index=0
    local key
    local idx

    if [[ -n "$timeout" ]]; then
        if ! read -r -s -n 1 -t "$timeout" key; then
            return 1
        fi
    else
        if ! read -r -s -n 1 key; then
            return 1
        fi
    fi

    if (( ${#instruction_files[@]} == 0 )); then
        printf "\nBrak plików instrukcji (*.md, *.txt). Naciśnij [q], aby wrócić..."
        while true; do
            if key="$(read_input_key)"; then
                [[ "$key" == "q" || "$key" == "Q" ]] && return
            fi
        done
        return
    fi

    while true; do
        clear || true
        printf "%s=== Instrukcje interaktywne ===%s\n\n" "$COLOR_TITLE" "$COLOR_RESET"
        printf "Wybierz plik strzałkami góra/dół. Enter = podgląd, q = powrót.\n\n"

        for idx in "${!instruction_files[@]}"; do
            if (( idx == selected_index )); then
                printf "  %s> %s%s\n" "$COLOR_LABEL" "${instruction_files[$idx]#$(dirname "$0")/}" "$COLOR_RESET"
            else
                printf "    %s\n" "${instruction_files[$idx]#$(dirname "$0")/}"
            fi
        done

        if ! key="$(read_input_key)"; then
            continue
        fi

        case "$key" in
            q|Q)
                return
                ;;
            UP)
                if (( selected_index > 0 )); then
                    selected_index=$((selected_index - 1))
                fi
                ;;
            DOWN)
                if (( selected_index < ${#instruction_files[@]} - 1 )); then
                    selected_index=$((selected_index + 1))
                fi
                ;;
            ENTER)
                if command -v less >/dev/null 2>&1; then
                    less -R "${instruction_files[$selected_index]}"
                else
                    clear || true
                    cat "${instruction_files[$selected_index]}"
                    printf "\n--- Koniec pliku. Naciśnij [q], aby wrócić..."
                    while true; do
                        if key="$(read_input_key)"; then
                            [[ "$key" == "q" || "$key" == "Q" ]] && break
                        fi
                    done
                fi
                ;;
        esac
    done
}

# Rysuje pojedynczy ekran TUI.
render_screen() {
    local refresh_hz="$1"
    local focused_index="${2:-0}"
    local version hostname kernel uptime_str load_avg ip_addr
    local cpu_percent cpu_info cpu_model cpu_cores
    local memory_stats mem_percent mem_used_mb mem_total_mb swap_percent swap_used_mb swap_total_mb
    local disk_root_stats disk_home_stats disk_root_percent disk_root_free disk_root_total
    local disk_home_percent disk_home_free disk_home_total
    local process_users process_count user_count
    local net_stats net_if net_rx net_tx
    local top_process cpu_temperature tcp_connections

    version="$(get_version)"
    hostname="$(hostname)"
    kernel="$(uname -sr)"
    uptime_str="$(uptime -p 2>/dev/null || true)"
    load_avg="$(awk '{print $1" "$2" "$3}' /proc/loadavg)"
    ip_addr="$(hostname -I 2>/dev/null | awk '{print $1}')"

    cpu_percent="$(get_cpu_usage)"
    cpu_info="$(get_cpu_info)"
    IFS=';' read -r cpu_model cpu_cores <<<"$cpu_info"

    memory_stats="$(get_memory_stats)"
    IFS=';' read -r mem_percent mem_used_mb mem_total_mb swap_percent swap_used_mb swap_total_mb <<<"$memory_stats"

    disk_root_stats="$(get_disk_stats /)"
    IFS=';' read -r disk_root_percent disk_root_free disk_root_total <<<"$disk_root_stats"

    if [[ -d /home ]]; then
        disk_home_stats="$(get_disk_stats /home)"
        IFS=';' read -r disk_home_percent disk_home_free disk_home_total <<<"$disk_home_stats"
    else
        disk_home_percent=0
        disk_home_free=0
        disk_home_total=0
    fi

    process_users="$(get_process_and_users)"
    IFS=';' read -r process_count user_count <<<"$process_users"

    net_stats="$(get_network_stats)"
    IFS=';' read -r net_if net_rx net_tx <<<"$net_stats"

    top_process="$(get_top_cpu_process)"
    cpu_temperature="$(get_cpu_temperature)"
    tcp_connections="$(get_established_tcp_connections)"

    printf '\033[H'
    cat <<EOT
${COLOR_BORDER}╔════════════════════════════════════════════════════════════════════════════════════════╗${COLOR_RESET}
${COLOR_BORDER}║${COLOR_RESET}${COLOR_TITLE}                                  MONITOR SYSTEMU                                  ${COLOR_RESET}${COLOR_BORDER}║${COLOR_RESET}
${COLOR_BORDER}╠════════════════════════════════════════════════════════════════════════════════════════╣${COLOR_RESET}
${COLOR_BORDER}║${COLOR_RESET} ${COLOR_LABEL}Aplikacja:${COLOR_RESET} ${COLOR_VALUE}${APP_NAME}${COLOR_RESET}    ${COLOR_LABEL}Wersja (auto):${COLOR_RESET} ${COLOR_VALUE}${version}${COLOR_RESET}
${COLOR_BORDER}║${COLOR_RESET} ${COLOR_LABEL}Autorzy:${COLOR_RESET} ${COLOR_VALUE}${AUTHORS}${COLOR_RESET}
${COLOR_BORDER}╠════════════════════════════════════════════════════════════════════════════════════════╣${COLOR_RESET}
${COLOR_BORDER}║${COLOR_RESET} ${COLOR_LABEL}Host:${COLOR_RESET} ${COLOR_VALUE}${hostname}${COLOR_RESET}    ${COLOR_LABEL}Jądro:${COLOR_RESET} ${COLOR_VALUE}${kernel}${COLOR_RESET}
${COLOR_BORDER}║${COLOR_RESET} ${COLOR_LABEL}IP:${COLOR_RESET} ${COLOR_VALUE}${ip_addr:-brak}${COLOR_RESET}    ${COLOR_LABEL}Czas działania:${COLOR_RESET} ${COLOR_VALUE}${uptime_str}${COLOR_RESET}
${COLOR_BORDER}║${COLOR_RESET} ${COLOR_LABEL}Load avg:${COLOR_RESET} ${COLOR_VALUE}${load_avg}${COLOR_RESET}    ${COLOR_LABEL}Procesy/Użytkownicy:${COLOR_RESET} ${COLOR_VALUE}${process_count}/${user_count}${COLOR_RESET}
${COLOR_BORDER}║${COLOR_RESET} ${COLOR_LABEL}Temp. CPU:${COLOR_RESET} ${COLOR_VALUE}${cpu_temperature}${COLOR_RESET}    ${COLOR_LABEL}Połączenia TCP:${COLOR_RESET} ${COLOR_VALUE}${tcp_connections}${COLOR_RESET}
${COLOR_BORDER}║${COLOR_RESET} ${COLOR_LABEL}CPU model:${COLOR_RESET} ${COLOR_VALUE}${cpu_model}${COLOR_RESET}
${COLOR_BORDER}║${COLOR_RESET} ${COLOR_LABEL}Rdzenie logiczne:${COLOR_RESET} ${COLOR_VALUE}${cpu_cores}${COLOR_RESET}    ${COLOR_LABEL}Top CPU process:${COLOR_RESET} ${COLOR_VALUE}${top_process:-brak}${COLOR_RESET}
${COLOR_BORDER}╠════════════════════════════════════════════════════════════════════════════════════════╣${COLOR_RESET}
${COLOR_BORDER}║${COLOR_RESET} ${COLOR_LABEL}CPU:${COLOR_RESET}     $(build_progress_bar "$cpu_percent")
${COLOR_BORDER}║${COLOR_RESET} ${COLOR_LABEL}RAM:${COLOR_RESET}     $(build_progress_bar "$mem_percent")  ${COLOR_INFO}(${mem_used_mb}MB / ${mem_total_mb}MB)${COLOR_RESET}
${COLOR_BORDER}║${COLOR_RESET} ${COLOR_LABEL}SWAP:${COLOR_RESET}    $(build_progress_bar "$swap_percent")  ${COLOR_INFO}(${swap_used_mb}MB / ${swap_total_mb}MB)${COLOR_RESET}
${COLOR_BORDER}║${COLOR_RESET} ${COLOR_LABEL}Dysk /:${COLOR_RESET}  $(build_progress_bar "$disk_root_percent")  ${COLOR_INFO}(wolne: ${disk_root_free}K / ${disk_root_total}K)${COLOR_RESET}
${COLOR_BORDER}║${COLOR_RESET} ${COLOR_LABEL}Dysk /home:${COLOR_RESET} $(build_progress_bar "$disk_home_percent")  ${COLOR_INFO}(wolne: ${disk_home_free}K / ${disk_home_total}K)${COLOR_RESET}
${COLOR_BORDER}║${COLOR_RESET} ${COLOR_LABEL}Sieć:${COLOR_RESET} ${COLOR_VALUE}${net_if}${COLOR_RESET}  ${COLOR_INFO}RX: ${net_rx}MB | TX: ${net_tx}MB${COLOR_RESET}
${COLOR_BORDER}╠════════════════════════════════════════════════════════════════════════════════════════╣${COLOR_RESET}
${COLOR_BORDER}║${COLOR_RESET} $(render_action_bar "$focused_index")
${COLOR_BORDER}║${COLOR_RESET} ${COLOR_INFO}Odświeżanie: ${refresh_hz}Hz  ([+] szybciej, [-] wolniej)${COLOR_RESET}
${COLOR_BORDER}║${COLOR_RESET} ${COLOR_INFO}Enter: aktywuj pole | q: powrót/wyjście | h: szybkie instrukcje${COLOR_RESET}
${COLOR_BORDER}╚════════════════════════════════════════════════════════════════════════════════════════╝${COLOR_RESET}
EOT
    render_materials_section "$selected_material_index" "$focus_zone"
}

main() {
    local mode="interactive"
    local refresh_index=2
    local refresh_hz
    local refresh_timeout
    local focused_control=0
    local focus_zone="actions"
    local selected_material_index=0
    local material_files=()
    local key

    case "${1:-}" in
        --snapshot)
            mode="snapshot"
            ;;
        --list-instructions)
            discover_material_files
            return 0
            ;;
    esac

    if [[ "$mode" == "snapshot" ]]; then
        render_screen "${REFRESH_HZ_LEVELS[$refresh_index]}"
        return 0
    fi

    trap cleanup_terminal EXIT INT TERM
    setup_terminal
    mapfile -t material_files < <(discover_material_files)

    while true; do
        mapfile -t material_files < <(discover_material_files)
        if (( ${#material_files[@]} == 0 )); then
            selected_material_index=0
        elif (( selected_material_index > ${#material_files[@]} - 1 )); then
            selected_material_index=$((${#material_files[@]} - 1))
        fi

        refresh_hz="${REFRESH_HZ_LEVELS[$refresh_index]}"
        refresh_timeout="${REFRESH_TIMEOUT_LEVELS[$refresh_index]}"
        render_screen "$refresh_hz" "$focused_control" "$focus_zone" "$selected_material_index"

        if key="$(read_input_key "$refresh_timeout")"; then
            case "$key" in
                q|Q)
                    break
                    ;;
                r|R)
                    continue
                    ;;
                LEFT)
                    if [[ "$focus_zone" == "actions" ]]; then
                        focused_control="$(move_selection "$focused_control" "left" "${#ACTION_LABELS[@]}")"
                    fi
                    ;;
                RIGHT)
                    if [[ "$focus_zone" == "actions" ]]; then
                        focused_control="$(move_selection "$focused_control" "right" "${#ACTION_LABELS[@]}")"
                    fi
                    ;;
                UP)
                    if [[ "$focus_zone" == "files" ]]; then
                        if (( selected_material_index > 0 )); then
                            selected_material_index=$((selected_material_index - 1))
                        else
                            focus_zone="actions"
                        fi
                    fi
                    ;;
                DOWN)
                    if [[ "$focus_zone" == "actions" ]] && (( ${#material_files[@]} > 0 )); then
                        focus_zone="files"
                    elif [[ "$focus_zone" == "files" ]] && (( selected_material_index < ${#material_files[@]} - 1 )); then
                        selected_material_index=$((selected_material_index + 1))
                    fi
                    ;;
                ENTER)
                    if [[ "$focus_zone" == "files" ]]; then
                        if (( ${#material_files[@]} > 0 )); then
                            open_material_file "${material_files[$selected_material_index]}"
                        fi
                    else
                        case "$focused_control" in
                            0)
                                refresh_index="$(decrease_refresh_rate "$refresh_index")"
                                ;;
                            1)
                                refresh_index="$(increase_refresh_rate "$refresh_index")"
                                ;;
                            2)
                                continue
                                ;;
                            3)
                                break
                                ;;
                        esac
                    fi
                    ;;
                LEFT)
                    focused_control="$(move_selection "$focused_control" "left" "${#ACTION_LABELS[@]}")"
                    ;;
                RIGHT)
                    focused_control="$(move_selection "$focused_control" "right" "${#ACTION_LABELS[@]}")"
                    ;;
                ENTER)
                    case "$focused_control" in
                        0)
                            show_instructions
                            ;;
                        1)
                            refresh_index="$(decrease_refresh_rate "$refresh_index")"
                            ;;
                        2)
                            refresh_index="$(increase_refresh_rate "$refresh_index")"
                            ;;
                        3)
                            continue
                            ;;
                        4)
                            break
                            ;;
                    esac
                    ;;
                +)
                    refresh_index="$(increase_refresh_rate "$refresh_index")"
                    ;;
                -)
                    refresh_index="$(decrease_refresh_rate "$refresh_index")"
                    ;;
            esac
        fi
    done
}

main "$@"
