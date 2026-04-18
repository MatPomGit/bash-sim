#!/usr/bin/env bash

# Moduł silnika Gry w Życie.
# Udostępnia funkcje operujące na planszy 2D zapisanej jako tablica 1D.

# Inicjalizuje globalne zmienne silnika.
life_engine_init() {
  LIFE_WIDTH=$1
  LIFE_HEIGHT=$2
  LIFE_WRAP=${3:-1}
  LIFE_SIZE=$((LIFE_WIDTH * LIFE_HEIGHT))

  declare -g -a LIFE_GRID
  declare -g -a LIFE_NEXT

  local i
  for ((i = 0; i < LIFE_SIZE; i++)); do
    LIFE_GRID[i]=0
    LIFE_NEXT[i]=0
  done
}

# Ustawia tryb zawijania krawędzi: 1 = torus, 0 = twarde granice.
life_set_wrap() {
  LIFE_WRAP=$1
}

# Czyści planszę.
life_clear() {
  local i
  for ((i = 0; i < LIFE_SIZE; i++)); do
    LIFE_GRID[i]=0
  done
}

# Losowo zasiewa planszę według gęstości procentowej.
life_seed_random() {
  local density=$1
  local i
  for ((i = 0; i < LIFE_SIZE; i++)); do
    if ((RANDOM % 100 < density)); then
      LIFE_GRID[i]=1
    else
      LIFE_GRID[i]=0
    fi
  done
}

# Zwraca wartość komórki; poza planszą zwraca 0 w trybie bez zawijania.
life_get_cell() {
  local row=$1
  local col=$2

  if ((LIFE_WRAP == 1)); then
    row=$(((row + LIFE_HEIGHT) % LIFE_HEIGHT))
    col=$(((col + LIFE_WIDTH) % LIFE_WIDTH))
  else
    if ((row < 0 || row >= LIFE_HEIGHT || col < 0 || col >= LIFE_WIDTH)); then
      echo 0
      return
    fi
  fi

  echo "${LIFE_GRID[row * LIFE_WIDTH + col]}"
}

# Ustawia wartość pojedynczej komórki, jeśli mieści się w granicach planszy.
life_set_cell() {
  local row=$1
  local col=$2
  local value=$3

  if ((row < 0 || row >= LIFE_HEIGHT || col < 0 || col >= LIFE_WIDTH)); then
    return
  fi

  LIFE_GRID[row * LIFE_WIDTH + col]=$value
}

# Zlicza żywych sąsiadów komórki.
life_count_neighbors() {
  local row=$1
  local col=$2
  local neighbors=0
  local dr dc

  for dr in -1 0 1; do
    for dc in -1 0 1; do
      if ((dr == 0 && dc == 0)); then
        continue
      fi
      neighbors=$((neighbors + $(life_get_cell $((row + dr)) $((col + dc)))))
    done
  done

  echo "$neighbors"
}

# Wykonuje jeden krok symulacji i zwraca liczbę żywych komórek po kroku.
life_step() {
  local row col idx current neighbors live_count=0

  for ((row = 0; row < LIFE_HEIGHT; row++)); do
    for ((col = 0; col < LIFE_WIDTH; col++)); do
      idx=$((row * LIFE_WIDTH + col))
      current=${LIFE_GRID[idx]}
      neighbors=$(life_count_neighbors "$row" "$col")

      if ((current == 1)); then
        if ((neighbors == 2 || neighbors == 3)); then
          LIFE_NEXT[idx]=1
        else
          LIFE_NEXT[idx]=0
        fi
      else
        if ((neighbors == 3)); then
          LIFE_NEXT[idx]=1
        else
          LIFE_NEXT[idx]=0
        fi
      fi
      live_count=$((live_count + LIFE_NEXT[idx]))
    done
  done

  for ((idx = 0; idx < LIFE_SIZE; idx++)); do
    LIFE_GRID[idx]=${LIFE_NEXT[idx]}
  done

  echo "$live_count"
}

# Wstawia wzorzec 2D (lista stringów 0/1) z podanym przesunięciem.
life_place_pattern() {
  local base_row=$1
  local base_col=$2
  shift 2
  local pattern=("$@")

  local r c row_str cell
  for ((r = 0; r < ${#pattern[@]}; r++)); do
    row_str=${pattern[r]}
    for ((c = 0; c < ${#row_str}; c++)); do
      cell=${row_str:c:1}
      if [[ "$cell" == "1" ]]; then
        life_set_cell $((base_row + r)) $((base_col + c)) 1
      fi
    done
  done
}
