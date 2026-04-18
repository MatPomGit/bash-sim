#!/usr/bin/env bash
# tests/run_tests.sh – Minimal test runner
# Usage: bash tests/run_tests.sh

GAME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TESTS_DIR="${GAME_DIR}/tests"

PASS=0
FAIL=0
ERRORS=()

run_suite() {
    local suite="$1"
    echo "  Running: $suite"
    if BASH_RPG_TESTING=1 bash "${TESTS_DIR}/${suite}" 2>&1; then
        (( PASS++ ))
    else
        (( FAIL++ ))
        ERRORS+=("$suite")
    fi
}

echo
echo "========================================"
echo "  Bash RPG – Test Suite"
echo "========================================"
echo

run_suite "test_player.sh"
run_suite "test_combat.sh"
run_suite "test_challenges.sh"

echo
echo "========================================"
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo "========================================"
if [[ ${#ERRORS[@]} -gt 0 ]]; then
    echo "  FAILED:"
    for e in "${ERRORS[@]}"; do
        echo "    - $e"
    done
    exit 1
fi
echo
