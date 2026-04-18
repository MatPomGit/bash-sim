#!/usr/bin/env bash
# lib/shop.sh – Moduł sklepu między poziomami

# shellcheck source=lib/ui.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/ui.sh"
source "${SCRIPT_DIR}/player.sh"

# Definicja asortymentu sklepu.
# Każda pozycja ma: nazwę, cenę bazową i opis działania.
SHOP_ITEM_NAMES=(
    "Mikstura zdrowia"
    "Mikstura many"
    "Mikstura wiedzy"
    "Tarcza tymczasowa"
    "Oczyszczenie"
)
SHOP_ITEM_BASE_PRICES=(35 40 65 70 60)
SHOP_ITEM_DESCRIPTIONS=(
    "+50 PŻ"
    "+1 ładunek podpowiedzi"
    "+2 ładunki podpowiedzi"
    "+40 tarczy bojowej"
    "Usuwa negatywne efekty"
)

# Oblicza współczynnik cen na podstawie aktualnego poziomu rozdziału.
# Dzięki temu przedmioty nie stają się zbyt tanie w późniejszej fazie gry.
shop_price_multiplier_percent() {
    local level="${CURRENT_LEVEL:-1}"
    [[ "$level" -lt 1 ]] && level=1
    printf "%d" $(( 100 + (level - 1) * 18 ))
}

# Zwraca skalowaną cenę dla indeksu przedmiotu.
shop_get_price() {
    local idx="$1"
    local base_price="${SHOP_ITEM_BASE_PRICES[$idx]}"
    local multiplier
    multiplier="$(shop_price_multiplier_percent)"
    printf "%d" $(( (base_price * multiplier + 99) / 100 ))
}

# Wyświetla pełną ofertę sklepu z aktualnymi cenami i opisami.
shop_show_offer() {
    local multiplier
    multiplier="$(shop_price_multiplier_percent)"

    echo
    printf "  %b=== Sklep Podróżnika ===%b\n" "${BOLD_WHITE}" "${RESET}"
    printf "  %bPoziom obszaru:%b %d   %bMnożnik cen:%b %d%%\n" \
        "${DIM}" "${RESET}" "${CURRENT_LEVEL:-1}" "${DIM}" "${RESET}" "$multiplier"
    printf "  %bTwoje złoto:%b %b%d Zł%b\n\n" "${DIM}" "${RESET}" "${COLOR_GOLD}" "$PLAYER_GOLD" "${RESET}"

    local idx
    for idx in "${!SHOP_ITEM_NAMES[@]}"; do
        local scaled_price
        scaled_price="$(shop_get_price "$idx")"
        printf "  %b[%d]%b %-20s %b%3d Zł%b  %b%s%b\n" \
            "${BOLD_CYAN}" "$(( idx + 1 ))" "${RESET}" \
            "${SHOP_ITEM_NAMES[$idx]}" "${COLOR_GOLD}" "$scaled_price" "${RESET}" \
            "${DIM}" "${SHOP_ITEM_DESCRIPTIONS[$idx]}" "${RESET}"
    done
    printf "  %b[Q]%b Wyjście ze sklepu\n" "${BOLD_CYAN}" "${RESET}"
    echo
}

# Dodaje kupiony przedmiot do ekwipunku gracza.
shop_add_item_to_inventory() {
    local item_name="$1"
    player_add_item "$item_name"
}

# Obsługuje próbę zakupu: waliduje wybór, złoto i aktualizuje stan gracza.
shop_buy_item() {
    local selected_index="$1"

    if [[ -z "$selected_index" || ! "$selected_index" =~ ^[0-9]+$ ]]; then
        ui_error "Podaj numer przedmiotu z listy."
        return 1
    fi

    if [[ "$selected_index" -lt 1 || "$selected_index" -gt "${#SHOP_ITEM_NAMES[@]}" ]]; then
        ui_error "Nie ma przedmiotu o takim numerze."
        return 1
    fi

    local idx=$(( selected_index - 1 ))
    local item_name="${SHOP_ITEM_NAMES[$idx]}"
    local item_price
    item_price="$(shop_get_price "$idx")"

    if [[ "$PLAYER_GOLD" -lt "$item_price" ]]; then
        ui_warning "Masz za mało złota na: ${item_name}."
        return 1
    fi

    PLAYER_GOLD=$(( PLAYER_GOLD - item_price ))
    shop_add_item_to_inventory "$item_name"
    ui_success "Kupiono: ${item_name} za ${item_price} Zł."
    return 0
}

# Pętla sklepu uruchamiana między poziomami po pokazaniu statusu gracza.
shop_level_checkpoint() {
    [[ "${BASH_RPG_TESTING:-}" == "1" ]] && return 0

    echo
    ui_prompt "Czy chcesz wejść do sklepu? [t/N]: "
    local answer
    read -r answer

    case "${answer,,}" in
        t|tak|y|yes)
            while true; do
                ui_clear
                shop_show_offer
                ui_prompt "Wybierz przedmiot do kupna (lub Q): "
                local choice
                read -r choice

                case "${choice,,}" in
                    q|wyjdz|wyjdź|exit)
                        ui_info "Opuszczasz sklep i ruszasz dalej."
                        return 0
                        ;;
                    *)
                        shop_buy_item "$choice"
                        press_enter
                        ;;
                esac
            done
            ;;
        *)
            return 0
            ;;
    esac
}
