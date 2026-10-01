# bash-sim

Zbiór małych projektów dydaktycznych i eksperymentalnych związanych z terminalem, Bashem i prostymi symulacjami.

| Projekt | Technologia | Cel |
| --- | --- | --- |
| `bash-life` | Bash + HTML | Gra w życie Conwaya w terminalu i przeglądarce |
| `bash-rpg` | Bash | Gra RPG ucząca poleceń Bash |
| `bash-tui` | Bash | Interaktywny monitor informacji systemowych |
| `bash-civ` | Python + HTML | Eksperymentalna symulacja rozwoju cywilizacji |
| `ndplab` | Bash | Materiały i interaktywne ćwiczenia NDP |

## Szybki start

Przykładowo:

```bash
git clone https://github.com/MatPomGit/bash-sim.git
cd bash-sim
./bash-life/bash_life.sh
```

Każdy większy podprojekt ma własny plik README z instrukcją uruchomienia.

## bash-rpg

Kopia `bash-rpg/` znajduje się w tym repozytorium ze względów historycznych. Główną, kanoniczną wersją gry jest osobne repozytorium:

https://github.com/MatPomGit/bash-rpg

Nowe zmiany w grze powinny być rozwijane przede wszystkim tam, aby uniknąć rozjeżdżania się dwóch kopii.

## Kontrola jakości

Workflow CI sprawdza składnię skryptów Bash i kompilowalność modułów Python bez ich uruchamiania.
