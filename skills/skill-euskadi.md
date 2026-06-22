---
name: euskadi
description: "CLI para el portal de datos abiertos de Euskadi — SPARQL endpoint + API REST. Trigger: datos de Euskadi, euskadi datos abiertos, opendata euskadi, euskadi datos, datasets euskadi, SPARQL euskadi."
license: MIT
metadata:
  author: comunidad OpenCode
  version: "1.0.0"
  api_base: "https://api.euskadi.eus"
  api_type: sparql
  api_path: "/sparql"
  api_extra: ""
---

# SKILL: euskadi — Portal Open Data Euskadi (SPARQL + REST API)

## Metadata

- **name**: `euskadi`
- **version**: `1.0.0`
- **author**: comunidad OpenCode
- **api_base**: `https://api.euskadi.eus`
- **api_path**: `/sparql`
- **api_type**: SPARQL + REST API (Linked Open Data + endpoints temáticos)
- **language**: SPARQL queries / JSON-LD responses

## Trigger

Actívate cuando el usuario menciona:
- "datos del gobierno vasco", "euskadi datos abiertos"
- "opendata euskadi", "datos de euskadi", "datasets vascos"
- "sparql euskadi", "linked open data euskadi"
- "opendata.euskadi.eus", "data.euskadi.eus"
- "presupuestos euskadi", "estadísticas euskadi", "geografía euskadi"

Cualquier referencia a `euskadi.eus` o `opendata.euskadi.eus`.

## API Base

```
https://api.euskadi.eus/sparql/
```

El portal de Open Data Euskadi ofrece dos capas:

