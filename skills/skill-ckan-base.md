---
name: ckan-base
description: "Plantilla base CKAN v3 para portales de datos abiertos. Trigger: ckan, datos abiertos ckan, portales ckan."
license: MIT
metadata:
  author: comunidad OpenCode
  version: "1.0.0"
  api_base: "<url_base>"
  api_path: "/api/3/action"
  api_type: ckan
---

# SKILL: ckan-base — Plantilla base CKAN v3 para portales de datos abiertos

## Metadata

- **name**: `ckan-base`
- **version**: `1.0.0`
- **author**: comunidad OpenCode
- **api_base**: configurable por comunidad
- **api_path**: `/api/3/action` (por defecto; Aragón usa `/ckan/api/3/action`)
- **api_type**: CKAN v3

## Trigger

Actívate cuando el usuario menciona:
- "ckan base", "plantilla ckan", "template ckan"
- "datos abiertos ckan", "portal ckan v3"
- Cualquier referencia a endpoints CKAN estándar

Los skills de comunidad individuales usan triggers específicos de su territorio.

## API Base

```
{api_base}{api_path}
```

CKAN v3 pública — no requiere API key. Formato JSON en todas las respuestas.

### api_path configurable

| Comunidad | `api_path` |
|-----------|-----------|
| Valor por defecto | `/api/3/action` |
| Aragón | `/ckan/api/3/action` |

## Comandos

| Comando | Descripción | Endpoint API |
|---------|-------------|-------------|
| `dataset list` | Lista todos los datasets disponibles | `package_search` |
| `dataset get <id>` | Obtiene detalle de un dataset | `package_show` |
| `org list` | Lista organizaciones publicadoras | `organization_list` |
| `org get <id>` | Detalle de una organización | `organization_show` |
| `group list` | Lista grupos temáticos | `group_list` |
| `group get <id>` | Detalle de un grupo | `group_show` |
| `search` | Búsqueda avanzada con filtros | `package_search` |

## Parámetros

| Parámetro | Tipo | Endpoint | Descripción |
|-----------|------|----------|-------------|
| `--rows` | int | package_search | Nº de resultados por página (máx 50, por defecto 10) |
| `--start` | int | package_search | Offset para paginación (0-based) |
| `--q` | string | package_search | Query de búsqueda textual |
| `--fq` | string | package_search | Facet query (filtro por organización, grupo, etc.) |
| `--org <name>` | string | package_search | Filtrar por organización (slug) |
| `--group <name>` | string | package_search | Filtrar por grupo temático (slug) |
| `--id` | string | package_show | ID o slug del dataset |

## Formato de respuesta

Todas las respuestas siguen el formato CKAN estándar:

```json
{
  "success": true,
  "result": {
    "count": 833,
    "results": [
      {
        "name": "nombre-del-dataset",
        "title": "Título del dataset",
        "organization": {
          "title": "Organización publicadora"
        },
        "groups": [],
        "tags": [],
        "resources": [
          {
            "url": "https://...",
            "format": "CSV",
            "name": "Nombre del recurso"
          }
        ]
      }
    ]
  }
}
```

### Campos clave de un dataset

- `title` / `name`: título y slug del dataset
- `organization.title`: publicador (ej: "Consejería de Educación")
- `groups[].display_name`: categorías temáticas
- `tags[].display_name`: etiquetas (hasta 5)
- `resources[].format`: CSV, JSON, HTML, etc.
- `resources[].url`: URL del recurso real

### Respuesta de error

```json
{
  "success": false,
  "error": {
    "message": "__type: Descripción del error"
  }
}
```

## Ejemplos prácticos

### 1. Listar todos los datasets

```python
import requests

api = '{api_base}{api_path}'

r = requests.get(f'{api}/package_list', timeout=15)
ids = r.json().get('result', [])
print(f'Total: {len(ids)} datasets')
```

### 2. Obtener las principales organizaciones

```python
import requests, time

api = '{api_base}{api_path}'

r = requests.get(f'{api}/organization_list', timeout=15)
orgs = r.json().get('result', [])

org_count = []
for o in orgs:
    r = requests.get(f'{api}/organization_show', params={'id': o}, timeout=15)
    od = r.json().get('result', {})
    org_count.append((od.get('title', o), od.get('package_count', 0)))
    time.sleep(0.2)

org_count.sort(key=lambda x: -x[1])
for title, count in org_count[:10]:
    print(f'{title}: {count} datasets')
```

### 3. Buscar datasets por organización

```python
import requests

api = '{api_base}{api_path}'

r = requests.post(f'{api}/package_search', json={'rows': 50, 'q': '*', 'fq': 'organization:mi-organizacion'}, timeout=15)
results = r.json().get('result', {}).get('results', [])
total = r.json().get('result', {}).get('count', 0)

print(f'Total en esta org: {total}')
for ds in results:
    print(f'  {ds["title"]} — {len(ds.get("resources", []))} recursos')
```

### 4. Buscar por grupo temático

```python
import requests

api = '{api_base}{api_path}'

r = requests.get(f'{api}/group_list', timeout=15)
groups = r.json().get('result', [])
print(f'Grupos disponibles: {len(groups)}')

for g in groups:
    r = requests.get(f'{api}/group_show', params={'id': g}, timeout=15)
    gd = r.json().get('result', {})
    print(f'{gd.get("display_name", g)}: {gd.get("package_count", 0)} datasets')
```

### 5. Búsqueda textual

```python
import requests

api = '{api_base}{api_path}'

r = requests.get(f'{api}/package_search', params={'q': 'agua', 'rows': 10}, timeout=15)
data = r.json()
if data.get('success'):
    print(f'Resultados: {data["result"]["count"]}')
    for ds in data['result']['results']:
        print(f'  - {ds["title"]}')
```

## Paginación

El endpoint `package_search` acepta `rows` y `start`:

```python
import requests

api = '{api_base}{api_path}'

# Primera página
r = requests.post(f'{api}/package_search', json={'rows': 50, 'start': 0, 'q': '*'})
data = r.json()
total = data['result']['count']

# Recorrer todas las páginas
for offset in range(0, min(total, 500), 50):
    r = requests.post(f'{api}/package_search', json={'rows': 50, 'start': offset, 'q': '*'})
    for ds in r.json()['result']['results']:
        print(ds['title'])
    import time
    time.sleep(0.2)
```

## Notas técnicas

- **API pública**: no requiere autenticación ni API key en la mayoría de portales
- **Formato**: CKAN v3 con `success` + `result` en todas las respuestas
- **Rate limiting**: esperar 0.2s entre requests secuenciales (5 peticiones/segundo máximo)
- **Timeout**: 15s por defecto
- **Paginación**: `rows` (máx 50) + `start` (0-based)
- **Buscar por organización**: `fq=organization:<slug>` (el slug es el `name` de la org)
- **Buscar por grupo**: `fq=groups:<slug>` (el slug del grupo)
- **Query libre**: `q=<término>` en `title` y `notes`
- **Recursos**: cada dataset tiene `resources[]` con `url`, `format`, `name`, `description`
- **api_path**: la mayoría de portales usan `/api/3/action`; Aragón usa `/ckan/api/3/action`
