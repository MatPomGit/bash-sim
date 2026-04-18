#!/usr/bin/env bash
# lib/ui.sh – User interface helper functions

# shellcheck source=lib/colors.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/colors.sh"

TERM_WIDTH=78

# ──────────────────────────────────────────────────────────────────────────────
# Terminal window management
# ──────────────────────────────────────────────────────────────────────────────

# Attempt to resize the terminal window to half the screen height, full width.
# Works only in xterm-compatible terminals; silently ignored elsewhere.
ui_resize_half_screen() {
    [[ "${BASH_RPG_TESTING:-}" == "1" ]] && return 0
    [[ -t 1 ]] || return 0
    # Query full screen size via xrandr or fallback to common defaults
    local screen_rows screen_cols
    if command -v xrandr &>/dev/null; then
        local res
        res=$(xrandr 2>/dev/null | awk '/\*/ {print $1; exit}')
        if [[ "$res" =~ ^([0-9]+)x([0-9]+)$ ]]; then
            local px_w=${BASH_REMATCH[1]}
            local px_h=${BASH_REMATCH[2]}
            # Approximate character cell size: 9×18 px (varies by font/terminal)
            screen_cols=$(( px_w / 9 ))
            screen_rows=$(( px_h / 18 / 2 ))
        fi
    fi
    # Fallback: use 40 rows, 160 columns as a reasonable half-screen size
    screen_rows="${screen_rows:-40}"
    screen_cols="${screen_cols:-160}"
    # Clamp to sane bounds to guard against unexpected xrandr output
    [[ $screen_rows -lt 10 ]] && screen_rows=10
    [[ $screen_rows -gt 500 ]] && screen_rows=500
    [[ $screen_cols -lt 40 ]] && screen_cols=40
    [[ $screen_cols -gt 1000 ]] && screen_cols=1000
    # xterm resize escape sequence
    printf '\033[8;%d;%dt' "$screen_rows" "$screen_cols"
    TERM_WIDTH=$(( screen_cols < 160 ? screen_cols : 160 ))
}

# ──────────────────────────────────────────────────────────────────────────────
# Basic primitives
# ──────────────────────────────────────────────────────────────────────────────

ui_clear() {
    clear
}

# Print a horizontal rule of given character
ui_hr() {
    local char="${1:-─}"
    local width="${2:-$TERM_WIDTH}"
    printf "${COLOR_BORDER}"
    printf "%${width}s" | tr ' ' "${char}"
    printf "${RESET}\n"
}

