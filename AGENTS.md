# AGENTS.md

## GitHub Actions: reguły dla agentów AI

- **Manual-first:** wywołuj `workflow_dispatch` wyłącznie z `main`. Nie uruchamiaj CI w GitHub Actions dla gałęzi roboczych ani dla PR; testuj lokalnie.
- Każdy job wymaga `github.ref == 'refs/heads/main'`; nie zmieniaj na `push` na innych gałęziach ani tagach, `pull_request`, `workflow_run` czy `repository_dispatch`.
- Wyjątek automatyczny dopiero po ocenie budżetu: `push` wyłącznie `branches: [main]` z filtrem `paths` i uzasadnieniem; nie testuj sprzętu badawczego na ślepo.
- W formularzu Run workflow zawsze wybieraj `main` (stare definicje na innych gałęziach mogą nie być zabezpieczone).
