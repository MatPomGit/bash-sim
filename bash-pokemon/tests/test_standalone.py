#!/usr/bin/env python3
"""Verify the generated game works with no adjacent game files."""
from pathlib import Path
import os
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def main() -> int:
    subprocess.run(["python3", str(ROOT / "tools/build_standalone.py"), "--check"], check=True)
    with tempfile.TemporaryDirectory(prefix="pokemon standalone ") as directory:
        work = Path(directory)
        game = work / "pokemon-red.sh"
        shutil.copy2(ROOT / game.name, game)
        subprocess.run(["bash", "-n", str(game)], check=True, cwd=work)
        env = dict(os.environ, BASH_POKEMON_TEST_ENTRY=str(game), XDG_DATA_HOME=str(work / "saves"))
        subprocess.run(["bash", str(ROOT / "tests/run_tests.sh")], check=True, cwd=work, env=env)
        # Run actual interactive input through the isolated file, then resume it.
        save = work / "saved game.dat"
        commands = "1\ne\n1\nt\n" + "1\n" * 12 + "q\n"
        first = subprocess.run(
            ["bash", str(game), "--new", "--save", str(save)],
            input=commands, text=True, capture_output=True, cwd=work, env=env, check=True, timeout=5,
        )
        assert "F|lab\n" in save.read_text(encoding="utf-8"), first.stderr
        second = subprocess.run(
            ["bash", str(game), "--load", "--save", str(save)],
            input="q\n", text=True, capture_output=True, cwd=work, env=env, check=True, timeout=5,
        )
        assert "Wczytano" in second.stdout, second.stderr
        assert not (work / "lib").exists() and not (work / "data").exists()
    print("Single-file isolation, real tutorial and resume: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
