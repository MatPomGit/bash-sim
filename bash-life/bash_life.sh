#!/usr/bin/env bash

# Symulacja 2D gry w życie Conwaya uruchamiana w terminalu.
# Sterowanie:
#   q - wyjście z programu
#   p - pauza/wznowienie
#   n - wykonaj pojedynczy krok (gdy pauza)
#   r - losuj nową planszę
#   c - wyczyść planszę
#   +/- - zmiana szybkości symulacji

set -euo pipefail

# Domyślna konfiguracja symulacji.
readonly DEFAULT_DENSITY=25
readonly MIN_DELAY=0.03
readonly MAX_DELAY=1.00

DELAY=0.15
PAUSED=0
RUNNING=1

# Tablice przechowujące aktualny i następny stan komórek.
declare -a grid next

# Czyści środowisko terminala i przywraca jego ustawienia po zakończeniu programu.
cleanup() {
  tput sgr0 || true
  tput cnorm || true
  tput rmcup || true
  # Przywracamy ustawienia TTY tylko wtedy, gdy wejście jest terminalem.
  if [[ -t 0 ]]; then
    stty sane || true
  fi
}

# Obsługuje zakończenie programu przez sygnał i gwarantuje poprawne sprzątanie.
on_exit() {
  RUNNING=0
  cleanup
}

trap on_exit EXIT INT TERM

# Wyznacza aktualny rozmiar planszy na podstawie rozmiaru terminala.
update_dimensions() {
  TERM_ROWS=$(tput lines)
  TERM_COLS=$(tput cols)

  # Ostatni wiersz pozostawiamy na pasek statusu.
  GRID_HEIGHT=$((TERM_ROWS - 1))
  GRID_WIDTH=$TERM_COLS

  if ((GRID_HEIGHT < 5 || GRID_WIDTH < 10)); then
    printf 'Terminal jest zbyt mały (min 10x5).\n' >&2
    exit 1
  fi

  GRID_SIZE=$((GRID_HEIGHT * GRID_WIDTH))
}

# Zwraca indeks tablicy 1D dla współrzędnych 2D.
idx() {
  local row=$1
  local col=$2
  echo $((row * GRID_WIDTH + col))
}

# Inicjalizuje planszę losowym rozkładem żywych komórek.
seed_random() {
  local i
  for ((i = 0; i < GRID_SIZE; i++)); do
    if ((RANDOM % 100 < DEFAULT_DENSITY)); then
      grid[i]=1
    else
      grid[i]=0
    fi
  done
}

# Czyści planszę (ustawia wszystkie komórki jako martwe).
clear_grid() {
  local i
  for ((i = 0; i < GRID_SIZE; i++)); do
    grid[i]=0
  done
}

# Zlicza żywych sąsiadów z zawijaniem krawędzi (topologia torusa).
count_neighbors() {
  local row=$1
  local col=$2
  local neighbors=0

  local dr dc rr cc nidx
  for dr in -1 0 1; do
    for dc in -1 0 1; do
      if ((dr == 0 && dc == 0)); then
        continue
      fi

      rr=$(((row + dr + GRID_HEIGHT) % GRID_HEIGHT))
      cc=$(((col + dc + GRID_WIDTH) % GRID_WIDTH))
      nidx=$((rr * GRID_WIDTH + cc))
      neighbors=$((neighbors + grid[nidx]))
    done
  done

  echo "$neighbors"
}

# Wykonuje pojedynczą iterację reguł Conwaya.
step_simulation() {
  local row col current alive neighbors cell_idx

  for ((row = 0; row < GRID_HEIGHT; row++)); do
    for ((col = 0; col < GRID_WIDTH; col++)); do
      cell_idx=$((row * GRID_WIDTH + col))
      current=${grid[cell_idx]}
      neighbors=$(count_neighbors "$row" "$col")

      if ((current == 1)); then
        if ((neighbors == 2 || neighbors == 3)); then
          next[cell_idx]=1
        else
          next[cell_idx]=0
        fi
      else
        if ((neighbors == 3)); then
          next[cell_idx]=1
        else
          next[cell_idx]=0
        fi
      fi
    done
  done

  for ((alive = 0; alive < GRID_SIZE; alive++)); do
    grid[alive]=${next[alive]}
  done
}

# Rysuje aktualną planszę i pasek statusu w terminalu.
render() {
  local row col cell_idx
  local line
  local live_count=0

  tput cup 0 0

  for ((row = 0; row < GRID_HEIGHT; row++)); do
    line=""
    for ((col = 0; col < GRID_WIDTH; col++)); do
      cell_idx=$((row * GRID_WIDTH + col))
      if ((grid[cell_idx] == 1)); then
        line+="█"
        live_count=$((live_count + 1))
      else
        line+=" "
      fi
    done
    printf '%s\n' "$line"
  done

  local mode="RUN"
  if ((PAUSED == 1)); then
    mode="PAUZA"
  fi

  tput el
  printf 'Tryb: %s | Żywe: %d | Delay: %.2fs | [p] pauza [n] krok [r] losuj [c] czyść [+/-] szybkość [q] wyjście' \
    "$mode" "$live_count" "$DELAY"
}

# Przetwarza wejście z klawiatury bez blokowania głównej pętli.
handle_input() {
  local key
  if read -rsn1 -t 0.01 key; then
    case "$key" in
      q)
        RUNNING=0
        ;;
      p)
        if ((PAUSED == 1)); then
          PAUSED=0
        else
          PAUSED=1
        fi
        ;;
      n)
        if ((PAUSED == 1)); then
          step_simulation
        fi
        ;;
      r)
        seed_random
        ;;
      c)
        clear_grid
        ;;
      +)
        DELAY=$(awk -v d="$DELAY" -v min="$MIN_DELAY" 'BEGIN { d = d - 0.02; if (d < min) d = min; printf "%.2f", d }')
        ;;
      -)
        DELAY=$(awk -v d="$DELAY" -v max="$MAX_DELAY" 'BEGIN { d = d + 0.02; if (d > max) d = max; printf "%.2f", d }')
        ;;
    esac
  fi
}

# Konfiguruje terminal i uruchamia główną pętlę symulacji.
main() {
  # Program jest interaktywny i wymaga terminala po stronie wejścia i wyjścia.
  if [[ ! -t 0 || ! -t 1 ]]; then
    printf 'Ten program musi być uruchomiony bezpośrednio w terminalu (TTY).\n' >&2
    exit 1
  fi

  update_dimensions

  tput smcup
  tput civis
  tput clear

  stty -echo -icanon time 0 min 0

  seed_random

  while ((RUNNING == 1)); do
    handle_input

    if ((PAUSED == 0)); then
      step_simulation
    fi

    render
    sleep "$DELAY"
  done
}

main "$@"
