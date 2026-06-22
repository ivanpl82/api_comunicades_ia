# comunas-ai-skills-ckan — Plantilla base CKAN v3

## Propósito

Plantilla compartida para todas las comunidades que usan CKAN v3.
Cubre el ~80% común: endpoints, parámetros, formato de respuesta, paginación
y rate limiting. Cada comunidad solo define su `api_base` y `api_path`.

## Requisitos

### R1: Patrón API CKAN v3

El skill SHALL implementar estos endpoints CKAN v3 estándar:

| Endpoint | Propósito | Parámetros clave |
|----------|-----------|-----------------|
| `package_search` | Buscar datasets | `q`, `fq`, `rows`, `start` |
| `package_show` | Detalle de dataset | `id` |
| `organization_list` | Listar organizaciones | `all_fields` |
| `group_list` | Listar grupos | `all_fields` |
| `tag_list` | Listar etiquetas | `all_fields` |

#### Escenario: Buscar datasets por palabra clave

- GIVEN el usuario especifica `--q "agua" --rows 10`
- WHEN se llama a `package_search?q=agua&rows=10`
- THEN devuelve respuesta con `success: true` y `result.results` con ≤10 datasets

#### Escenario: Obtener detalle de dataset

- GIVEN el usuario especifica `--id "abc-123"`
- WHEN se llama a `package_show?id=abc-123`
- THEN devuelve `success: true` y `result` con el dataset completo

### R2: `api_path` configurable

El skill SHALL aceptar un `api_path` configurable. Algunas comunidades
(como Aragón) usan `/ckan/api/3/action` en lugar de `/api/3/action`.

| Comunidad | `api_path` |
|-----------|-----------|
| Andalucía, Madrid, Murcia, Navarra, Valencia, Castilla-La Mancha | `/api/3/action` |
| Aragón | `/ckan/api/3/action` |

#### Escenario: api_path estándar

- GIVEN `api_path = "/api/3/action"`
- WHEN se construye la URL para `package_search`
- THEN la URL resultante es `{api_base}/api/3/action/package_search`

#### Escenario: api_path no estándar (Aragón)

- GIVEN `api_path = "/ckan/api/3/action"`
- WHEN se construye la URL para `package_search`
- THEN la URL resultante es `{api_base}/ckan/api/3/action/package_search`
- AND la API responde correctamente con datos de Aragón

### R3: Parámetros comunes

El skill SHALL exponer estos parámetros en la línea de comandos:

| Parámetro | Endpoint | Descripción |
|-----------|----------|-------------|
| `--rows N` | package_search | Número de resultados (Default: 10, Máx: 100) |
| `--start N` | package_search | Offset para paginación |
| `--q "texto"` | package_search | Búsqueda textual |
| `--fq "filtro"` | package_search | Filtro de faceta |
| `--org "nombre"` | package_search | Filtrar por organización |
| `--group "nombre"` | package_search | Filtrar por grupo |
| `--id "uuid"` | package_show | ID del dataset |

#### Escenario: Paginación con rows + start

- GIVEN `--rows 5 --start 10`
- WHEN se llama a `package_search?rows=5&start=10`
- THEN devuelve resultados 11-15

#### Escenario: Filtrar por organización

- GIVEN `--org "consejeria-educacion"`
- WHEN se llama a `package_search?fq=organization:consejeria-educacion`
- THEN solo devuelve datasets de esa organización

### R4: Formato de respuesta

El skill SHALL validar el formato de respuesta CKAN:
- `success`: booleano (true/false)
- `result`: objeto con resultados
- `result.count`: total de resultados disponibles
- `result.results`: array de datasets

#### Escenario: Respuesta válida

- GIVEN la API responde con `{"success": true, "result": {"count": 42, "results": [...]}}`
- WHEN se procesa la respuesta
- THEN extrae y muestra `count` y `results` correctamente

#### Escenario: Error de API

- GIVEN la API responde con `{"success": false, "error": {"message": "..."}}`
- WHEN se procesa la respuesta
- THEN muestra el mensaje de error
- AND sale con código 1

### R5: Rate limiting

El skill SHALL respetar un intervalo de 0.2s entre peticiones a la
misma comunidad (5 peticiones/segundo máximo).

#### Escenario: Respeto del rate limit

- GIVEN el usuario hace 3 peticiones seguidas
- WHEN se ejecutan
- THEN cada petición espera ≥200ms desde la anterior
