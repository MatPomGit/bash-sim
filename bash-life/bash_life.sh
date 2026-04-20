#!/usr/bin/env bash

# Interaktywny frontend terminalowy dla silnika Gry w Życie.
# Komentarze i opisy są po polsku, a kod pozostaje w angielskiej konwencji.

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# Wczytujemy wydzielony moduł silnika, aby oddzielić logikę od interfejsu.
source "$SCRIPT_DIR/life_engine.sh"

readonly DEFAULT_DENSITY=25
readonly DEFAULT_DELAY=0.15
readonly MIN_DELAY=0.03
readonly MAX_DELAY=1.00

INITIAL_WIDTH=0
INITIAL_HEIGHT=0
INITIAL_DELAY=$DEFAULT_DELAY
INITIAL_DENSITY=$DEFAULT_DENSITY
INITIAL_WRAP=1
START_PAUSED=0
INITIAL_PATTERN=""

DELAY=$DEFAULT_DELAY
PAUSED=0
RUNNING=1
SHOW_HELP=0
WRAP_MODE=1
GENERATION=0
LIVE_COUNT=0
AUTO_STOP=0
LAST_SIGNATURE=""

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
  if ((INITIAL_WIDTH > 0 && INITIAL_HEIGHT > 0)); then
    GRID_WIDTH=$INITIAL_WIDTH
    GRID_HEIGHT=$INITIAL_HEIGHT
  else
    TERM_ROWS=$(tput lines)
    TERM_COLS=$(tput cols)
    GRID_HEIGHT=$((TERM_ROWS - 2))
    GRID_WIDTH=$TERM_COLS
  fi

  if ((GRID_HEIGHT < 8 || GRID_WIDTH < 20)); then
    printf 'Terminal jest zbyt mały (min 20x8).\n' >&2
    exit 1
  fi
}

# Inicjalizuje silnik z aktualnym rozmiarem.
init_engine() {
  update_dimensions
  life_engine_init "$GRID_WIDTH" "$GRID_HEIGHT" "$WRAP_MODE"
  life_seed_random "$INITIAL_DENSITY"
  GENERATION=0
  LIVE_COUNT=$(life_count_live)
  LAST_SIGNATURE=$(life_grid_signature)
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
    toad)
      # Ropucha.
      life_place_pattern $((center_row - 1)) $((center_col - 2)) \
        "01110" \
        "11100"
      ;;
    lwss)
      # Lekki statek kosmiczny.
      life_place_pattern $((center_row - 2)) $((center_col - 2)) \
        "01001" \
        "10000" \
        "10001" \
        "11110"
      ;;
  esac
  LIVE_COUNT=$(life_count_live)
  LAST_SIGNATURE=$(life_grid_signature)
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
  local auto_stop_label="OFF"
  if ((PAUSED == 1)); then mode="PAUZA"; fi
  if ((WRAP_MODE == 0)); then wrap_label="BORDER"; fi
  if ((AUTO_STOP == 1)); then auto_stop_label="ON"; fi

  tput el
  printf 'Gen: %d | Tryb: %s | Żywe: %d | Delay: %.2fs | Krawędzie: %s | AutoStop: %s' \
    "$GENERATION" "$mode" "$LIVE_COUNT" "$DELAY" "$wrap_label" "$auto_stop_label"
}

