# Design: api-comunidades-ai — Skills de comunidades autónomas

## Enfoque técnico

Proyecto de skills OpenCode para cubrir los portales de datos abiertos de las 17 CCAA + Ceuta + Melilla.
**Tres grupos** según tecnología del portal: (a) CKAN v3 — plantilla compartida, (b) standalone — APIs propias (SPARQL, Socrata, custom), (c) stubs — sin portal detectable.

Estrategia **base+config**: un `skill-ckan-base.md` (template genérico) que los skills CKAN heredan mediante `includes` en el frontmatter. Los no-CKAN tienen su propia estructura. El instalador unifica todo.

## Decisiones de arquitectura

| Decisión | Opción | Alternativas | Rationale |
|----------|--------|--------------|----------|
| Organización de archivos | 1 skill `.md` por CCAA | 1 archivo por tecnología | Cada CCAA es independiente; triggers por nombre de comunidad son más precisos; el agente carga solo lo relevante |
| Plantilla CKAN | `skill-ckan-base.md` con `includes` por comunidad | Copiar mismo template 9 veces | ~80% del código es idéntico; Aragón tiene ruta no estándar (`/ckan/api/3/action`); una corrección en base arregla todas |
| Standalone no-CKAN | Skills independientes con su propia API | Forzarlos a un template común | Euskadi usa SPARQL, Cataluña Socrata — no comparten nada con CKAN; cada uno necesita ejemplos y endpoints distintos |
| Stubs sin portal | Archivos informativos sin llamadas HTTP | Omitirlos | El usuario debe saber qué portales no existen; `--check` del instalador debe fallar explícitamente |
| Formato instalador | Script bash único en `scripts/` | Inline en README | El instalador debe ser independiente del proyecto; `--dry-run`, `--force`, `--verbose`, `--check` son flags estándar |
| Ruta de instalación | `$HOME/.config/opencode/skills/` siempre | Ruta absoluta | Sin rutas con `/home/palan` — usa `$HOME` o `~` |

## Flujo de datos

```
Usuario → trigger "aragón" → skill-aragón.md
                                   │
                                   ├── reads skill-ckan-base.md (includes)
                                   │
                                   └── api_base: opendata.aragon.es
                                       api_path: /ckan/api/3/action
                                       →
                                       curl {api_base}{api_path}/package_search?q=...

Para standalone (Euskadi):
  Usuario → "euskadi" → skill-euskadi.md
                         → SPARQL endpoint → opendata.euskadi.eus/sparql
                         → resultado normalizado a {title, description, url}
```

## Archivos afectados

| Archivo | Acción | Descripción |
|---------|--------|-------------|
| `skills/skill-ckan-base.md` | Crear | Plantilla base CKAN con endpoints, params, formato, rate limiting |
| `skills/skill-ckan-andalucia.md` | Migrar (renombrar) | Andalucía existente → adaptar a base+config |
| `skills/skill-ckan-aragon.md` | Crear | Aragón con `api_path: /ckan/api/3/action` |
| `skills/skill-ckan-castillalamancha.md` | Crear | Castilla-La Mancha |
| `skills/skill-ckan-madrid.md` | Crear | Madrid |
| `skills/skill-ckan-murcia.md` | Crear | Murcia |
| `skills/skill-ckan-navarra.md` | Crear | Navarra |
| `skills/skill-ckan-valencia.md` | Crear | C. Valenciana |
| `skills/skill-euskadi.md` | Crear | País Vasco — SPARQL + REST |
| `skills/skill-cataluna.md` | Crear | Cataluña — Socrata |
| `skills/skill-canarias.md` | Crear | Canarias — custom |
| `skills/skill-castillayleon.md` | Crear | Castilla y León — custom |
| `skills/skill-baleares.md` | Crear | Baleares — pendiente de investigar |
| `skills/skill-asturias.md` | Crear | Stub — error de transporte |
| `skills/skill-cantabria.md` | Crear | Stub — error de transporte |
| `skills/skill-extremadura.md` | Crear | Stub — error de transporte |
| `skills/skill-galicia.md` | Crear | Stub — error de transporte |
| `skills/skill-larioja.md` | Crear | Stub — error de transporte |
| `skills/skill-ceuta.md` | Crear | Stub — sin portal |
| `skills/skill-melilla.md` | Crear | Stub — sin portal |
| `scripts/install-comunidades-ai.sh` | Crear | Instalador bash con detección de SO y flags |
| `README.md` | Modificar | Actualizar descripción de cobertura |
| `.atl/skill-registry.md` | Modificar | Indexar todas las skills nuevas |

