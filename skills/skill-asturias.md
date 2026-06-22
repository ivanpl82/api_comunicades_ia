---
name: asturias
description: "CLI para el portal de datos abiertos del Principado de Asturias — portal no disponible (error de transporte). Trigger: datos de Asturias, datos abiertos asturias, Asturias opendata, asturias datasets, datos del principado."
license: MIT
metadata:
  author: comunidad OpenCode
  version: "0.1.0"
  api_base: "https://datos.asturias.es"
  api_type: stub
  api_status: transport_error
  investigation_url: "https://datos.asturias.es"
  last_checked: "2026-06-22"
---

# SKILL: asturias — Portal de Datos Abiertos del Principado de Asturias (stub — error de transporte)

## Metadata

- **name**: `asturias`
- **version**: `0.1.0`
- **author**: comunidad OpenCode
- **api_base**: `https://datos.asturias.es`
- **api_type**: stub — error de transporte
- **api_status**: `transport_error` — el portal CKAN se detecta pero no responde de forma fiable
- **investigation_url**: `https://datos.asturias.es`
- **last_checked**: `2026-06-22`

## Trigger

Actívate cuando el usuario menciona:
- "datos de asturias", "datos abiertos asturias"
- "asturias opendata", "datos del principado de asturias"
- "datos.asturias.es"
- "datasets asturias"

## Situación actual

El portal de Datos Abiertos del Principado de Asturias está alojado en
`https://datos.asturias.es`. Utiliza una plataforma CKAN, pero actualmente
presenta errores de transporte que impiden el acceso fiable a la API.

| Aspecto | Estado |
|---------|--------|
| Portal web | Detectado — CKAN |
| API REST | No responde de forma fiable |
| Última verificación | 2026-06-22 |
| Estado | `transport_error` |

### URL investigada

```
https://datos.asturias.es
```

Se ha identificado el portal como una instalación CKAN, pero las peticiones a la API
no responden consistentemente. No se proporcionan comandos ni ejemplos de código
hasta que el servicio恢复正常 (se restablezca).

## ⚠️ Hard Rule

- **NO realizar llamadas HTTP reales a `https://datos.asturias.es`**.
- Este skill es un stub informativo hasta que se confirme que la API responde.

## Notas técnicas

- **Estado**: `transport_error` — el portal CKAN existe pero no es accesible
  de forma fiable desde esta ubicación.
- **Recomendación**: al confirmar que la API responde, migrar este stub a un skill
  funcional basado en `ckan-base.md`.
- **Próxima verificación**: programar reintento periódico contra
  `https://datos.asturias.es/api/3/action/package_list`.