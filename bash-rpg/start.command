#!/usr/bin/env bash
# ============================================================
#  Bash RPG: Kroniki Terminala – uruchamiacz macOS
#  Kliknij dwukrotnie ten plik w Finderze, aby uruchomić grę.
#
#  Wymagania:
#    • Bash 4.0+  (macOS dostarcza /bin/sh z Bash 3.x;
#      zainstaluj nowszy przez Homebrew: brew install bash)
# ============================================================

cd "$(dirname "$0")"

BASH_BIN="$(command -v bash)"

# Preferuj Homebrew bash (4.x / 5.x) jeśli dostępny
for candidate in /opt/homebrew/bin/bash /usr/local/bin/bash "$BASH_BIN"; do
    if [[ -x "$candidate" ]]; then
        BASH_VERSION_OK=$("$candidate" -c 'echo ${BASH_VERSINFO[0]}' 2>/dev/null)
        if [[ "${BASH_VERSION_OK:-0}" -ge 4 ]]; then
            exec "$candidate" bash_rpg.sh
        fi
    fi
done

echo "Nie znaleziono Bash 4.0+."
echo "Zainstaluj przez Homebrew: brew install bash"
echo "Szczegóły: https://brew.sh"
read -r -p "Naciśnij Enter, aby zamknąć..."
