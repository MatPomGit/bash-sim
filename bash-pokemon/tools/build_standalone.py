#!/usr/bin/env python3
"""Build one reproducible Bash script with embedded modules and data."""
from pathlib import Path
import argparse
import re

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "pokemon-red.sh"


def embed_data(source: str, name: str) -> str:
    marker = "POKEBASH_" + re.sub(r"[^A-Z0-9]", "_", name.upper())
    data = (ROOT / "data" / name).read_text(encoding="utf-8")
    if marker in data.splitlines():
        raise ValueError(f"Here-document delimiter appears in {name}")
    target = f'< "$GAME_ROOT/data/{name}"'
    if source.count(target) != 1:
        raise ValueError(f"Expected exactly one data include for {name}")
    return source.replace(target, f"<<'{marker}'\n{data.rstrip(chr(10))}\n{marker}")


def build() -> str:
    source = (ROOT / "bash_pokemon.sh").read_text(encoding="utf-8")
    root_line = 'GAME_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)\n'
    if source.count(root_line) != 1:
        raise ValueError("Cannot identify the modular entry point")
    source = source.replace(root_line, "")
    source = embed_data(source, "species.tsv")
    for name in ("world", "story", "collection", "ui", "save"):
        target = f'source "$GAME_ROOT/lib/{name}.sh"'
        if source.count(target) != 1:
            raise ValueError(f"Expected exactly one module include for {name}")
        module = (ROOT / "lib" / f"{name}.sh").read_text(encoding="utf-8")
        if name == "save":
            module = embed_data(module, "legacy_ids.tsv")
        source = source.replace(target, f"# Embedded module: {name}\n{module.rstrip()}\n# End module: {name}")
    if "GAME_ROOT" in source or re.search(r"^source\s", source, re.MULTILINE):
        raise ValueError("Unresolved external game resource")
    banner = "# Single-file distribution. Rebuild with tools/build_standalone.py.\n"
    return source.replace("#!/usr/bin/env bash\n", "#!/usr/bin/env bash\n" + banner, 1)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Fail if the committed bundle is stale")
    args = parser.parse_args()
    content = build()
    if args.check:
        if not OUTPUT.is_file() or OUTPUT.read_text(encoding="utf-8") != content:
            print("Standalone bundle is stale. Run python3 bash-pokemon/tools/build_standalone.py")
            return 1
        print("Standalone bundle: up to date")
    else:
        OUTPUT.write_text(content, encoding="utf-8", newline="\n")
        OUTPUT.chmod(0o755)
        print(f"Built {OUTPUT.name} ({OUTPUT.stat().st_size} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