# Rysuje skróconą pomoc na ostatniej linii.
render_help_line() {
  tput cup $((GRID_HEIGHT + 1)) 0
  tput el
  if ((SHOW_HELP == 1)); then
    printf '[q] wyjście [p] pauza [n] krok [r] losuj [c] czyść [w] zawijanie [a] auto-stop [g/b/u/t/l] wzorce [+/-] prędkość [h] pomoc'
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

# Pokazuje krótką pomoc parametrów startowych.
print_usage() {
  cat <<'EOF'
Użycie:
  ./bash-life/bash_life.sh [opcje]

Opcje:
  --width N         Szerokość planszy (min. 20)
  --height N        Wysokość planszy (min. 8)
  --density N       Gęstość startowa 0-100
  --delay X         Opóźnienie między krokami (sekundy)
  --wrap MODE       Tryb krawędzi: torus|border
  --paused          Uruchomienie od razu w pauzie
  --pattern NAME    Wzorzec startowy: glider|blinker|pulsar|toad|lwss
  --help            Pokazuje tę pomoc
EOF
}

# Waliduje czy wartość to liczba całkowita.
is_integer() {
  [[ $1 =~ ^[0-9]+$ ]]
}

# Parsuje parametry przekazane przy uruchomieniu programu.
parse_args() {
  while (($# > 0)); do
    case "$1" in
      --width)
        shift
        is_integer "${1:-}" || { printf 'Błąd: --width wymaga liczby całkowitej.\n' >&2; exit 1; }
        INITIAL_WIDTH=$1
        ;;
      --height)
        shift
        is_integer "${1:-}" || { printf 'Błąd: --height wymaga liczby całkowitej.\n' >&2; exit 1; }
        INITIAL_HEIGHT=$1
        ;;
      --density)
        shift
        is_integer "${1:-}" || { printf 'Błąd: --density wymaga liczby 0-100.\n' >&2; exit 1; }
        if (($1 < 0 || $1 > 100)); then
          printf 'Błąd: --density musi być w zakresie 0-100.\n' >&2
          exit 1
        fi
        INITIAL_DENSITY=$1
        ;;
      --delay)
        shift
        if [[ ! "${1:-}" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
          printf 'Błąd: --delay wymaga liczby dodatniej.\n' >&2
          exit 1
        fi
        if ! awk -v d="$1" -v min="$MIN_DELAY" -v max="$MAX_DELAY" 'BEGIN { exit !(d >= min && d <= max) }'; then
          printf 'Błąd: --delay musi być w zakresie %.2f - %.2f.\n' "$MIN_DELAY" "$MAX_DELAY" >&2
          exit 1
        fi
        INITIAL_DELAY=$1
        ;;
      --wrap)
        shift
        case "${1:-}" in
          torus) INITIAL_WRAP=1 ;;
          border) INITIAL_WRAP=0 ;;
          *)
            printf 'Błąd: --wrap przyjmuje wartości torus albo border.\n' >&2
            exit 1
            ;;
        esac
        ;;
      --paused)
        START_PAUSED=1
        ;;
      --pattern)
        shift
        case "${1:-}" in
          glider|blinker|pulsar|toad|lwss) INITIAL_PATTERN=$1 ;;
          *)
            printf 'Błąd: --pattern wymaga: glider|blinker|pulsar|toad|lwss.\n' >&2
            exit 1
            ;;
        esac
        ;;
      --help|-h)
        print_usage
        exit 0
        ;;
      *)
        printf 'Błąd: nieznana opcja "%s". Użyj --help.\n' "$1" >&2
        exit 1
        ;;
    esac
    shift
  done
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
        life_seed_random "$INITIAL_DENSITY"
        GENERATION=0
        LIVE_COUNT=$(life_count_live)
        LAST_SIGNATURE=$(life_grid_signature)
        ;;
      c)
        life_clear
        GENERATION=0
        LIVE_COUNT=0
        LAST_SIGNATURE=$(life_grid_signature)
        ;;
      w)
        WRAP_MODE=$((1 - WRAP_MODE))
        life_set_wrap "$WRAP_MODE"
        ;;
      a) AUTO_STOP=$((1 - AUTO_STOP)) ;;
      g) place_pattern_center glider ;;
      b) place_pattern_center blinker ;;
      u) place_pattern_center pulsar ;;
      t) place_pattern_center toad ;;
      l) place_pattern_center lwss ;;
      +) adjust_delay up ;;
      -) adjust_delay down ;;
    esac
  fi
}

# Główna pętla aplikacji.
main() {
  parse_args "$@"

  if [[ ! -t 0 || ! -t 1 ]]; then
    printf 'Ten program musi być uruchomiony bezpośrednio w terminalu (TTY).\n' >&2
    exit 1
  fi

  DELAY=$INITIAL_DELAY
  WRAP_MODE=$INITIAL_WRAP
  PAUSED=$START_PAUSED

  init_engine
  if [[ -n "$INITIAL_PATTERN" ]]; then
    life_clear
    place_pattern_center "$INITIAL_PATTERN"
    GENERATION=0
  fi

  tput smcup
  tput civis
  tput clear
  stty -echo -icanon time 0 min 0

  while ((RUNNING == 1)); do
    handle_input

    if ((PAUSED == 0)); then
      local previous_signature=$LAST_SIGNATURE
      LIVE_COUNT=$(life_step)
      GENERATION=$((GENERATION + 1))
      LAST_SIGNATURE=$(life_grid_signature)

      if ((AUTO_STOP == 1 && LAST_SIGNATURE == previous_signature)); then
        PAUSED=1
      fi
    fi

    render
    sleep "$DELAY"
  done
}

main "$@"
