# AGENTS.md

## GitHub Actions: reguły dla agentów AI

- **Manual-first:** wywołuj `workflow_dispatch` wyłącznie z `main`. Nie uruchamiaj CI w GitHub Actions dla gałęzi roboczych ani dla PR; testuj lokalnie.
- Każdy job wymaga `github.ref == 'refs/heads/main'`; nie zmieniaj na `push` na innych gałęziach ani tagach, `pull_request`, `workflow_run` czy `repository_dispatch`.
- Wyjątek automatyczny dopiero po ocenie budżetu: `push` wyłącznie `branches: [main]` z filtrem `paths` i uzasadnieniem; nie testuj sprzętu badawczego na ślepo.
- W formularzu Run workflow zawsze wybieraj `main` (stare definicje na innych gałęziach mogą nie być zabezpieczone).

## GitHub Actions execution policy (mandatory for AI agents)

- Manual workflow execution via `workflow_dispatch` is the default. Do not add automated heavyweight builds, tests, packaging or publication.
- Automatic runs, when explicitly justified, may happen only on `push` to `main` with restricted `paths`. No `pull_request`, `pull_request_target`, `merge_group`, or non-main push triggers.
- Every GitHub Actions job must check `github.ref == 'refs/heads/main'` and preserve current opt-in inputs, permissions and disabled gates.
- Agents must test locally on branches, never dispatch Actions on non-main branches, and record exceptions and actual validation results. Required PR checks may need branch protection changes.
