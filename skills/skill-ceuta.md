---
name: ceuta
description: "CLI para datos abiertos de Ceuta — portal no disponible (sin portal de datos abiertos). Trigger: datos de Ceuta, datos abiertos ceuta, ceuta opendata, ceuta datasets."
license: MIT
metadata:
  author: comunidad OpenCode
  version: "0.1.0"
  api_base: ""
  api_type: stub
  api_status: no_portal
  last_checked: "2026-06-22"
---

# SKILL: ceuta — Datos Abiertos de Ceuta (stub — sin portal)

## Metadata

- **name**: `ceuta`
- **version**: `0.1.0`
- **author**: comunidad OpenCode
- **api_base**: No disponible
- **api_type**: stub — sin portal de datos abiertos
- **api_status**: `no_portal` — no se ha encontrado un portal de datos abiertos
- **last_checked**: `2026-06-22`

## Trigger

Actívate cuando el usuario menciona:
- "datos de ceuta", "datos abiertos ceuta"
- "ceuta opendata", "ceuta datasets"
- "ciudad autónoma de ceuta datos"

## Situación actual

No se ha encontrado un portal de datos abiertos operativo para la Ciudad Autónoma
de Ceuta. No existe una URL confirmada de API ni portal web de datos abiertos.

| Aspecto | Estado |
|---------|--------|
| Portal web | No detectado |
| API REST | No disponible |
| Última verificación | 2026-06-22 |
| Estado | `no_portal` |

### URLs investigadas

| URL | Resultado |
|-----|-----------|
| `https://www.ceuta.es` | Portal institucional — sin sección de datos abiertos |
| `https://datos.ceuta.es` | No resuelve |

## ⚠️ Hard Rule

- **NO realizar llamadas HTTP a portales de datos de Ceuta**.
- No hay API ni portal de datos abiertos confirmado para esta comunidad.
- Este skill es un stub informativo.

## Notas técnicas

- **Estado**: `no_portal` — no se ha identificado un portal de datos abiertos
  para Ceuta en ninguna de las URLs investigadas.
- **Recomendación**: si en el futuro aparece un portal, crear un skill funcional
  basado en la plataforma que utilice (CKAN, Socrata, custom, etc.).
- **Próxima verificación**: revisar periódicamente si la Ciudad Autónoma de Ceuta
  ha puesto en marcha un portal de datos abiertos.