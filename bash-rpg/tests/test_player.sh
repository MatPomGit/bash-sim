#!/usr/bin/env bash
# tests/test_player.sh – Unit tests for lib/player.sh

GAME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${GAME_DIR}/lib/colors.sh"
source "${GAME_DIR}/lib/ui.sh"
source "${GAME_DIR}/lib/player.sh"
source "${GAME_DIR}/lib/save_load.sh"

PASS=0
FAIL=0

assert_eq() {
    local desc="$1" expected="$2" actual="$3"
    if [[ "$expected" == "$actual" ]]; then
        printf "    %b✔%b %s\n" "${GREEN:-}" "${RESET:-}" "$desc"
        (( PASS++ ))
    else
        printf "    %b✘%b %s  (expected '%s', got '%s')\n" \
            "${RED:-}" "${RESET:-}" "$desc" "$expected" "$actual"
        (( FAIL++ ))
    fi
}

assert_true() {
    local desc="$1"
    if eval "$2"; then
        printf "    %b✔%b %s\n" "${GREEN:-}" "${RESET:-}" "$desc"
        (( PASS++ ))
    else
        printf "    %b✘%b %s\n" "${RED:-}" "${RESET:-}" "$desc"
        (( FAIL++ ))
    fi
}

assert_file_contains() {
    local desc="$1" file="$2" pattern="$3"
    if rg -q "$pattern" "$file"; then
        printf "    %b✔%b %s\n" "${GREEN:-}" "${RESET:-}" "$desc"
        (( PASS++ ))
    else
        printf "    %b✘%b %s  (pattern '%s' not found in '%s')\n" \
            "${RED:-}" "${RESET:-}" "$desc" "$pattern" "$file"
        (( FAIL++ ))
    fi
}

echo
echo "  === Player Tests ==="

# ── player_create ──────────────────────────────────────────────────
player_create "TestHero"
assert_eq "player_create sets name"    "TestHero" "$PLAYER_NAME"
assert_eq "player_create sets level"   "1"        "$PLAYER_LEVEL"
assert_eq "player_create sets XP"      "0"        "$PLAYER_XP"
assert_eq "player_create sets HP"      "100"      "$PLAYER_HP"
assert_eq "player_create sets MaxHP"   "100"      "$PLAYER_MAX_HP"
assert_eq "player_create sets Gold"    "0"        "$PLAYER_GOLD"
assert_eq "player_create sets Attack"  "10"       "$PLAYER_ATTACK"
assert_eq "player_create sets Defense" "5"        "$PLAYER_DEFENSE"

# ── player_add_xp (no level up yet) ───────────────────────────────
player_create "TestHero"
player_add_xp 50 > /dev/null
assert_eq "add_xp accumulates"   "50"  "$PLAYER_XP"
assert_eq "no level-up yet"       "1"   "$PLAYER_LEVEL"

# ── player_level_up via add_xp ─────────────────────────────────────
player_create "TestHero"
player_add_xp 260 > /dev/null   # Should reach level 2 (XP_NEXT=250)
assert_eq "level-up increments level" "2" "$PLAYER_LEVEL"
assert_true "HP fully healed on level-up" '[[ $PLAYER_HP -eq $PLAYER_MAX_HP ]]'
assert_true "attack increased" '[[ $PLAYER_ATTACK -gt 10 ]]'

# ── player_heal ────────────────────────────────────────────────────
player_create "TestHero"
player_damage 30 > /dev/null
player_heal 20 > /dev/null
assert_eq "heal restores HP" "95" "$PLAYER_HP"  # 100 - (30-5 defense) + 20 = 95

player_create "TestHero"
player_heal 200 > /dev/null
assert_eq "heal caps at max HP" "100" "$PLAYER_HP"

# ── player_damage ──────────────────────────────────────────────────
player_create "TestHero"
player_damage 20 > /dev/null   # effective = 20 - 5 (defense) = 15
assert_eq "damage reduced by defense" "85" "$PLAYER_HP"

player_create "TestHero"
player_damage 3 > /dev/null    # 3 - 5 = -2, capped to 1
assert_eq "minimum 1 damage" "99" "$PLAYER_HP"

# ── player_is_dead ─────────────────────────────────────────────────
player_create "TestHero"
assert_true "alive when HP>0" '! player_is_dead'
PLAYER_HP=0
assert_true "dead when HP=0" 'player_is_dead'
PLAYER_HP=-5
assert_true "dead when HP<0" 'player_is_dead'

# ── inventory ──────────────────────────────────────────────────────
player_create "TestHero"
player_add_item "Mikstura zdrowia" > /dev/null
player_add_item "Mikstura zdrowia" > /dev/null
player_add_item "Eliksir wiedzy" > /dev/null
assert_true "ma Miksturę Zdrowia"       'player_has_item "Mikstura zdrowia"'
assert_true "ma Eliksir Wiedzy" 'player_has_item "Eliksir wiedzy"'
assert_true "nie ma Miecza"                '! player_has_item "Miecz"'
assert_eq "ekwipunek ma 3 przedmioty" "3" "${#PLAYER_INVENTORY[@]}"

player_remove_item "Mikstura zdrowia" > /dev/null
assert_eq "usuń jedną miksturę, pozostają 2" "2" "${#PLAYER_INVENTORY[@]}"
assert_true "nadal ma jedną miksturę" 'player_has_item "Mikstura zdrowia"'

