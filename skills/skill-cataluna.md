---
name: cataluna
description: "CLI para el portal de transparencia de Cataluña (Socrata API). Trigger: datos de Cataluña, transparencia cataluña, dades obertes catalunya, catalunya datos abiertos, analisi.transparenciacatalunya.cat."
license: MIT
metadata:
  author: comunidad OpenCode
  version: "1.0.0"
  api_base: "https://analisi.transparenciacatalunya.cat"
  api_path: "/resource"
  api_type: socrata
  api_format: "json"
  app_token_required: false
---

# SKILL: cataluna — Portal de Transparencia de Cataluña (Socrata API)

## Metadata

- **name**: `cataluna`
- **version**: `1.0.0`
- **author**: comunidad OpenCode
- **api_base**: `https://analisi.transparenciacatalunya.cat`
- **api_path**: `/resource`
- **api_type**: Socrata (SODA API)
- **api_format**: JSON (por defecto), CSV, XML
- **app_token_required**: false (pública)

## Trigger

Actívate cuando el usuario menciona:
- "datos de la transparencia de catalunya", "transparencia catalunya"
- "analisi.transparenciacatalunya.cat", "dades obertes catalunya"
- "datos abiertos cataluña", "catalunya datos abiertos"
- "cataluña sodapoint", "socrata cataluña"
- "catalunya datasets", "datasets catalanes"
- "dadesobertes.gencat.cat" (portal complementario)

## API Base

```
https://analisi.transparenciacatalunya.cat/resource/{dataset-id}.json
```

Este portal utiliza **Socrata Open Data API (SODA)**, la plataforma de datos abiertos
de Socrata, también conocida como Socrata Socrata / Tyler Technologies. El catálogo
cubre datos de transparencia, presupuestos, contratación, personal, y subvenciones
de la Generalitat de Catalunya.

## Comandos

| Comando | Descripción | Endpoint API |
|---------|-------------|-------------|
| `dataset list` | Lista datasets del catálogo | `api/views.json` |
| `dataset get <id>` | Obtiene registros de un dataset | `/resource/{id}.json` |
| `search <q>` | Búsqueda en todos los datasets | `/resource/{id}.json?$q=<query>` |
| `count <id>` | Cuenta registros de un dataset | `/resource/{id}.json?$select=count(*)` |
| `filter <id> <col> <val>` | Filtra por columna | `/resource/{id}.json?<col>=<val>` |

## Parámetros

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `--limit` | int | Nº de resultados (SODA: `$limit`, máx 50000, por defecto 1000) |
| `--offset` | int | Offset para paginación (SODA: `$offset`, 0-based) |
| `--where` | string | Filtro SoQL: `$where=<condición>` |
| `--select` | string | Columnas a seleccionar: `$select=<col1,col2>` |
| `--order` | string | Ordenación: `$order=<col> DESC` |
| `--q` | string | Búsqueda texto completo: `$q=<query>` |
| `--format` | string | Formato: `json` (default), `csv`, `xml` |

## Formato de respuesta

Las respuestas SODA en JSON devuelven un array de objetos:

```json
[
  {
    "id_dataset": "12345",
    "titol": "Título del dataset",
    "descripcio": "Descripción en catalán",
    "organisme": "Departament de ...",
    "any": "2024",
    "tipus": "Pressupost",
    ":created_at": "2024-01-15T10:30:00.000",
    ":updated_at": "2024-06-20T14:22:00.000"
  }
]
```

### Campos comunes en todos los datasets

- `:id` — identificador único Socrata (4-4-4-4-12 formato UUID)
- `:created_at` — fecha de creación
- `:updated_at` — última actualización
- `:slug` — slug URL del dataset

Los campos concretos varían según el dataset (cada dataset tiene su propio esquema).
Usar `GET /resource/{id}.json?$limit=1` para inspeccionar el esquema.

### Catálogo de datasets

```json
{
  "views": [
    {
      "id": "xxxx-yyyy-zzzz",
      "name": "Nombre del dataset",
      "description": "Descripción",
      "category": "Transparencia",
      "columns": [],
      "rowCount": 1234,
      "createdAt": 1705321800000,
      "updatedAt": 1718888520000
    }
  ]
}
```

## Ejemplos prácticos

### 1. Listar datasets del catálogo

```python
import requests

api = "https://analisi.transparenciacatalunya.cat/api/views.json"

r = requests.get(api, params={"limit": 20}, timeout=15)
views = r.json().get("views", [])

print(f"Catálogo: {len(views)} datasets")
for v in views:
    print(f"  - {v.get('name', '?')} ({v.get('id', '?')} — {v.get('rowCount', 0)} filas)")
```

### 2. Obtener datos de un dataset concreto

```python
import requests

# ID de ejemplo — usar dataset_id real obtenido del catálogo
dataset_id = "xxxx-yyyy-zzzz"
url = f"https://analisi.transparenciacatalunya.cat/resource/{dataset_id}.json"

r = requests.get(url, params={"$limit": 10}, timeout=15)
rows = r.json()

print(f"Registros: {len(rows)}")
for row in rows:
    print(row)
```

### 3. Buscar en un dataset

```python
import requests

dataset_id = "xxxx-yyyy-zzzz"
url = f"https://analisi.transparenciacatalunya.cat/resource/{dataset_id}.json"

r = requests.get(url, params={"$q": "salud", "$limit": 10}, timeout=15)
results = r.json()
print(f"Resultados: {len(results)}")
```

### 4. Contar registros con filtro

```python
import requests

dataset_id = "xxxx-yyyy-zzzz"
url = f"https://analisi.transparenciacatalunya.cat/resource/{dataset_id}.json"

r = requests.get(url, params={
    "$select": "count(*)",
    "$where": "any = 2024"
}, timeout=15)
count = r.json()[0].get("count", 0)
print(f"Registros en 2024: {count}")
```

### 5. Paginación con SODA

```python
import requests

dataset_id = "xxxx-yyyy-zzzz"
url = f"https://analisi.transparenciacatalunya.cat/resource/{dataset_id}.json"

# SODA: $limit + $offset
for offset in range(0, 1000, 100):
    r = requests.get(url, params={"$limit": 100, "$offset": offset}, timeout=15)
    rows = r.json()
    if not rows:
        break
    print(f"Offset {offset}: {len(rows)} registros")
```

## Paginación

SODA usa `$limit` (por defecto 1000, máximo 50000) y `$offset` (0-based):

```python
r = requests.get(url, params={"$limit": 100, "$offset": 0})
```

## Notas técnicas

- **API pública**: no requiere API key para consultas básicas. Socrata recomienda un
  `X-App-Token` opcional para mayor rate limiting, pero no es obligatorio.
- **Formato**: JSON array (por defecto). También `csv`, `xml`, `geojson` según extensión.
- **Rate limiting**: 1000 peticiones por hora sin token; 50000/hora con token.
- **Timeout**: 15s por defecto.
- **Paginación**: `$limit` (max 50000) + `$offset` (0-based).
- **Lenguaje de consulta**: SoQL (Socrata Query Language) — SQL-like.
- **Fechas en formato**: timestamp Unix en milisegundos o ISO 8601.
- **Dataset ID**: formato UUID con guiones (`xxxx-yyyy-zzzz-wwww-vvvv`).
- **Portal complementario**: `https://dadesobertes.gencat.cat` (portal CKAN de la Generalitat).
- **Nota**: los nombres de columna están en catalán (no español). Prefijo `:id`, `:created_at`.
- **IDs de ejemplo** (para pruebas): consultar `api/views.json` para obtener IDs reales.