---
name: castillayleon
description: "CLI para el portal de datos abiertos de Castilla y León. Trigger: datos de Castilla y León, datos abiertos cyl, jcyl datos, datasets castilla y león."
license: MIT
metadata:
  author: comunidad OpenCode
  version: "1.0.0"
  api_base: "https://datosabiertos.jcyl.es"
  api_type: custom
  api_status: unknown
  investigation_url: "https://datosabiertos.jcyl.es/web/es/datos-abiertos/catalogo.html"
  last_checked: "2026-06-22"
---

# SKILL: castillayleon — Portal de Datos Abiertos de Castilla y León (plataforma custom)

## Metadata

- **name**: `castillayleon`
- **version**: `1.0.0`
- **author**: comunidad OpenCode
- **api_base**: `https://datosabiertos.jcyl.es`
- **api_type**: plataforma institucional custom (CKAN-like)
- **api_status**: `unknown` — el catálogo se sirve como portal web sin API REST
  pública documentada confirmada.
- **investigation_url**: `https://datosabiertos.jcyl.es/web/es/datos-abiertos/`
- **last_checked**: `2026-06-22`

## Trigger

Actívate cuando el usuario menciona:
- "datos de castilla y león", "datos abiertos castilla y león"
- "datos cyl", "datos de la junta de castilla y león"
- "datosabiertos.jcyl.es", "jcyl datos abiertos"
- "datasets cyl", "castilla y león opendata"
- "IDECyL" (infraestructura de datos espaciales de CyL)

## API Base

```
https://datosabiertos.jcyl.es
```

El portal de Datos Abiertos de Castilla y León es una plataforma institucional
personalizada desarrollada por la Junta de Castilla y León. No es CKAN estándar.
Incluye datasets de múltiples consejerías y organismos públicos de CyL.

### API — bajo investigación

No se ha encontrado una API REST pública documentada. Posibles alternativas:

| Recurso | URL | Estado |
|---------|-----|--------|
| Catálogo web | `https://datosabiertos.jcyl.es/web/es/datos-abiertos/` | ✅ Disponible |
| API REST | `https://datosabiertos.jcyl.es/api/` | `404` — no existe |
| API REST v1 | `https://datosabiertos.jcyl.es/api/v1/` | Por verificar |
| IDECyL | `https://idecyl.jcyl.es` | Infraestructura de datos espaciales |
| Buscador | `https://datosabiertos.jcyl.es/web/es/datos-abiertos/buscador-conjuntos-datos.html` | Disponible (web) |

## Comandos

| Comando | Descripción |
|---------|-------------|
| `dataset list` | Lista datasets (por determinar) |
| `search <q>` | Búsqueda textual en el catálogo |
| `idecyl <capa>` | Consultar capas de IDECyL |
| `org list` | Lista organizaciones publicadoras |

## Parámetros

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `--limit` | int | Nº de resultados |
| `--source` | string | Fuente: `datosabiertos.jcyl.es` (default) o `idecyl` |

## Ejemplos prácticos

### 1. Verificar disponibilidad del portal

```python
import requests

r = requests.get("https://datosabiertos.jcyl.es/web/es/datos-abiertos/", timeout=15)
print(f"Portal CyL: {r.status_code} — {'disponible' if r.status_code == 200 else 'no disponible'}")
```

### 2. Consultar IDECyL (datos geoespaciales)

```python
import requests

# IDECyL — infraestructura de datos espaciales (WMS/WFS)
idecyl_base = "https://idecyl.jcyl.es/geoserver/wfs"
params = {
    "service": "WFS",
    "version": "2.0.0",
    "request": "GetCapabilities"
}

r = requests.get(idecyl_base, params=params, timeout=30)
if r.status_code == 200:
    print("IDECyL WFS disponible")
else:
    print(f"IDECyL devolvió {r.status_code}")
```

## Notas técnicas

- **API**: **pendiente de confirmar** — el portal `datosabiertos.jcyl.es` es un portal
  web institucional. No se ha confirmado API REST pública. Usar scraping web
  o el buscador integrado como alternativa.
- **IDECyL**: `https://idecyl.jcyl.es` — infraestructura de datos espaciales con
  servicios WMS/WFS para capas geoespaciales de Castilla y León.
- **Buscador web**: `https://datosabiertos.jcyl.es/web/es/datos-abiertos/buscador-conjuntos-datos.html`
  permite buscar datasets por texto, categoría y formato.
- **Formatos disponibles**: CSV, JSON, XML, GeoJSON, entre otros.
- **Temáticas**: medio ambiente, educación, sanidad, economía, empleo, turismo,
  servicios sociales, vivienda, infraestructuras.
- **Nota**: si se descubre la URL exacta de la API REST, actualizar `api_path`
  y comandos de consulta directa.