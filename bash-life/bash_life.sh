#!/usr/bin/env bash

# Interaktywny frontend terminalowy dla silnika Gry w Życie.
# Komentarze i opisy są po polsku, a kod pozostaje w angielskiej konwencji.

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# Wczytujemy wydzielony moduł silnika, aby oddzielić logikę od interfejsu.
source "$SCRIPT_DIR/life_engine.sh"

readonly DEFAULT_DENSITY=25
readonly MIN_DELAY=0.03
readonly MAX_DELAY=1.00

DELAY=0.15
PAUSED=0
RUNNING=1
SHOW_HELP=0
WRAP_MODE=1
GENERATION=0
LIVE_COUNT=0

# Czyści terminal i przywraca ustawienia.
cleanup() {
  tput sgr0 || true
  tput cnorm || true
  tput rmcup || true
  if [[ -t 0 ]]; then
    stty sane || true
  fi
}

# Obsługa kończenia programu.
on_exit() {
  RUNNING=0
  cleanup
}
trap on_exit EXIT INT TERM

# Wyznacza geometrię planszy z aktualnego rozmiaru terminala.
update_dimensions() {
  TERM_ROWS=$(tput lines)
  TERM_COLS=$(tput cols)
  GRID_HEIGHT=$((TERM_ROWS - 2))
  GRID_WIDTH=$TERM_COLS

  if ((GRID_HEIGHT < 8 || GRID_WIDTH < 20)); then
    printf 'Terminal jest zbyt mały (min 20x8).\n' >&2
    exit 1
  fi
}

# Inicjalizuje silnik z aktualnym rozmiarem.
init_engine() {
  update_dimensions
  life_engine_init "$GRID_WIDTH" "$GRID_HEIGHT" "$WRAP_MODE"
  life_seed_random "$DEFAULT_DENSITY"
  GENERATION=0
}

# Wstawia przykładowe wzorce na środek planszy.
place_pattern_center() {
  local pattern_name=$1
  local center_row=$((GRID_HEIGHT / 2))
  local center_col=$((GRID_WIDTH / 2))

  case "$pattern_name" in
    glider)
      # Szybowiec.
      life_place_pattern $((center_row - 1)) $((center_col - 1)) \
        "010" \
        "001" \
        "111"
      ;;
    blinker)
      # Migacz.
      life_place_pattern "$center_row" $((center_col - 1)) "111"
      ;;
    pulsar)
      # Uproszczony pulsar (część wzorca), dobry do demonstracji oscylacji.
      life_place_pattern $((center_row - 2)) $((center_col - 2)) \
        "00100" \
        "00100" \
        "11111" \
        "00100" \
        "00100"
      ;;
  esac
}

# Rysuje bieżącą planszę.
render_grid() {
  local row col idx line
  tput cup 0 0

  for ((row = 0; row < GRID_HEIGHT; row++)); do
    line=""
    for ((col = 0; col < GRID_WIDTH; col++)); do
      idx=$((row * GRID_WIDTH + col))
      if ((LIFE_GRID[idx] == 1)); then
        line+="█"
      else
        line+=" "
      fi
    done
    printf '%s\n' "$line"
  done
}

# Rysuje pasek statusu.
render_status() {
  local mode="RUN"
  local wrap_label="TORUS"
  if ((PAUSED == 1)); then mode="PAUZA"; fi
  if ((WRAP_MODE == 0)); then wrap_label="BORDER"; fi

  tput el
  printf 'Gen: %d | Tryb: %s | Żywe: %d | Delay: %.2fs | Krawędzie: %s' \
    "$GENERATION" "$mode" "$LIVE_COUNT" "$DELAY" "$wrap_label"
}

# Rysuje skróconą pomoc na ostatniej linii.
render_help_line() {
  tput cup $((GRID_HEIGHT + 1)) 0
  tput el
  if ((SHOW_HELP == 1)); then
    printf '[q] wyjście [p] pauza [n] krok [r] losuj [c] czyść [w] zawijanie [g] glider [b] blinker [u] pulsar [+/-] prędkość [h] pomoc'
  else
    printf '[h] pomoc'
  fi
}

# Rysuje wszystko.
render() {
  render_grid
  tput cup "$GRID_HEIGHT" 0
  render_status
  render_help_line
}

# Zmienia szybkość symulacji.
adjust_delay() {
  local dir=$1
  if [[ "$dir" == "up" ]]; then
    DELAY=$(awk -v d="$DELAY" -v min="$MIN_DELAY" 'BEGIN { d = d - 0.02; if (d < min) d = min; printf "%.2f", d }')
  else
    DELAY=$(awk -v d="$DELAY" -v max="$MAX_DELAY" 'BEGIN { d = d + 0.02; if (d > max) d = max; printf "%.2f", d }')
  fi
}

# Obsługuje wejście z klawiatury.
handle_input() {
  local key
  if read -rsn1 -t 0.01 key; then
    case "$key" in
      q) RUNNING=0 ;;
      p) PAUSED=$((1 - PAUSED)) ;;
      h) SHOW_HELP=$((1 - SHOW_HELP)) ;;
      n)
        if ((PAUSED == 1)); then
          LIVE_COUNT=$(life_step)
          GENERATION=$((GENERATION + 1))
        fi
        ;;
      r)
        life_seed_random "$DEFAULT_DENSITY"
        GENERATION=0
        ;;
      c)
        life_clear
        GENERATION=0
        LIVE_COUNT=0
        ;;
      w)
        WRAP_MODE=$((1 - WRAP_MODE))
        life_set_wrap "$WRAP_MODE"
        ;;
      g) place_pattern_center glider ;;
      b) place_pattern_center blinker ;;
      u) place_pattern_center pulsar ;;
      +) adjust_delay up ;;
      -) adjust_delay down ;;
    esac
  fi
}

# Główna pętla aplikacji.
main() {
  if [[ ! -t 0 || ! -t 1 ]]; then
    printf 'Ten program musi być uruchomiony bezpośrednio w terminalu (TTY).\n' >&2
    exit 1
  fi

  init_engine

  tput smcup
  tput civis
  tput clear
  stty -echo -icanon time 0 min 0

  while ((RUNNING == 1)); do
    handle_input

    if ((PAUSED == 0)); then
      LIVE_COUNT=$(life_step)
      GENERATION=$((GENERATION + 1))
    fi

    render
    sleep "$DELAY"
  done
}

main "$@"
