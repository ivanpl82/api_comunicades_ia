---
name: extremadura
description: "CLI para el portal de datos abiertos de Extremadura — portal no disponible (error de transporte). Trigger: datos de Extremadura, datos abiertos extremadura, junta de extremadura datos, extremeños opendata, datasets extremadura."
license: MIT
metadata:
  author: comunidad OpenCode
  version: "0.1.0"
  api_base: "https://datosabiertos.juntaex.es"
  api_type: stub
  api_status: transport_error
  investigation_url: "https://datosabiertos.juntaex.es"
  last_checked: "2026-06-22"
---

# SKILL: extremadura — Portal de Datos Abiertos de Extremadura (stub — error de transporte)

## Metadata

- **name**: `extremadura`
- **version**: `0.1.0`
- **author**: comunidad OpenCode
- **api_base**: `https://datosabiertos.juntaex.es`
- **api_type**: stub — error de transporte
- **api_status**: `transport_error` — el portal CKAN se detecta pero no responde de forma fiable
- **investigation_url**: `https://datosabiertos.juntaex.es`
- **last_checked**: `2026-06-22`

## Trigger

Actívate cuando el usuario menciona:
- "datos de extremadura", "datos abiertos extremadura"
- "junta de extremadura datos", "extremeños datos abiertos"
- "datosabiertos.juntaex.es"
- "datasets extremadura"

## Situación actual

El portal de Datos Abiertos de Extremadura está alojado en
`https://datosabiertos.juntaex.es`. Utiliza una plataforma CKAN, pero actualmente
presenta errores de transporte que impiden el acceso fiable a la API.

| Aspecto | Estado |
|---------|--------|
| Portal web | Detectado — CKAN |
| API REST | No responde de forma fiable |
| Última verificación | 2026-06-22 |
| Estado | `transport_error` |

### URL investigada

```
https://datosabiertos.juntaex.es
```

Se ha identificado el portal como una instalación CKAN, pero las peticiones a la API
no responden consistentemente. No se proporcionan comandos ni ejemplos de código
hasta que el servicio se restablezca.

## ⚠️ Hard Rule

- **NO realizar llamadas HTTP reales a `https://datosabiertos.juntaex.es`**.
- Este skill es un stub informativo hasta que se confirme que la API responde.

## Notas técnicas

- **Estado**: `transport_error` — el portal CKAN existe pero no es accesible
  de forma fiable desde esta ubicación.
- **Recomendación**: al confirmar que la API responde, migrar este stub a un skill
  funcional basado en `ckan-base.md`.
- **Próxima verificación**: programar reintento periódico contra
  `https://datosabiertos.juntaex.es/api/3/action/package_list`.