1. **SPARQL endpoint** (https://api.euskadi.eus/sparql/) — consultas RDF/SPARQL,
   cargadas en una base de datos semántica donde la información se almacena en grafos.
2. **REST API** — varios endpoints temáticos no-CKAN (catálogos, recursos estadísticos,
   datasets de organizaciones públicas).

### Endpoints disponibles

| Tipo | URL | Uso |
|------|-----|-----|
| SPARQL | `https://api.euskadi.eus/sparql/` | Consultas RDF con SPARQL |
| REST datasets | `https://opendata.euskadi.eus/catalogo-datos/` | Catálogos de datasets LOD |
| Temáticos | `https://api.euskadi.eus/<tema>` | Endpoints temáticos |

## Comandos

| Comando | Descripción | Método |
|---------|-------------|--------|
| `dataset list` | Lista datasets disponibles en el catálogo LOD | SPARQL `SELECT` |
| `dataset get <uri>` | Obtiene detalle RDF de un dataset | SPARQL `DESCRIBE` |
| `search <q>` | Búsqueda SPARQL por término libre | SPARQL `SELECT` |
| `query <sparql>` | Ejecuta consulta SPARQL arbitraria | `POST /sparql/` |
| `stat` | Estadísticas de la base de datos RDF | `COUNT` query |
| `org list` | Lista organizaciones publicadoras | SPARQL `SELECT DISTINCT ?org` |

## Parámetros

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `--format` | string | Formato de salida: `json` (default), `xml`, `csv`, `tsv` |
| `--timeout` | int | Timeout en segundos (por defecto 30) |
| `--limit` | int | Límite de resultados (SPARQL: `LIMIT <n>`) |
| `--offset` | int | Offset para paginación (SPARQL: `OFFSET <n>`) |
| `--graph` | string | Grafo concreto a consultar (SPARQL: `FROM <graph>`) |
| `--query` | string | Consulta SPARQL completa (raw) |

## Formato de respuesta

Las respuestas SPARQL siguen el formato W3C SPARQL Results JSON:

```json
{
  "head": {
    "vars": ["s", "p", "o"]
  },
  "results": {
    "bindings": [
      {
        "s": { "type": "uri", "value": "http://..." },
        "p": { "type": "uri", "value": "http://..." },
        "o": {
          "type": "literal",
          "xml:lang": "es",
          "value": "Valor"
        }
      }
    ]
  }
}
```

Para respuestas REST de `opendata.euskadi.eus`:

```json
{
  "result": {
    "count": <n>,
    "results": [
      {
        "title": "Título del dataset",
        "description": "Descripción",
        "publisher": "Organización",
        "resources": ["url1", "url2"]
      }
    ]
  }
}
```

## Ejemplos prácticos

### 1. Listar todos los datasets (SPARQL)

```python
import requests

endpoint = "https://api.euskadi.eus/sparql/"
query = """
SELECT DISTINCT ?dataset ?title
WHERE {
  ?dataset a dcat:Dataset .
  ?dataset dct:title ?title .
}
LIMIT 50
"""

r = requests.get(endpoint, params={"query": query, "format": "json"}, timeout=30)
data = r.json()
bindings = data.get("results", {}).get("bindings", [])
print(f"{len(bindings)} datasets encontrados")
for b in bindings:
    print(f"  - {b.get('title', {}).get('value', 'sin título')}")
```

### 2. Búsqueda por texto libre

```python
import requests

endpoint = "https://api.euskadi.eus/sparql/"
query = """
PREFIX dcat: <http://www.w3.org/ns/dcat#>
PREFIX dct: <http://purl.org/dc/terms/>

SELECT ?dataset ?title ?description
WHERE {
  ?dataset a dcat:Dataset ;
           dct:title ?title ;
           dct:description ?description .
  FILTER(CONTAINS(LCASE(?title), "presupuesto"))
}
"""

r = requests.get(endpoint, params={"query": query, "format": "json"}, timeout=30)
data = r.json()
print(f"Datasets sobre presupuestos en Euskadi ({len(data['results']['bindings'])}):")
for b in data["results"]["bindings"]:
    print(f"  - {b['title']['value']}")
```

### 3. Obtener todos los datasets de una organización

```python
import requests

endpoint = "https://api.euskadi.eus/sparql/"
query = """
PREFIX dcat: <http://www.w3.org/ns/dcat#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>

SELECT ?dataset ?title ?publisher
WHERE {
  ?dataset a dcat:Dataset ;
           dct:publisher ?publisherUri .
  ?publisherUri foaf:name "Gobierno Vasco"@es .
}
"""

r = requests.get(endpoint, params={"query": query, "format": "json"}, timeout=30)
data = r.json()
print("Datasets publicados por el Gobierno Vasco:")
for b in data.get("results", {}).get("bindings", []):
    print(f"  - {b.get('title', {}).get('value', '?')}")
```

### 4. Obtener información de un recurso concreto

```python
import requests

endpoint = "https://api.euskadi.eus/sparql/"
query = """
PREFIX dcat: <http://www.w3.org/ns/dcat#>
PREFIX dct: <http://purl.org/dc/terms/>

DESCRIBE <http://opendata.euskadi.eus/dataset/123456>
"""

r = requests.get(endpoint, params={"query": query}, timeout=30)
print(f"Tipo: {r.headers.get('content-type')}")
```

## Paginación

En SPARQL, la paginación se hace con `LIMIT` + `OFFSET`:

```python
import requests

endpoint = "https://api.euskadi.eus/sparql/"

# Primera página
query = "SELECT ?s ?p ?o WHERE { ?s ?p ?o } LIMIT 100 OFFSET 0"
r = requests.get(endpoint, params={"query": query, "format": "json"}, timeout=30)
total = len(r.json()["results"]["bindings"])

# Siguientes páginas
for offset in range(100, min(total, 1000), 100):
    query = f"SELECT ?s ?p ?o WHERE {{ ?s ?p ?o }} LIMIT 100 OFFSET {offset}"
    r = requests.get(endpoint, params={"query": query, "format": "json"}, timeout=30)
    print(f"Página con OFFSET={offset}: {len(r.json()['results']['bindings'])} resultados")
```

## Notas técnicas

- **API pública**: no requiere autenticación ni API key
- **Formato**: SPARQL Results JSON (`application/sparql-results+json`) o JSON-LD
- **Rate limiting**: 1 petición cada 1s (evitar sobrecarga del endpoint SPARQL)
- **Timeout**: 30s por defecto (las consultas SPARQL pueden ser lentas con datasets grandes)
- **Paginación**: `LIMIT <n>` + `OFFSET <n>` (no `rows`/`start` como en CKAN)
- **Lenguaje de consulta**: SPARQL 1.1 (`SELECT`, `DESCRIBE`, `ASK`, `CONSTRUCT`)
- **Vocabularios**: `dcat:Dataset`, `dct:title`, `dct:publisher`, `foaf:name`, `dct:description`
- **URI de la API**: `https://api.euskadi.eus/sparql/` (el portal de datos usa el mismo endpoint)
- **Nota**: aunque `data.euskadi.eus` devuelve 403/500, el endpoint `api.euskadi.eus/sparql` está operativo.
  Usar el subdominio `api.` en lugar de `data.` para el endpoint SPARQL.
- **Datos asociados**: LOD (Linked Open Data) — no solo CKAN, también hay datasets temáticos