# comunas-ai-stubs — Skills stub para comunidades no disponibles

## Propósito

Proveer stubs informativos para comunidades donde el portal de datos
abiertos no está disponible o no existe. El stub explica el estado actual
y no realiza llamadas API reales.

## Requisitos

### R1: Cobertura de stubs

El sistema SHALL incluir stubs para estas comunidades:

| Comunidad | Estado | Razón |
|-----------|--------|-------|
| Ceuta | Sin portal | No se encontró portal de datos abiertos |
| Melilla | Sin portal | No se encontró portal de datos abiertos |
| Asturias | Error de transporte | Portal `opendata.asturias.es` no responde |
| Cantabria | Error de transporte | Portal `datos.cantabria.es` no responde |
| Extremadura | Error de transporte | Portal `datosabiertos.juntaex.es` no responde |
| Galicia | Error de transporte | Portal `datosabertos.xunta.gal` no responde |
| La Rioja | Error de transporte | Portal `datosabiertos.larioja.org` no responde |

### R2: Mensaje informativo

Cada stub SHALL mostrar al menos:
- Nombre de la comunidad
- Estado actual del portal
- URL investigada
- Fecha de última verificación
- Sugerencia de acción (revisitar, buscar alternativa)

#### Escenario: Consultar Ceuta

- GIVEN el usuario invoca el stub de Ceuta
- WHEN se ejecuta cualquier comando (`dataset list`, `dataset get`)
- THEN muestra `Ceuta: No se encontró portal de datos abiertos (verificado: 2026-06-22)`
- AND no realiza ninguna petición HTTP
- AND sale con código 0

#### Escenario: Consultar Asturias (error transporte)

- GIVEN el usuario invoca el stub de Asturias
- WHEN se ejecuta `dataset list`
- THEN muestra `Asturias: El portal opendata.asturias.es no responde (error de transporte)`
- AND sugiere `Revisitar en: https://opendata.asturias.es`
- AND sale con código 0

### R3: Sin llamadas de red

Ningún stub SHALL realizar llamadas HTTP reales. Todo el comportamiento
es puramente informativo (mensaje + código de salida 0).

#### Escenario: Aislamiento de red

- GIVEN el stub de Melilla se ejecuta sin conexión a internet
- WHEN se ejecuta cualquier comando
- THEN muestra el mensaje informativo
- AND no lanza error por falta de red

### R4: Fecha de verificación

Cada stub SHALL incluir la fecha de última verificación en su metadato
y en el mensaje mostrado, para que el usuario sepa si el dato está
actualizado.

#### Escenario: Fecha visible

- GIVEN el stub de Galicia
- WHEN se muestra el mensaje
- THEN incluye `(verificado: 2026-06-22)`
