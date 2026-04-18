#!/usr/bin/env bash
# lib/save_load.sh – Save and load game state

SAVE_DIR="${HOME}/.bash_rpg"
SAVE_FILE="${SAVE_DIR}/save.dat"
SAVE_FORMAT_VERSION="2"

# Minimalny zestaw kluczy wymaganych do uznania pliku zapisu za poprawny.
# Dzięki temu nie ładujemy uszkodzonego lub niekompletnego stanu gry.
SAVE_REQUIRED_KEYS=(
    PLAYER_NAME
    PLAYER_LEVEL
    PLAYER_XP
    PLAYER_XP_NEXT
    PLAYER_HP
    PLAYER_MAX_HP
    PLAYER_GOLD
    PLAYER_ATTACK
    PLAYER_DEFENSE
    PLAYER_TALENT_POINTS
    TALENT_OFFENSE_LEVEL
    TALENT_DEFENSE_LEVEL
    TALENT_KNOWLEDGE_LEVEL
    TALENT_KNOWLEDGE_HINTS
    CURRENT_LEVEL
)

# Koduje pojedynczy wpis ekwipunku do Base64.
# Powód: nazwy przedmiotów mogą zawierać spacje i znaki specjalne,
# więc format "jedna wartość po spacji" jest niejednoznaczny.
_save_encode_item() {
    printf '%s' "$1" | base64 | tr -d '\n='
}

