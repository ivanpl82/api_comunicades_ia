# comunas-ai-skills-standalone — Skills no-CKAN

## Propósito

Skills independientes para comunidades que NO usan CKAN v3.
Cada una tiene su propia API, endpoints y formato de respuesta.

## Requisitos

### R1: Cobertura de comunidades no-CKAN

El sistema SHALL proveer un skill por cada comunidad no-CKAN confirmada:

| Comunidad | API | Portal Base |
|-----------|-----|-------------|
| Euskadi | SPARQL + REST | `opendata.euskadi.eus` |
| Cataluña | Socrata | `analisi.transparenciacatalunya.cat` |
| Canarias | Custom | `datos.canarias.es` |
| Castilla y León | Custom | `datosabiertos.jcyl.es` |
| Baleares | CKAN desconocida | `caib.es/caibdata` |

### R2: Comandos mínimos

Cada skill SHALL implementar al menos estos comandos:

| Comando | Descripción |
|---------|-------------|
| `dataset list [--q "término"] [--rows N]` | Listar datasets disponibles |
| `dataset get <id>` | Obtener detalle de un dataset |

#### Escenario: Listar datasets (Euskadi — SPARQL)

- GIVEN el skill de Euskadi con `--q "calidad aire" --rows 5`
- WHEN se ejecuta `dataset list`
- THEN construye una consulta SPARQL contra el endpoint `https://opendata.euskadi.eus/sparql`
- AND devuelve ≤5 datasets con título y URL

#### Escenario: Obtener dataset (Cataluña — Socrata)

- GIVEN el skill de Cataluña con `--id "abc-def-123"`
- WHEN se ejecuta `dataset get abc-def-123`
- THEN llama a `https://analisi.transparenciacatalunya.cat/resource/{id}.json`
- AND devuelve el dataset completo

#### Escenario: Listar datasets con error de API

- GIVEN la API de Canarias devuelve HTTP 500
- WHEN se ejecuta `dataset list`
- THEN muestra `Error: La API de Canarias no responde (HTTP 500)`
- AND sale con código 1

### R3: Triggers específicos

Cada skill SHALL tener su propio trigger para que el agente lo active
por nombre de comunidad:

| Skill | Trigger |
|-------|---------|
| Euskadi | `euskadi`, `pais vasco`, `opendata.euskadi.eus` |
| Cataluña | `cataluna`, `catalunya`, `gencat` |
| Canarias | `canarias`, `datos.canarias.es` |
| Castilla y León | `castilla y leon`, `jcyl` |

#### Escenario: Activación por nombre de comunidad

- GIVEN el usuario escribe "busca datos de euskadi sobre turismo"
- WHEN el agente reconoce el trigger `euskadi`
- THEN carga el skill de Euskadi y ejecuta `dataset list --q "turismo"`

### R4: Formato de salida unificado

Cada skill SHOULD normalizar su salida a un formato común:

| Campo | Origen | Descripción |
|-------|--------|-------------|
| `title` | Mapeado del campo título de cada API | Nombre del dataset |
| `description` | Mapeado de descripción | Resumen del dataset |
| `url` | URL directa al portal del dataset | Enlace de acceso |
| `format` | Formato de los datos (CSV, JSON, etc.) | Si aplica |
| `issued` | Fecha de publicación | ISO 8601 |

#### Escenario: Normalización desde SPARQL

- GIVEN la respuesta SPARQL devuelve `?title`, `?desc`, `?url`
- WHEN se normaliza la respuesta
- THEN los campos se mapean a `title`, `description`, `url`