# ── player_use_item (Health Potion) ────────────────────────────────
player_create "TestHero"
PLAYER_HP=50
player_add_item "Mikstura zdrowia" > /dev/null
player_use_item "Mikstura zdrowia" > /dev/null
assert_eq "mikstura leczy 50 PŻ" "100" "$PLAYER_HP"
assert_true "mikstura zużyta z ekwipunku" '! player_has_item "Mikstura zdrowia"'

# ── player_use_item (Runa tarczy) ───────────────────────────────────
player_create "TestHero"
PLAYER_SHIELD_VALUE=0
player_add_item "Runa tarczy" > /dev/null
player_use_item "Runa tarczy" > /dev/null
assert_eq "runa dodaje tarczę" "25" "$PLAYER_SHIELD_VALUE"
assert_true "runa zużyta z ekwipunku" '! player_has_item "Runa tarczy"'

# ── player_use_item (Bombka krwawienia) ─────────────────────────────
player_create "TestHero"
ENEMY_STATUS_BLEED_TURNS=0
ENEMY_STATUS_BLEED_DAMAGE=0
player_add_item "Bombka krwawienia" > /dev/null
player_use_item "Bombka krwawienia" > /dev/null
assert_eq "bombka ustawia czas bleed" "3" "$ENEMY_STATUS_BLEED_TURNS"
assert_eq "bombka ustawia obrażenia bleed" "8" "$ENEMY_STATUS_BLEED_DAMAGE"
assert_true "bombka zużyta z ekwipunku" '! player_has_item "Bombka krwawienia"'

# ── save/load inventory format + migration + integrity ───────────────
TEST_SAVE_DIR="$(mktemp -d)"
SAVE_DIR="$TEST_SAVE_DIR"
SAVE_FILE="${SAVE_DIR}/save.dat"

player_create "SaverHero"
PLAYER_INVENTORY=(
    "Mikstura zdrowia"
    "Zwój teleportacji"
    "Klucz=Sekretny #1"
)
save_game > /dev/null

PLAYER_INVENTORY=()
load_game > /dev/null
assert_eq "save/load zachowuje liczbę przedmiotów" "3" "${#PLAYER_INVENTORY[@]}"
assert_eq "save/load zachowuje item ze spacją (1)" "Mikstura zdrowia" "${PLAYER_INVENTORY[0]}"
assert_eq "save/load zachowuje item ze spacją (2)" "Zwój teleportacji" "${PLAYER_INVENTORY[1]}"
assert_eq "save/load zachowuje znaki specjalne" "Klucz=Sekretny #1" "${PLAYER_INVENTORY[2]}"
assert_file_contains "nowy format zapisuje elementy jako Base64" "$SAVE_FILE" '^PLAYER_INVENTORY_ITEM_0_B64='

# Test migracji starego formatu: jedna linia PLAYER_INVENTORY=...
cat > "$SAVE_FILE" <<'EOF'
PLAYER_NAME=LegacyHero
PLAYER_LEVEL=1
PLAYER_XP=0
PLAYER_XP_NEXT=250
PLAYER_HP=100
PLAYER_MAX_HP=100
PLAYER_GOLD=0
PLAYER_ATTACK=10
PLAYER_DEFENSE=5
PLAYER_TALENT_POINTS=0
TALENT_OFFENSE_LEVEL=0
TALENT_DEFENSE_LEVEL=0
TALENT_KNOWLEDGE_LEVEL=0
TALENT_KNOWLEDGE_HINTS=0
CURRENT_LEVEL=1
PLAYER_INVENTORY=Potion Sword
EOF

load_game > /dev/null
assert_eq "legacy: odczyt itemu 1 po migracji" "Potion" "${PLAYER_INVENTORY[0]}"
assert_eq "legacy: odczyt itemu 2 po migracji" "Sword" "${PLAYER_INVENTORY[1]}"
assert_file_contains "legacy: plik migrowany do nowego formatu" "$SAVE_FILE" '^PLAYER_INVENTORY_ITEM_1_B64='

# Test integralności: brak wymaganego klucza powinien zablokować odczyt.
cat > "$SAVE_FILE" <<'EOF'
PLAYER_NAME=BrokenHero
PLAYER_LEVEL=1
PLAYER_XP=0
PLAYER_XP_NEXT=250
PLAYER_MAX_HP=100
PLAYER_GOLD=0
PLAYER_ATTACK=10
PLAYER_DEFENSE=5
PLAYER_TALENT_POINTS=0
TALENT_OFFENSE_LEVEL=0
TALENT_DEFENSE_LEVEL=0
TALENT_KNOWLEDGE_LEVEL=0
TALENT_KNOWLEDGE_HINTS=0
CURRENT_LEVEL=1
PLAYER_INVENTORY_COUNT=0
EOF

if load_game > /dev/null 2>&1; then
    assert_true "integralność: uszkodzony plik powinien nie przejść" "false"
else
    assert_true "integralność: uszkodzony plik odrzucony" "true"
fi

rm -rf "$TEST_SAVE_DIR"

echo
echo "  Player Tests: ${PASS} passed, ${FAIL} failed"
[[ $FAIL -eq 0 ]]
