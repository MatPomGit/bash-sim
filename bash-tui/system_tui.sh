#!/usr/bin/env bash

# Bash TUI prezentujący najważniejsze informacje systemowe.
# Interfejs i komentarze są w języku polskim, zgodnie z wymaganiami projektu.

set -o errexit
set -o nounset
set -o pipefail

readonly APP_NAME="bash-tui"
readonly VERSION_PREFIX="1.0"
readonly AUTHORS="KIA, Katedra Informatyki i Automatyki, Politechnika Rzeszowska"
readonly REFRESH_SECONDS=1

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

# Przełącza terminal w tryb „pełnoekranowy” (alt-screen + próba maksymalizacji okna).
setup_terminal() {
    printf '\e[9;1t' || true
    tput smcup || true
    tput civis || true
    clear || true
}

# Zwraca obciążenie CPU w procentach.
get_cpu_usage() {
    local cpu_line idle total busy
    cpu_line="$(grep '^cpu ' /proc/stat)"
    read -r _ user nice system idle iowait irq softirq steal _ <<<"$cpu_line"
    total=$((user + nice + system + idle + iowait + irq + softirq + steal))
    busy=$((total - idle - iowait))

    sleep 0.2

    cpu_line="$(grep '^cpu ' /proc/stat)"
    read -r _ user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2 _ <<<"$cpu_line"
    local total2 busy2
    total2=$((user2 + nice2 + system2 + idle2 + iowait2 + irq2 + softirq2 + steal2))
    busy2=$((total2 - idle2 - iowait2))

    local total_diff busy_diff
    total_diff=$((total2 - total))
    busy_diff=$((busy2 - busy))

    if (( total_diff == 0 )); then
        echo "0"
    else
        echo $((100 * busy_diff / total_diff))
    fi
}

# Buduje pasek postępu dla procentów.
build_progress_bar() {
    local percent="$1"
    local width=30
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    printf "["
    printf "%${filled}s" "" | tr ' ' '#'
    printf "%${empty}s" "" | tr ' ' '.'
    printf "] %3s%%" "$percent"
}

# Zwraca wykorzystanie pamięci RAM w procentach.
get_memory_usage() {
    local total available used percent
    total="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"
    available="$(awk '/MemAvailable/ {print $2}' /proc/meminfo)"
    used=$((total - available))
    percent=$((100 * used / total))
    echo "$percent"
}

# Zwraca wykorzystanie głównego systemu plików w procentach.
get_disk_usage() {
    df -P / | awk 'NR==2 {gsub("%", "", $5); print $5}'
}

# Rysuje pojedynczy ekran TUI.
render_screen() {
    local version hostname kernel uptime_str load_avg ip_addr cpu_percent memory_percent disk_percent

    version="$(get_version)"
    hostname="$(hostname)"
    kernel="$(uname -sr)"
    uptime_str="$(uptime -p 2>/dev/null || true)"
    load_avg="$(awk '{print $1" "$2" "$3}' /proc/loadavg)"
    ip_addr="$(hostname -I 2>/dev/null | awk '{print $1}')"
    cpu_percent="$(get_cpu_usage)"
    memory_percent="$(get_memory_usage)"
    disk_percent="$(get_disk_usage)"

    clear || true
    cat <<EOT
╔════════════════════════════════════════════════════════════════════════════╗
║                              MONITOR SYSTEMU                              ║
╠════════════════════════════════════════════════════════════════════════════╣
║ Aplikacja: ${APP_NAME}
║ Wersja (auto): ${version}
║ Autorzy: ${AUTHORS}
╠════════════════════════════════════════════════════════════════════════════╣
║ Host: ${hostname}
║ Jądro systemu: ${kernel}
║ Czas działania: ${uptime_str}
║ Średnie obciążenie (1m/5m/15m): ${load_avg}
║ Adres IP: ${ip_addr:-brak}
╠════════════════════════════════════════════════════════════════════════════╣
║ CPU:     $(build_progress_bar "$cpu_percent")
║ RAM:     $(build_progress_bar "$memory_percent")
║ Dysk /:  $(build_progress_bar "$disk_percent")
╠════════════════════════════════════════════════════════════════════════════╣
║ Sterowanie: [q] wyjście, [r] odśwież natychmiast
╚════════════════════════════════════════════════════════════════════════════╝
EOT
}

main() {
    local mode="interactive"
    if [[ "${1:-}" == "--snapshot" ]]; then
        mode="snapshot"
    fi

    if [[ "$mode" == "snapshot" ]]; then
        render_screen
        return 0
    fi

    trap cleanup_terminal EXIT INT TERM
    setup_terminal

    while true; do
        render_screen

        if read -r -s -n 1 -t "$REFRESH_SECONDS" key; then
            case "$key" in
                q|Q)
                    break
                    ;;
                r|R)
                    continue
                    ;;
            esac
        fi
    done
}

main "$@"
