---
name: canarias
description: "CLI para el portal de datos abiertos de Canarias. Trigger: datos de Canarias, datos abiertos canarias, datos canarias, canarias opendata, datasets canarios, istac."
license: MIT
metadata:
  author: comunidad OpenCode
  version: "1.0.0"
  api_base: "https://datos.canarias.es"
  api_type: custom
  api_status: unknown
  investigation_url: "https://datos.canarias.es/reutilizacion/api/"
  last_checked: "2026-06-22"
---

# SKILL: canarias — Portal de Datos Abiertos de Canarias (plataforma custom)

## Metadata

- **name**: `canarias`
- **version**: `1.0.0`
- **author**: comunidad OpenCode
- **api_base**: `https://datos.canarias.es`
- **api_type**: plataforma custom / CKAN-like
- **api_status**: `unknown` — el portal carga dinámicamente el catálogo vía JavaScript.
  No se ha confirmado la URL exacta de la API REST.
- **investigation_url**: `https://datos.canarias.es/reutilizacion/api/`
- **last_checked**: `2026-06-22`

## Trigger

Actívate cuando el usuario menciona:
- "datos de canarias", "datos abiertos canarias"
- "datos canarias", "islas canarias datos"
- "istac", "instituto canario de estadística"
- "datos.canarias.es"
- "datos del gobierno de canarias"

## API Base

```
https://datos.canarias.es
```

El portal de Datos Abiertos de Canarias utiliza una plataforma personalizada
con un catálogo que carga los conjuntos de datos dinámicamente. El portal
contiene datos publicados por el Gobierno de Canarias, los cabildos insulares,
y el Instituto Canario de Estadística (ISTAC).

### API — bajo investigación

No se ha confirmado aún la URL exacta de la API REST. Posibles candidatos:

| Ruta | Estado |
|------|--------|
| `https://datos.canarias.es/api/` | 404 — no existe |
| `https://datos.canarias.es/api/v1/` | 404 — no existe |
| `https://datos.canarias.es/api/action/` | 404 — no existe |
| `https://datos.canarias.es/catalogo/api/` | Por verificar |

**Alternativa**: el ISTAC publica datos abiertos en su propio portal:
`https://www.gobiernodecanarias.org/istac/`. ISTAC expone datos a través de
PXWeb y API estadística.

## Comandos

| Comando | Descripción |
|---------|-------------|
| `dataset list` | Lista datasets del catálogo (por determinar) |
| `search <q>` | Búsqueda textual en el catálogo |
| `istac <tema>` | Consultar datos del ISTAC |
| `org list` | Lista organizaciones publicadoras |

## Parámetros

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `--limit` | int | Nº de resultados |
| `--source` | string | Fuente: `datos.canarias.es` (default) o `istac` |

## Ejemplos prácticos

### 1. Consultar datos del ISTAC (PXWeb API)

```python
import requests

# ISTAC tiene datos a través de PXWeb (PX-XML/JSON)
# URL base del ISTAC (confirmada)
istac_base = "https://www.gobiernodecanarias.org/istac/api/"

# Ejemplo: consulta de indicadores disponibles
r = requests.get(f"{istac_base}indicators", timeout=15)
if r.status_code == 200:
    print("ISTAC API disponible")
else:
    print(f"ISTAC API devolvió {r.status_code}")
```

### 2. Navegar al portal web

```python
import requests
from bs4 import BeautifulSoup

# El portal carga su catálogo vía JS, pero podemos verificar disponibilidad
r = requests.get("https://datos.canarias.es", timeout=15)
print(f"Portal canario: {r.status_code} — {'disponible' if r.status_code == 200 else 'no disponible'}")
```

## Notas técnicas

- **API**: **pendiente de confirmar** — la URL oficial de la API REST del portal
  `datos.canarias.es` no se ha localizado aún. Usar `--source istac` para datos
  del Instituto Canario de Estadística.
- **ISTAC API**: `https://www.gobiernodecanarias.org/istac/api/` — expone indicadores
  estadísticos, población, economía, turismo, medio ambiente. Formato JSON/XML.
- **Portal**: el web `datos.canarias.es` carga vía JavaScript (`Cargando conjuntos de datos…`),
  probablemente desde un endpoint no documentado públicamente.
- **Rate limiting**: aplicar cortesía de 1s entre requests.
- **Timeout**: 15s por defecto.