# Center text within TERM_WIDTH
ui_center() {
    local text="$1"
    # Strip ANSI codes for length calculation
    local plain
    plain=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
    local len=${#plain}
    local pad=$(( (TERM_WIDTH - len) / 2 ))
    printf "%${pad}s%b\n" "" "$text"
}

# Print colored text followed by newline
ui_print() {
    local color="$1"; shift
    printf "%b%s%b\n" "$color" "$*" "$RESET"
}

# ──────────────────────────────────────────────────────────────────────────────
# Game logo / title screen
# ──────────────────────────────────────────────────────────────────────────────

ui_title_screen() {
    ui_clear
    echo
    ui_hr "═"
    printf "%b" "${COLOR_TITLE}"
    ui_center " ██████╗  █████╗ ███████╗██╗  ██╗    ██████╗ ██████╗  ██████╗ "
    ui_center " ██╔══██╗██╔══██╗██╔════╝██║  ██║    ██╔══██╗██╔══██╗██╔════╝ "
    ui_center " ██████╔╝███████║███████╗███████║    ██████╔╝██████╔╝██║  ███╗ "
    ui_center " ██╔══██╗██╔══██║╚════██║██╔══██║    ██╔══██╗██╔═══╝ ██║   ██║ "
    ui_center " ██████╔╝██║  ██║███████║██║  ██║    ██║  ██║██║     ╚██████╔╝ "
    ui_center " ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝  ╚═╝╚═╝      ╚═════╝  "
    printf "%b" "${RESET}"
    ui_center "${BOLD_YELLOW}⚔  Kroniki Terminala  ⚔${RESET}"
    ui_center "${DIM}Opanuj konsolę Bash, by ocalić Królestwo${RESET}"
    echo
    ui_hr "═"
    echo
}

# ──────────────────────────────────────────────────────────────────────────────
# Section headers
# ──────────────────────────────────────────────────────────────────────────────

ui_header() {
    local title="$1"
    echo
    ui_hr "─"
    ui_center "${COLOR_TITLE}${title}${RESET}"
    ui_hr "─"
    echo
}

# ──────────────────────────────────────────────────────────────────────────────
# Dialog / story boxes
# ──────────────────────────────────────────────────────────────────────────────

ui_story() {
    local text="$1"
    echo
    printf "%b" "${COLOR_STORY}"
    printf "  %s\n" "$text"
    printf "%b" "${RESET}"
}

ui_dialog() {
    local speaker="$1"
    local text="$2"
    local color="${3:-$BOLD_WHITE}"
    echo
    printf "%b┌─ %s ─────────────────────────────────────────────────────%b\n" "${COLOR_BORDER}" "$speaker" "${RESET}"
    # Word-wrap at ~68 chars
    echo "$text" | fold -s -w 68 | while IFS= read -r line; do
        printf "%b│%b  %s\n" "${COLOR_BORDER}" "${color}" "$line"
    done
    printf "%b└──────────────────────────────────────────────────────────────%b\n" "${COLOR_BORDER}" "${RESET}"
    echo
}

# ──────────────────────────────────────────────────────────────────────────────
# Status bars
# ──────────────────────────────────────────────────────────────────────────────

# Draw a filled bar: ui_bar current max width fill_char empty_char
ui_bar() {
    local current="$1"
    local max="$2"
    local width="${3:-20}"
    local fill_char="${4:-█}"
    local empty_char="${5:-░}"
    local filled=$(( current * width / max ))
    [[ $filled -lt 0 ]] && filled=0
    [[ $filled -gt $width ]] && filled=$width
    local empty=$(( width - filled ))
    printf "%${filled}s" | tr ' ' "${fill_char}"
    printf "%${empty}s" | tr ' ' "${empty_char}"
}

hp_color() {
    local current="$1"; local max="$2"
    local pct=$(( current * 100 / max ))
    if   [[ $pct -ge 60 ]]; then printf "%b" "${COLOR_HP_HIGH}"
    elif [[ $pct -ge 30 ]]; then printf "%b" "${COLOR_HP_MED}"
    else                         printf "%b" "${COLOR_HP_LOW}"
    fi
}

ui_player_status() {
    local name="$PLAYER_NAME"
    local hp="$PLAYER_HP"
    local max_hp="$PLAYER_MAX_HP"
    local xp="$PLAYER_XP"
    local xp_next="$PLAYER_XP_NEXT"
    local level="$PLAYER_LEVEL"
    local gold="$PLAYER_GOLD"

    local hp_col; hp_col=$(hp_color "$hp" "$max_hp")
    echo
    ui_hr "─"
    printf " ${COLOR_PLAYER}%s${RESET}   Poz. ${BOLD_WHITE}%d${RESET}   " "$name" "$level"
    printf "PŻ: ${hp_col}%s${RESET} %b[%s%b]${RESET}   " "$hp/$max_hp" "${hp_col}" "$(ui_bar "$hp" "$max_hp" 15)" "${hp_col}"
    printf "PD: ${COLOR_XP}%d/%d${RESET}   " "$xp" "$xp_next"
    printf "${COLOR_GOLD}%d Zł${RESET}\n" "$gold"
    ui_hr "─"
}

ui_enemy_status() {
    local name="$1"
    local hp="$2"
    local max_hp="$3"
    local hp_col; hp_col=$(hp_color "$hp" "$max_hp")
    printf " ${COLOR_ENEMY}%s${RESET}   PŻ: ${hp_col}%d/%d [%s]${RESET}\n" \
        "$name" "$hp" "$max_hp" "$(ui_bar "$hp" "$max_hp" 15)"
}

# Wyświetla aktywne efekty statusu i ich czas trwania dla wybranego celu.
ui_combat_effects() {
    local target_name="$1"
    local stun_turns="$2"
    local bleed_turns="$3"
    local bleed_damage="$4"
    local shield_value="$5"

    local line=""
    if [[ $stun_turns -gt 0 ]]; then
        line+=" ${COLOR_WARNING}stun:${stun_turns}t${RESET}"
    fi
    if [[ $bleed_turns -gt 0 ]]; then
        line+=" ${COLOR_ERROR}bleed:${bleed_turns}t(${bleed_damage})${RESET}"
    fi
    if [[ $shield_value -gt 0 ]]; then
        line+=" ${BOLD_CYAN}shield:${shield_value}${RESET}"
    fi

    if [[ -n "$line" ]]; then
        printf "  %bEfekty (%s):%b%s\n" "${DIM}" "$target_name" "${RESET}" "$line"
    fi
}

# ──────────────────────────────────────────────────────────────────────────────
# Messages
# ──────────────────────────────────────────────────────────────────────────────

ui_success() {
    printf "\n  %b✔  %s%b\n\n" "${COLOR_SUCCESS}" "$*" "${RESET}"
}

ui_error() {
    printf "\n  %b✘  %s%b\n\n" "${COLOR_ERROR}" "$*" "${RESET}"
}

ui_warning() {
    printf "\n  %b⚠  %s%b\n\n" "${COLOR_WARNING}" "$*" "${RESET}"
}

ui_info() {
    printf "\n  %bℹ  %s%b\n\n" "${COLOR_HINT}" "$*" "${RESET}"
}

ui_xp_gain() {
    printf "  %b+%d PD%b\n" "${COLOR_XP}" "$1" "${RESET}"
}

ui_gold_gain() {
    printf "  %b+%d Złota%b\n" "${COLOR_GOLD}" "$1" "${RESET}"
}

ui_level_up() {
    local level="$1"
    echo
    ui_hr "★"
    ui_center "${BOLD_YELLOW}★  Awans na poziom! Osiągnąłeś poziom ${level}!  ★${RESET}"
    ui_hr "★"
    echo
}

# ──────────────────────────────────────────────────────────────────────────────
# Input helpers
# ──────────────────────────────────────────────────────────────────────────────

press_enter() {
    # Skip when running in test mode or when stdin is not an interactive terminal
    [[ "${BASH_RPG_TESTING:-}" == "1" ]] && return 0
    [[ -t 0 ]] || return 0
    printf "\n  %b[ Naciśnij ENTER, aby kontynuować... ]%b" "${DIM}" "${RESET}"
    read -r
    echo
}

ui_prompt() {
    local prompt="${1:-> }"
    printf "%b%s%b" "${COLOR_PROMPT}" "$prompt" "${RESET}"
}

ui_menu() {
    local title="$1"; shift
    local options=("$@")
    echo
    printf "  %b%s%b\n" "${BOLD_WHITE}" "$title" "${RESET}"
    echo
    local i=1
    for opt in "${options[@]}"; do
        printf "  %b[%d]%b %s\n" "${BOLD_CYAN}" "$i" "${RESET}" "$opt"
        (( i++ ))
    done
    echo
}

# ASCII art combat banner
ui_combat_banner() {
    local enemy_name="$1"
    echo
    printf "%b" "${BOLD_RED}"
    ui_center "⚔  Walka: ${enemy_name}  ⚔"
    printf "%b" "${RESET}"
    echo
}

# Typewriter effect for story text
ui_typewrite() {
    local text="$1"
    local delay="${2:-0.02}"
    printf "%b" "${COLOR_STORY}"
    for (( i=0; i<${#text}; i++ )); do
        printf "%s" "${text:$i:1}"
        sleep "$delay"
    done
    printf "%b\n" "${RESET}"
}

# ──────────────────────────────────────────────────────────────────────────────
# Animations
# ──────────────────────────────────────────────────────────────────────────────

# Startup loading animation shown before the main menu
ui_startup_animation() {
    [[ "${BASH_RPG_TESTING:-}" == "1" ]] && return 0
    ui_clear
    echo
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local msgs=(
        "Ładowanie kronik..."
        "Budzenie starożytnych sił..."
        "Kalibrowanie terminala..."
        "Przygotowywanie wyzwań..."
        "Gotowe!"
    )
    for msg in "${msgs[@]}"; do
        printf "\r  "
        for (( spin=0; spin<8; spin++ )); do
            printf "\r  %b%s%b  %s  " "${BOLD_CYAN}" "${frames[spin % ${#frames[@]}]}" "${RESET}" "$msg"
            sleep 0.07
        done
    done
    printf "\r%*s\r" "$TERM_WIDTH" ""   # clear line
    sleep 0.2
}

# Brief animation shown when combat begins
ui_combat_start_animation() {
    [[ "${BASH_RPG_TESTING:-}" == "1" ]] && return 0
    local enemy_name="$1"
    local sword_frames=("⚔  " " ⚔ " "  ⚔")
    echo
    for (( i=0; i<6; i++ )); do
        local frame="${sword_frames[i % ${#sword_frames[@]}]}"
        printf "\r  %b%s  Walka: %s  %s%b" \
            "${BOLD_RED}" "$frame" "$enemy_name" "$frame" "${RESET}"
        sleep 0.15
    done
    printf "\r%*s\r" "$TERM_WIDTH" ""   # clear line
    echo
}
