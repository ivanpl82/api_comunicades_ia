# Tasks: api-comunidades-ai — Skills de comunidades autónomas

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~2000-2500 |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Suggested split | PR 1 (base+CKAN) → PR 2 (standalone) → PR 3 (stubs+installer) → PR 4 (polish) |
| Delivery strategy | auto-chain |
| Chain strategy | stacked-to-main |

Decision needed before apply: No
Chained PRs recommended: Yes
Chain strategy: stacked-to-main
400-line budget risk: High

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | CKAN base template + Andalucía migration + 6 CKAN skills | PR 1 | base → main; ~450 lines |
| 2 | Standalone skills: Euskadi, Cataluña, Canarias, CyL, Baleares | PR 2 | base → main; ~500 lines |
| 3 | 7 stubs + installer script | PR 3 | base → main; ~430 lines |
| 4 | Registry update + README + final verification | PR 4 | base → main; ~50 lines |

## Phase 1: Fundación — Plantilla CKAN base

- [x] 1.1 Crear `skills/skill-ckan-base.md` con frontmatter YAML + secciones CKAN estándar (endpoints, params, rate limiting, paginación)
- [x] 1.2 Incluir `api_path` configurable (default `/api/3/action`; Aragón `/ckan/api/3/action`)
- [x] 1.3 Incluir comandos `dataset list/get`, `org list/get`, `group list/get`, `search`
- [x] 1.4 Incluir ejemplos Python y formato de respuesta CKAN estándar

## Phase 2: Skills CKAN por comunidad

- [x] 2.1 Migrar `skills/skill-junta-andalucia.md` → actualizarla para que referencie la base y use la convención de api_path
- [x] 2.2 Crear `skills/skill-ckan-aragon.md` con `api_path: /ckan/api/3/action` (camino no estándar)
- [x] 2.3 Crear `skills/skill-ckan-castillalamancha.md`
- [x] 2.4 Crear `skills/skill-ckan-madrid.md`
- [x] 2.5 Crear `skills/skill-ckan-murcia.md`
- [x] 2.6 Crear `skills/skill-ckan-navarra.md`
- [x] 2.7 Crear `skills/skill-ckan-valencia.md`

## Phase 3: Skills standalone (no-CKAN)

- [x] 3.1 Crear `skills/skill-euskadi.md` — SPARQL endpoint + REST API normalizada
- [x] 3.2 Crear `skills/skill-cataluna.md` — Socrata API (`analisi.transparenciacatalunya.cat`)
- [x] 3.3 Crear `skills/skill-canarias.md` — plataforma custom
- [x] 3.4 Crear `skills/skill-castillayleon.md` — plataforma custom
- [x] 3.5 Crear `skills/skill-baleares.md` — pendiente de investigar API

## Phase 4: Stubs informativos

- [x] 4.1 Crear stubs para errores de transporte: Asturias, Cantabria, Extremadura, Galicia, La Rioja
- [x] 4.2 Crear stubs para sin portal: Ceuta, Melilla
- [x] 4.3 Cada stub incluye estado, URL investigada, fecha de verificación, sin llamadas HTTP

## Phase 5: Instalador + documentación

- [x] 5.1 Crear `scripts/install-comunidades-ai.sh` con `detect_os()`, `--dry-run`, `--force`, `--verbose`, `--check`
- [x] 5.2 Usar `$HOME/.config/opencode/skills/` sin rutas absolutas sensibles
- [x] 5.3 `--check` solo verifica cuando se pasa, no por defecto; WSL tratado como Linux
- [x] 5.4 Actualizar `.atl/skill-registry.md` con todas las skills nuevas
- [x] 5.5 Actualizar `README.md` con cobertura real (de solo Andalucía a todas las CCAA)

## Phase 6: Verificación

- [x] 6.1 Validar frontmatter YAML de cada skill con `python3 -c "import yaml; yaml.safe_load(open(...))"`
- [x] 6.2 Probar instalador con cada flag: `--dry-run`, `--force`, `--verbose`, `--check`
- [x] 6.3 Verificar que ningún stub hace llamadas HTTP reales