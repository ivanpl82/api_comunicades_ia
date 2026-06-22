---
name: baleares
description: "CLI para el portal de datos abiertos de las Illes Balears. Trigger: datos de Baleares, illes balears datos, balears opendata, ccaib datos, catalegdades.caib.cat, ibestat."
license: MIT
metadata:
  author: comunidad OpenCode
  version: "1.0.0"
  api_base: "https://catalegdades.caib.cat"
  api_type: unknown
  api_status: unknown
  investigation_url: "https://catalegdades.caib.cat"
  last_checked: "2026-06-22"
---

# SKILL: baleares — Portal de Datos Abiertos de las Illes Balears (plataforma por investigar)

## Metadata

- **name**: `baleares`
- **version**: `1.0.0`
- **author**: comunidad OpenCode
- **api_base**: `https://catalegdades.caib.cat`
- **api_type**: plataforma por determinar (posible DKAN / CKAN-like / Socrata)
- **api_status**: `unknown` — la URL de la API REST no se ha confirmado.
- **investigation_url**: `https://catalegdades.caib.cat`
- **last_checked**: `2026-06-22`

## Trigger

Actívate cuando el usuario menciona:
- "datos de baleares", "illes balears datos abiertos"
- "catalegdades.caib.cat", "caib datos"
- "ibestat", "institut balear d'estadística"
- "datos abiertos baleares", "opendata balears"
- "govern de les illes balears datos"

## API Base

```
https://catalegdades.caib.cat
```

El portal de Datos Abiertos de las Illes Balears (`catalegdades.caib.cat`)
contiene más de 14.700 conjuntos de datos publicados por el Govern de les
Illes Balears, con el IBESTAT (Institut Balear d'Estadística) como principal
publicador (>14.300 datasets). La plataforma cuenta con un catálogo navegable
por organizaciones, publicadores, categorías, etiquetas, formatos y licencias.

### API — bajo investigación

El portal parece ser una instalación de ckan/DKAN con interfaz personalizada.
No se ha confirmado aún la URL exacta de la API REST.

| Ruta | Estado |
|------|--------|
| `https://catalegdades.caib.cat/api/3/action/package_list` | `404` — no CKAN |
| `https://catalegdades.caib.cat/api/views.json` | `404` — no Socrata |
| `https://catalegdades.caib.cat/api/` | Por verificar |
| `https://catalegdades.caib.cat/api/action/` | Por verificar |
| `https://catalegdades.caib.cat/catalog/` | Por verificar |

## Comandos

| Comando | Descripción |
|---------|-------------|
| `dataset list` | Lista datasets (por determinar) |
| `search <q>` | Búsqueda textual |
| `ibestat <tema>` | Consultar datos del IBESTAT |

## Parámetros

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `--limit` | int | Nº de resultados |
| `--format` | string | Formato: `json` (default), `csv` |
| `--source` | string | Fuente: `catalegdades` (default) o `ibestat` |

## Formato de respuesta

El catálogo web muestra datasets con la siguiente estructura (observada en el web):

```json
{
  "title": "Viatges Càrrecs Públics Govern Illes Balears",
  "organitzacio": "DG de Transparència i Bon Govern",
  "categories": ["Sector públic"],
  "formats": ["CSV", "JSON"],
  "last_updated": "2026-06-22"
}
```

Los campos concretos variarán según se confirme la API.

## Ejemplos prácticos

### 1. Verificar disponibilidad del portal

```python
import requests

r = requests.get("https://catalegdades.caib.cat", timeout=15)
print(f"Portal Balears: {r.status_code} — {'disponible' if r.status_code == 200 else 'no disponible'}")
```

### 2. Navegar al catálogo web

```python
import requests
from bs4 import BeautifulSoup

# Parsearemos la página de inicio para obtener información del catálogo
r = requests.get("https://catalegdades.caib.cat", timeout=15)
if r.status_code == 200:
    print("Portal accesible. Contiene ~14.724 datasets de IBESTAT y otros organismos.")
```

### 3. Consultar IBESTAT (portal estadístico)

```python
import requests

# IBESTAT — Institut Balear d'Estadística
ibestat_base = "https://ibestat.caib.es"
r = requests.get(f"{ibestat_base}/ibestat/api/", timeout=15)
print(f"IBESTAT API: {r.status_code}")
```

## Notas técnicas

- **API**: **pendiente de confirmar** — la URL oficial de la API REST del portal
  `catalegdades.caib.cat` no se ha localizado aún.
- **IBESTAT**: el Institut Balear d'Estadística publica datos a través de su propio
  portal en `https://ibestat.caib.es`. Es la principal fuente de datos estadísticos
  de las Illes Balears.
- **Formats disponibles**: JSON, CSV, GeoJSON, XML, TSV, RDF, PDF, HTML (observado
  en el catálogo web).
- **Temáticas**: demografía, sociedad y bienestar, ciencia y tecnología, trabajo,
  sector público, hacienda, economía, salud, medio ambiente, educación.
- **Licencia**: mayoritariamente Creative Commons.
- **Nota**: al confirmar la URL de la API REST, actualizar `api_path` y comandos.
  El portal parece tener interfaz DKAN/CKAN modificado con más de 14.000 datasets.