# Dekoduje wpis ekwipunku zapisany w Base64.
_save_decode_item() {
    local payload="$1"
    local mod=$(( ${#payload} % 4 ))
    if [[ "$mod" -eq 2 ]]; then
        payload+="=="
    elif [[ "$mod" -eq 3 ]]; then
        payload+="="
    elif [[ "$mod" -eq 1 ]]; then
        return 1
    fi
    printf '%s' "$payload" | base64 --decode
}

save_game() {
    mkdir -p "$SAVE_DIR"

    {
        printf 'PLAYER_NAME=%s\n' "${PLAYER_NAME}"
        printf 'PLAYER_LEVEL=%s\n' "${PLAYER_LEVEL}"
        printf 'PLAYER_XP=%s\n' "${PLAYER_XP}"
        printf 'PLAYER_XP_NEXT=%s\n' "${PLAYER_XP_NEXT}"
        printf 'PLAYER_HP=%s\n' "${PLAYER_HP}"
        printf 'PLAYER_MAX_HP=%s\n' "${PLAYER_MAX_HP}"
        printf 'PLAYER_GOLD=%s\n' "${PLAYER_GOLD}"
        printf 'PLAYER_ATTACK=%s\n' "${PLAYER_ATTACK}"
        printf 'PLAYER_DEFENSE=%s\n' "${PLAYER_DEFENSE}"
        printf 'PLAYER_TALENT_POINTS=%s\n' "${PLAYER_TALENT_POINTS}"
        printf 'TALENT_OFFENSE_LEVEL=%s\n' "${TALENT_OFFENSE_LEVEL}"
        printf 'TALENT_DEFENSE_LEVEL=%s\n' "${TALENT_DEFENSE_LEVEL}"
        printf 'TALENT_KNOWLEDGE_LEVEL=%s\n' "${TALENT_KNOWLEDGE_LEVEL}"
        printf 'TALENT_KNOWLEDGE_HINTS=%s\n' "${TALENT_KNOWLEDGE_HINTS}"
        printf 'CURRENT_LEVEL=%s\n' "${CURRENT_LEVEL}"
        printf 'SAVE_FORMAT_VERSION=%s\n' "${SAVE_FORMAT_VERSION}"

        # Nowy, jednoznaczny format ekwipunku:
        # - liczba elementów w PLAYER_INVENTORY_COUNT
        # - każdy element jako osobny wpis Base64 PLAYER_INVENTORY_ITEM_<idx>_B64
        # Dzięki temu odczyt nie dzieli elementów po spacjach.
        printf 'PLAYER_INVENTORY_COUNT=%d\n' "${#PLAYER_INVENTORY[@]}"
        local idx
        for idx in "${!PLAYER_INVENTORY[@]}"; do
            printf 'PLAYER_INVENTORY_ITEM_%d_B64=%s\n' \
                "$idx" "$(_save_encode_item "${PLAYER_INVENTORY[$idx]}")"
        done
    } > "$SAVE_FILE"

    printf "  %b✔ Game saved.%b\n" "${COLOR_SUCCESS:-}" "${RESET:-}"
}

load_game() {
    [[ -f "$SAVE_FILE" ]] || return 1

    local key value
    local inventory_count=""
    local found_new_inventory_format=false
    local legacy_inventory_value=""
    local legacy_detected=false
    local idx
    local decoded_item
    local required_key
    local migration_needed=false
    local missing_required=false
    local keys_blob=""
    PLAYER_INVENTORY=()

    while IFS='=' read -r key value; do
        [[ "$key" =~ ^# ]] && continue
        [[ -z "$key" ]] && continue
        keys_blob+=$'\n'"$key"$'\n'

        case "$key" in
            PLAYER_NAME)      PLAYER_NAME="$value" ;;
            PLAYER_LEVEL)     PLAYER_LEVEL="$value" ;;
            PLAYER_XP)        PLAYER_XP="$value" ;;
            PLAYER_XP_NEXT)   PLAYER_XP_NEXT="$value" ;;
            PLAYER_HP)        PLAYER_HP="$value" ;;
            PLAYER_MAX_HP)    PLAYER_MAX_HP="$value" ;;
            PLAYER_GOLD)      PLAYER_GOLD="$value" ;;
            PLAYER_ATTACK)    PLAYER_ATTACK="$value" ;;
            PLAYER_DEFENSE)   PLAYER_DEFENSE="$value" ;;
            PLAYER_TALENT_POINTS) PLAYER_TALENT_POINTS="$value" ;;
            TALENT_OFFENSE_LEVEL) TALENT_OFFENSE_LEVEL="$value" ;;
            TALENT_DEFENSE_LEVEL) TALENT_DEFENSE_LEVEL="$value" ;;
            TALENT_KNOWLEDGE_LEVEL) TALENT_KNOWLEDGE_LEVEL="$value" ;;
            TALENT_KNOWLEDGE_HINTS) TALENT_KNOWLEDGE_HINTS="$value" ;;
            CURRENT_LEVEL)    CURRENT_LEVEL="$value" ;;
            PLAYER_INVENTORY_COUNT)
                inventory_count="$value"
                found_new_inventory_format=true
                ;;
            PLAYER_INVENTORY_ITEM_*_B64)
                idx="${key#PLAYER_INVENTORY_ITEM_}"
                idx="${idx%_B64}"
                decoded_item="$(_save_decode_item "$value" 2>/dev/null)" || return 1
                PLAYER_INVENTORY[$idx]="$decoded_item"
                found_new_inventory_format=true
                ;;
            PLAYER_INVENTORY)
                # Stary format: wszystkie przedmioty w jednej linii rozdzielone spacją.
                # Zachowujemy kompatybilność i po wczytaniu wykonujemy migrację do V2.
                legacy_inventory_value="$value"
                legacy_detected=true
                ;;
        esac
    done < "$SAVE_FILE"

    # Walidacja integralności: wymagamy minimalnego zestawu kluczy.
    for required_key in "${SAVE_REQUIRED_KEYS[@]}"; do
        if [[ "$keys_blob" != *$'\n'"$required_key"$'\n'* ]]; then
            missing_required=true
            break
        fi
    done
    if [[ "$missing_required" == "true" ]]; then
        printf "  %b✘ Save file is incomplete or corrupted.%b\n" "${COLOR_ERROR:-}" "${RESET:-}" >&2
        return 1
    fi

    # Odtwarzanie ekwipunku ze starego formatu (legacy).
    # Uwaga: historycznie format tracił informacje o spacjach, więc odzyskujemy
    # dane "best effort", a następnie zapisujemy już w formacie V2.
    if [[ "$found_new_inventory_format" == "false" && "$legacy_detected" == "true" ]]; then
        if [[ -n "$legacy_inventory_value" ]]; then
            read -r -a PLAYER_INVENTORY <<< "$legacy_inventory_value"
        else
            PLAYER_INVENTORY=()
        fi
        migration_needed=true
    fi

    # Sanitization: uzupełniamy luki po indeksach, jeśli plik był edytowany ręcznie.
    if [[ "$found_new_inventory_format" == "true" && -n "$inventory_count" ]]; then
        local normalized=()
        local i
        for (( i=0; i<inventory_count; i++ )); do
            if [[ -n "${PLAYER_INVENTORY[$i]:-}" ]]; then
                normalized+=("${PLAYER_INVENTORY[$i]}")
            fi
        done
        PLAYER_INVENTORY=("${normalized[@]}")
    fi

    # Automatyczna migracja:
    # jeżeli wykryto stary format, zapisujemy od razu w nowym i jednoznacznym.
    if [[ "$migration_needed" == "true" ]]; then
        save_game
    fi

    return 0
}

has_save() {
    [[ -f "$SAVE_FILE" ]]
}

delete_save() {
    rm -f "$SAVE_FILE"
    printf "  %b✔ Save deleted.%b\n" "${COLOR_SUCCESS:-}" "${RESET:-}"
}
