#!/usr/bin/env bash
# tests/test_combat.sh – Unit tests for combat helper logic
# (Tests the non-interactive parts: enemy_set, damage calculations, etc.)

GAME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${GAME_DIR}/lib/colors.sh"
source "${GAME_DIR}/lib/ui.sh"
source "${GAME_DIR}/lib/player.sh"
source "${GAME_DIR}/lib/challenges.sh"
source "${GAME_DIR}/lib/combat.sh"

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

echo
echo "  === Combat Tests ==="

# ── enemy_set ─────────────────────────────────────────────────────
enemy_set "Test Slime" 50 8 "navigation" "A test enemy." "Defeated!" 30 10 "Mikstura zdrowia"
assert_eq "enemy name"        "Test Slime"   "$ENEMY_NAME"
assert_eq "enemy HP"          "50"           "$ENEMY_HP"
assert_eq "enemy max HP"      "50"           "$ENEMY_MAX_HP"
assert_eq "enemy attack"      "8"            "$ENEMY_ATTACK"
assert_eq "enemy category"    "navigation"   "$ENEMY_CATEGORY"
assert_eq "enemy XP reward"   "30"           "$ENEMY_XP_REWARD"
assert_eq "enemy gold reward" "10"           "$ENEMY_GOLD_REWARD"
assert_eq "nagroda przedmiotu wroga" "Mikstura zdrowia" "$ENEMY_ITEM_REWARD"

# ── enemy_set without item reward ─────────────────────────────────
enemy_set "No-loot Ghost" 20 5 "files" "Description." "Victory!" 15 5
assert_eq "no item reward defaults empty" "" "$ENEMY_ITEM_REWARD"

# ── player damage and defense interaction in combat context ────────
player_create "CombatHero"
assert_eq "full HP before fight" "100" "$PLAYER_HP"

# Simulate receiving enemy damage
ENEMY_ATTACK=15
combat_enemy_attack > /dev/null
# Effective damage = 15 + (0..4) random - 5 defense = 10..14
assert_true "HP reduced after enemy attack" '[[ $PLAYER_HP -lt 100 ]]'
assert_true "HP still positive after one hit" '[[ $PLAYER_HP -gt 0 ]]'

# ── shield absorbs enemy damage in combat ───────────────────────────
player_create "ShieldHero"
PLAYER_SHIELD_VALUE=100
ENEMY_ATTACK=4
combat_enemy_attack > /dev/null
assert_eq "tarcza blokuje cały cios" "100" "$PLAYER_HP"
assert_true "wartość tarczy spada po absorpcji" '[[ $PLAYER_SHIELD_VALUE -lt 100 ]]'

# ── start-turn bleed tick on enemy ──────────────────────────────────
enemy_set "Bleeding Dummy" 40 0 "navigation" "dummy" "ok" 0 0
ENEMY_STATUS_BLEED_TURNS=2
ENEMY_STATUS_BLEED_DAMAGE=7
combat_start_turn_phase "enemy" > /dev/null
assert_eq "bleed odejmuje HP wroga" "33" "$ENEMY_HP"
assert_eq "bleed redukuje licznik tur" "1" "$ENEMY_STATUS_BLEED_TURNS"

# ── combat_victory awards XP and Gold ─────────────────────────────
player_create "RewardHero"
enemy_set "Reward Dummy" 0 0 "navigation" "" "You win!" 50 25 "Mikstura zdrowia"
ENEMY_HP=0
combat_victory > /dev/null
assert_eq "XP awarded after victory" "50" "$PLAYER_XP"
assert_eq "Gold awarded after victory" "25" "$PLAYER_GOLD"
assert_true "przedmiot po zwycięstwie" 'player_has_item "Mikstura zdrowia"'

# ── victory with no item reward ────────────────────────────────────
player_create "NoItemHero"
enemy_set "Skinflint" 0 0 "files" "" "Won!" 20 5
ENEMY_HP=0
combat_victory > /dev/null
assert_eq "brak przedmiotu gdy nagroda pusta" "0" "${#PLAYER_INVENTORY[@]}"

# ── player death during combat ─────────────────────────────────────
player_create "MortalHero"
PLAYER_HP=1
player_damage 100 > /dev/null   # way more than defense can block
assert_true "player is dead after fatal damage" 'player_is_dead'

echo
echo "  Combat Tests: ${PASS} passed, ${FAIL} failed"
[[ $FAIL -eq 0 ]]