## Interfaces / Contratos

### Plantilla CKAN base (skill-ckan-base.md)

```yaml
---
name: <ccaa-slug>
description: "CLI para <portal> (CKAN v3). Trigger: <comunidad>, datos abiertos <comunidad>..."
license: MIT
metadata:
  author: comunidad OpenCode
  version: "0.1.0"
  api_base: "<url_base>"
  api_path: "/api/3/action"  # Default; Aragón: "/ckan/api/3/action"
---
```

**Comandos compartidos** (iguales para todos los CKAN):
- `dataset list` → `{api_base}{api_path}/package_search`
- `dataset get <id>` → `{api_base}{api_path}/package_show?id=<id>`
- `org list` → `{api_base}{api_path}/organization_list`
- `org get <id>` → `{api_base}{api_path}/organization_show?id=<id>`
- `group list` → `{api_base}{api_path}/group_list`
- `group get <id>` → `{api_base}{api_path}/group_show?id=<id>`
- `search` → `{api_base}{api_path}/package_search?q=<term>`

**Formato de respuesta** (CKAN estándar):
```json
{"success": true, "result": {"count": N, "results": [...]}}
```

### Standalone: País Vasco (SPARQL)

Endpoint: `https://opendata.euskadi.eus/sparql`
Query: `SELECT ?s ?p ?o WHERE { ?s ?p ?o } LIMIT 10`
Formato: SPARQL XML/JSON → normalizado a `{title, description, url}`

### Standalone: Cataluña (Socrata)

Endpoint: `https://analisi.transparenciacatalunya.cat/api/views`
Formato: SODA API JSON → `{name, description, rows}`

### Standalone: Canarias / Castilla y León (custom)

Pendiente de investigación — sección `## Pendiente` en el skill.

### Instalador: flags

| Flag | Efecto |
|------|--------|
| `--dry-run` | Simula sin copiar |
| `--force` | Crea directorio si no existe |
| `--verbose` | Muestra cada operación |
| `--check` | Verifica instalación + pinge portales |

## Estrategia de testing

| Capa | Qué probar | Cómo |
|------|-----------|------|
| Sintaxis | Frontmatter YAML válido | `python3 -c "import yaml; yaml.safe_load(open(...))"` para cada skill |
| API | Cada endpoint responde HTTP 200 | `curl -s -o /dev/null -w "%{http_code}" {url}` |
| Formato | Respuesta JSON válida | `curl -s {url} | python3 -m json.tool` |
| Instalador | Flags `--dry-run`, `--force` | Ejecutar cada flag y verificar salida |
| Stubs | Sin llamadas HTTP | Ejecutar en entorno sin red — debe pasar |

## Migración / Rollout

No requiere migración de datos. Rollout secuencial:
1. Crear `skill-ckan-base.md`
2. Migrar `skill-junta-andalucia.md` → `skill-ckan-andalucia.md` (rename + add `includes`)
3. Crear skills CKAN restantes
4. Crear standalone (Euskadi, Cataluña, Canarias, CyL)
5. Crear stubs
6. Crear instalador
7. Actualizar registry + README

## Preguntas abiertas

- [ ] Confirmar URL base para Baleares (caib.es/caibdata — ¿qué API usa?)
- [ ] Euskadi SPARQL endpoint necesita más investigación — ¿tiene REST también o solo SPARQL?
- [ ] Canarias: ¿plataforma personalizada o algún fork de CKAN conocido?
- [ ] Castilla y León: confirmar si `datosabiertos.jcyl.es` es realmente custom o CKAN con path diferente
- [ ] ¿Queremos los stubs como skills separados o consolidados en un solo stub por tipo de error?