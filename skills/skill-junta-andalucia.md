---
name: junta-andalucia
description: "CLI para el portal de datos abiertos de la Junta de Andalucía (CKAN v3). Trigger: datos de la Junta de Andalucía, portal andalucia, datos abiertos andalucia, datasets andaluces, organizaciones andaluzas, recursos de la Junta."
license: MIT
metadata:
  author: comunidad OpenCode
  version: "0.1.0"
  api_base: "https://www.juntadeandalucia.es/datosabiertos/portal"
  api_path: "/api/3/action"
  api_type: ckan
  base_template: skill-ckan-base
  migrated_to: skill-ckan-andalucia
---

# SKILL: junta-andalucia — Portal de Datos Abiertos de la Junta de Andalucía (CKAN)

## Metadata
- **name**: `junta-andalucia`
- **version**: `0.1.0`
- **author**: comunidad OpenCode

## Trigger

Actívate cuando el usuario menciona:
- "datos de la junta de andalucia", "portal andalucia", "andalucia datos abiertos"
- "junta-andalucia", "andalucia abierto", "datos abiertos andalucia"
- "datasets de la junta", "organizaciones andaluzas"
- Cualquier referencia a `junta deandalucia.es/datosabiertos`

## API Base

```
https://www.juntadeandalucia.es/datosabiertos/portal/api/3/action
```

CKAN v3 pública — no requiere API key. Formato JSON en todas las respuestas.

## Comandos

| Comando | Descripción | API |
|---------|-------------|-----|
| `dataset list` | Lista todos los datasets disponibles | `package_search` |
| `dataset get <id>` | Obtiene detalle de un dataset | `package_show` |
| `org list` | Lista organizaciones publicadoras | `organization_list` |
| `org get <id>` | Detalle de una organización | `organization_show` |
| `group list` | Lista grupos temáticos | `group_list` |
| `group get <id>` | Detalle de un grupo | `group_show` |
| `search` | Búsqueda avanzada con filtros | `package_search` |

## Parámetros

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `--rows` | int | Nº de resultados por página (máx 50, por defecto 10) |
| `--start` | int | Offset para paginación (0-based) |
| `--q` | string | Query de búsqueda |
| `--fq` | string | Facet query (filtro por organización, grupo, etc.) |
| `--org <name>` | string | Filtrar por organización (ID del slug) |
| `--group <name>` | string | Filtrar por grupo temático |

## Formato de respuesta

Todas las respuestas siguen el formato CKAN:

```json
{
  "success": true,
  "result": {
    "count": 833,
    "results": [
      {
        "name": "academias-andaluzas",
        "title": "Academias andaluzas",
        "organization": {
          "title": "Universidad, Investigación e Innovación"
        },
        "groups": [],
        "tags": [],
        "resources": [
          {
            "url": "https://...",
            "format": "CSV",
            "name": "Academias andaluzas 2024"
          }
        ]
      }
    ]
  }
}
```

**Campos clave de un dataset**:
- `title` / `name`: título y slug del dataset
- `organization.title`: publicador (ej: "Instituto de Estadística y Cartografía de Andalucía")
- `groups[].display_name`: categorías temáticas
- `tags[].display_name`: etiquetas (hasta 5)
- `resources[].format`: CSV, JSON, HTML, etc.
- `resources[].url`: URL del recurso real

## Ejemplos prácticos

### 1. Listar todos los datasets

```python
import requests, json

api = 'https://www.juntadeandalucia.es/datosabiertos/portal/api/3/action'

r = requests.get(f'{api}/package_list', timeout=15)
ids = r.json().get('result', [])
print(f'Total: {len(ids)} datasets')
```

### 2. Obtener las 10 principales organizaciones

```python
import requests, json, time

api = 'https://www.juntadeandalucia.es/datosabiertos/portal/api/3/action'

r = requests.get(f'{api}/organization_list', timeout=15)
orgs = r.json().get('result', [])

org_count = []
for o in orgs:
    r = requests.get(f'{api}/organization_show', params={'id': o}, timeout=15)
    od = r.json().get('result', {})
    org_count.append((od.get('title', o), od.get('package_count', 0)))
    time.sleep(0.1)

org_count.sort(key=lambda x: -x[1])
for title, count in org_count[:10]:
    print(f'{title}: {count} datasets')
```

### 3. Buscar datasets por organización

```python
import requests, json

api = 'https://www.juntadeandalucia.es/datosabiertos/portal/api/3/action'

r = requests.post(f'{api}/package_search', json={'rows': 50, 'q': '*', 'fq': 'organization:sostenibilidad-y-medio-ambiente'}, timeout=15)
results = r.json().get('result', {}).get('results', [])
total = r.json().get('result', {}).get('count', 0)

print(f'Total en esta org: {total}')
for ds in results:
    print(f'  {ds["title"]} — {len(ds.get("resources", []))} recursos')
```

### 4. Buscar por grupo temático

```python
import requests

api = 'https://www.juntadeandalucia.es/datosabiertos/portal/api/3/action'

r = requests.get(f'{api}/group_list', timeout=15)
groups = r.json().get('result', [])
print(f'Grupos disponibles: {len(groups)}')

for g in groups:
    r = requests.get(f'{api}/group_show', params={'id': g}, timeout=15)
    gd = r.json().get('result', {})
    print(f'{gd.get("display_name", g)}: {gd.get("package_count", 0)} datasets')
```

### 5. Obtener todas las organizaciones y su conteo

```python
import requests, json

api = 'https://www.juntadeandalucia.es/datosabiertos/portal/api/3/action'

r = requests.get(f'{api}/organization_list', timeout=15)
orgs = r.json().get('result', [])

print(f'{len(orgs)} organizaciones registradas')

for o in orgs[:5]:
    r = requests.get(f'{api}/organization_show', params={'id': o}, timeout=15)
    od = r.json().get('result', {})
    print(f'{od.get("title", o)}: {od.get("package_count", 0)}  — {od.get("description", "-")[:80]}')
```

## Paginación

El endpoint `package_search` acepta `rows` y `start`:

```python
r = requests.post(f'{api}/package_search', json={'rows': 50, 'start': 0, 'q': '*'})
```

Para recorrer todos los 833 datasets:
1. Primera llamada: `{..., 'start': 0}` → get `count`
2. Siguientes: `{..., 'start': 50}` → hasta que `results` esté vacío o `start >= count`

## Notas técnicas

- **API pública**: no requiere autenticación ni API key
- **Formato**: CKAN v3 con `success` + `result` en todas las respuestas
- **Rate limiting**: esperar 0.2s entre requests secuenciales
- **Timeout**: 15s por defecto
- **Paginación**: `rows` (máx 50) + `start` (0-based)
- **Buscar por organización**: `fq=organization:<slug>` (el slug es el `name` de la org)
- **Buscar por grupo**: `fq=groups:<slug>` (el slug del grupo)
- **Query libre**: `q=<término>` en `title` y `notes`
- **Recursos**: cada dataset tiene `resources[]` con `url`, `format`, `name`, `description`