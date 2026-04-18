# Bash RPG: The Terminal Chronicles

> An interactive terminal RPG game that teaches you Bash console commands through combat, exploration, and adventure.

## Overview

You are the **Bash Warrior** – destined to save the Kingdom of Terminal from creatures of chaos and confusion. Traverse five distinct regions, each guarded by monsters that test your knowledge of real Bash commands. Defeat them by answering correctly, level up your hero, and restore order to the terminal world!

## Features

- 🗡️ **Turn-based combat** – answer Bash command questions to attack enemies
- 📈 **RPG progression** – XP, levels, HP, attack/defense stats
- 🎒 **Inventory system** – collect potions and magical items
- 🛒 **Inter-level shop** – buy items between chapters, with prices scaled by current level
- 💾 **Auto-save** – progress saved to `~/.bash_rpg/save.dat` after each chapter
- 🎨 **Colorful terminal UI** – ANSI colors, ASCII art, status bars
- 📚 **50+ Bash challenges** across 5 categories

## Bash Commands Taught

| Chapter | Region                  | Commands                                      |
|---------|-------------------------|-----------------------------------------------|
| 1       | Forest of Navigation    | `ls`, `pwd`, `cd`, `mkdir`, `rmdir`           |
| 2       | Cave of Files           | `touch`, `cat`, `cp`, `mv`, `rm`, `ln`, `file` |
| 3       | Temple of Text          | `grep`, `find`, `head`, `tail`, `wc`, `sort`, `uniq`, `cut` |
| 4       | River of Pipes          | `\|`, `>`, `>>`, `<`, `2>`, `tee`, `xargs`   |
| 5       | Wizard's Tower          | variables, `if`, `for`, `while`, functions, `$?` |

## Requirements

- **Bash 4.0+** (macOS users: `brew install bash`)
- **Git** – to clone the repository
- A terminal with ANSI color support (any modern terminal)

## How to Run

Choose the section that matches your operating system and follow the steps in order.

---

### 🐧 Linux

Most Linux distributions ship with Bash 4+ and Git pre-installed.

1. **Open a terminal** (e.g. GNOME Terminal, Konsole, xterm).

2. **Install Git** if it is not already present:

   ```bash
   # Debian / Ubuntu / Mint
   sudo apt install git

   # Fedora / RHEL / CentOS
   sudo dnf install git

   # Arch / Manjaro
   sudo pacman -S git
   ```

3. **Clone the repository and start the game:**

   ```bash
   git clone https://github.com/MatPomGit/bash-rpg.git
   cd bash-rpg
   bash bash_rpg.sh
   ```

---

### 🍎 macOS

macOS ships with Bash **3.2**, which is too old. You need to install Bash 4+ via [Homebrew](https://brew.sh).

1. **Install Homebrew** (skip if already installed):

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Install Git and Bash 4+:**

   ```bash
   brew install git bash
   ```

3. **Clone the repository and start the game:**

   ```bash
   git clone https://github.com/MatPomGit/bash-rpg.git
   cd bash-rpg
   bash bash_rpg.sh
   ```

   > **Tip:** You can also double-click `start.command` in Finder. The first time, right-click → *Open* to bypass the Gatekeeper warning.

---

### 🪟 Windows

Windows does not include Bash natively. Choose **one** of the options below.

#### Option A – Git for Windows (recommended, easiest)

1. **Download and install** [Git for Windows](https://gitforwindows.org/).  
   During setup you can keep all default options.

2. **Open Git Bash** (search for "Git Bash" in the Start menu).

3. **Clone the repository and start the game:**

   ```bash
   git clone https://github.com/MatPomGit/bash-rpg.git
   cd bash-rpg
   bash bash_rpg.sh
   ```

   > **Tip:** You can also double-click `start.bat` in Explorer. It automatically finds Git Bash and launches the game.

#### Option B – WSL (Windows Subsystem for Linux)

1. **Enable WSL** (run in PowerShell as Administrator):

   ```powershell
   wsl --install
   ```

   Restart your computer when prompted.

2. **Open the WSL terminal** (e.g. "Ubuntu" from the Start menu).

3. **Clone the repository and start the game:**

   ```bash
   git clone https://github.com/MatPomGit/bash-rpg.git
   cd bash-rpg
   bash bash_rpg.sh
   ```

#### Option C – Cygwin

1. **Download and run** the [Cygwin installer](https://www.cygwin.com/).

2. During package selection, add **git** and **bash** (both are in the default selection).

3. **Open the Cygwin Terminal**, then clone and run:

   ```bash
   git clone https://github.com/MatPomGit/bash-rpg.git
   cd bash-rpg
   bash bash_rpg.sh
   ```

#### Option D – MSYS2

1. **Download and install** [MSYS2](https://www.msys2.org/).

2. **Open the MSYS2 MSYS terminal** and install Git:

   ```bash
   pacman -S git
   ```

3. **Clone the repository and start the game:**

   ```bash
   git clone https://github.com/MatPomGit/bash-rpg.git
   cd bash-rpg
   bash bash_rpg.sh
   ```

---

## Project Structure

```
bash_rpg.sh          ← main entry point
lib/
  colors.sh          ← ANSI color definitions
  ui.sh              ← UI helpers (headers, bars, dialogs)
  player.sh          ← player state management
  challenges.sh      ← Bash-command challenge database
  combat.sh          ← turn-based combat engine
  save_load.sh       ← save/load game state
  shop.sh            ← inter-level shop and dynamic pricing
levels/
  level_01.sh        ← Forest of Navigation
  level_02.sh        ← Cave of Files
  level_03.sh        ← Temple of Text
  level_04.sh        ← River of Pipes
  level_05.sh        ← Wizard's Tower
tests/
  run_tests.sh       ← test runner
  test_player.sh     ← player unit tests
  test_combat.sh     ← combat unit tests
  test_challenges.sh ← challenge database tests
```

## Running Tests

```bash
bash tests/run_tests.sh
```

## How to Play

1. **Start the game** and create your hero.
2. In each battle, choose **[1] Attack** to face a Bash challenge.
3. Type the correct Bash command or answer to deal damage.
4. Wrong answers miss your turn – the enemy still attacks!
5. Use **Health Potions** from your inventory to survive tough fights.
6. After each chapter, visit the **shop** to spend gold on useful consumables.
7. Shop prices scale with `CURRENT_LEVEL`, so your economy stays balanced throughout the campaign.
8. Your progress is **auto-saved** – you can quit and continue later.

### Shop Between Chapters

After completing a level, you can enter a shop before continuing.

- Items include healing, hint-restoring elixirs, temporary shields, and status-cleansing consumables.
- Prices are dynamically scaled with `CURRENT_LEVEL` (higher chapters = higher prices).
- Item names with spaces are fully supported in inventory and save files.

### Combat Tips

- Answers are **case-insensitive** – `ls`, `LS`, and `Ls` all work.
- You can type just the command name (e.g., `grep`) or the full usage.
- After each challenge, an **explanation** is shown – read it!
- If you die, you can restart from your last save with half HP.

## License

[MIT License](LICENSE)
