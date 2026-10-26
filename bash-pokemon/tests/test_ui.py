#!/usr/bin/env python3
"""Check terminal layout and state isolation without a terminal dependency."""
from pathlib import Path
import os
import re
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]
ENTRY = Path(os.environ.get('BASH_POKEMON_TEST_ENTRY', ROOT / 'bash_pokemon.sh'))
ANSI = re.compile(r'\x1b\[[0-9;]*[A-Za-z]')


def render(command, columns=80, mode='plain', extra_env=None):
    env = dict(os.environ, COLUMNS=str(columns), LANG='C.UTF-8')
    env.pop('NO_COLOR', None)
    env.update(extra_env or {})
    script = '''set -euo pipefail
source "$1"
new_game 1
ui_style=$2
ui_color_mode=always
ui_init
''' + command
    return subprocess.run(['bash', '-c', script, 'ui-test', str(ENTRY), mode],
                          env=env, text=True, capture_output=True, check=True, timeout=5).stdout


class PresentationTest(unittest.TestCase):
    def test_panels_fit_columns(self):
        for cols in (24, 32, 40, 60, 80, 120):
            for mode in ('plain', 'retro'):
                with self.subTest(columns=cols, mode=mode):
                    text = render('''party_lv[0]=100; party_hp[0]=320
render
ui_battle 25 100 320 320 wild 'Próba polskich znaków: żółć i obrażenia'
ui_party
ui_dialog 'Próba dialogu' 'Ten długi dialog zawiera polskie znaki i ma zachować równe krawędzie podczas zawijania słów.'
''', cols, mode)
                    width = max(23, min(max(cols, 24)-2, 70))
                    lines = ANSI.sub('', text).splitlines()
                    self.assertTrue(lines)
                    self.assertTrue(all(len(line) == width for line in lines),
                                    [(len(line), line) for line in lines if len(line) != width])

    def test_standard_screen_height(self):
        self.assertLessEqual(len(render('render').splitlines()), 23)
        self.assertLessEqual(len(render("ui_battle 25 12 35 56 wild 'Atak: 12 obrażeń'").splitlines()), 23)
        self.assertLessEqual(len(render('for id in 4 7 10 13 16; do add_pokemon "$id" 5 >/dev/null; done; ui_party').splitlines()), 23)

    def test_no_color_and_plain_output(self):
        for env in ({'NO_COLOR': '1'}, {}):
            with self.subTest(env=env):
                text = render('render; ui_battle 25 12 35 56 wild test', mode='plain', extra_env=env)
                self.assertNotIn('\x1b', text)
        text = render('render', mode='retro', extra_env={'NO_COLOR': '1'})
        self.assertNotIn('\x1b', text)
        text = render('ui_color_mode=auto; ui_init; render', mode='retro')
        self.assertNotIn('\x1b', text)

    def test_color_and_ascii_modes(self):
        text = render('render; ui_battle 25 12 35 56 wild test', mode='retro')
        self.assertIn('\x1b[', text)
        self.assertIn('┌', text)
        self.assertIn('█', text)
        text = render('ui_ascii=1; ui_init; render', mode='retro')
        self.assertNotIn('┌', text)
        self.assertIn('+', text)

    def test_rendering_preserves_state_and_rng(self):
        text = render('''before=$(declare -p area x y gold balls potions badges champion active starter party_id party_lv party_xp party_hp flags owned)
RANDOM=12345
expected=$RANDOM
RANDOM=12345
render >/dev/null
ui_battle 25 12 35 56 wild test >/dev/null
ui_party >/dev/null
actual=$RANDOM
after=$(declare -p area x y gold balls potions badges champion active starter party_id party_lv party_xp party_hp flags owned)
[[ $before == "$after" && $expected == "$actual" ]]
printf 'unchanged'
''')
        self.assertEqual(text, 'unchanged')

    def test_silhouettes_and_hp_boundaries(self):
        render('''for ((id=1;id<=151;id++)); do
ui_sprite "$id"
[[ ${#SPRITE[@]} == 8 ]]
for row in "${SPRITE[@]}"; do [[ ${#row} == 12 && $row != *[!0-4]* ]]; done
done
for hp in 0 1 20 50 100; do ui_hp "$hp" 100 >/dev/null; done
''')


if __name__ == '__main__':
    unittest.main()
