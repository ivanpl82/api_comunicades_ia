# Propuesta: api-comunidades-ai

## Intención

Unificar todas las comunidades autónomas españolas (17 CCAA + Ceuta + Melilla) en skills OpenCode
para que cualquier agente pueda consultar datos abiertos de cualquier portal regional.
Actualmente solo existe `skill-junta-andalucia.md` — el proyecto cubre 1 de 19+ portales.

## Alcance

### Dentro del alcance
- **9+ skills CKAN** (Andalucía, Aragón, Castilla-La Mancha, Madrid, Murcia, Navarra, C. Valenciana,
  los que reaparezcan de error de transporte) — base compartida `skill-ckan-base.md` + config/community
- **4 skills standalone** (Euskadi/SPARQL, Cataluña/Socrata, Canarias, Castilla y León)
- **Skill instalador**: `skill-instalador-comunidades-ai.md` — script bash `instalar-comunidades-ai.sh`
  con `detect_os()`, `install_skills()`, `verify()`
- **Stubs** para comunidades sin portal (Ceuta, Melilla) o con error de transporte pendiente
- **Actualización**: `.atl/skill-registry.md`, `README.md`

### Fuera del alcance
- Autoupdate de skills (actualización automática de URLs)
- CI/CD de validación de skills
- Soporte de comunidades no españolas (datos.gob.es internacional)
- Migración de datos entre skills (mover datos entre portales)

## Capacidades

> Esta sección es el CONTRATO entre proposal y specs.
> `openspec/specs/` está vacío — todas las capacidades son nuevas.

### Nuevas capacidades
- `comunidades-ai-install`: instalador bash con detección de SO, `~/.config/opencode/skills/`, `--dry-run` y `--force`
- `comunidades-ai-ckan-base`: plantilla base CKAN v3 (endpoints, paginación, parámetros, formato de respuesta, ejemplos Python)
- `comunidades-ai-ckan-andalucia`: skill de Andalucía (ya existe, se migra)
- `comunidades-ai-ckan-aragon`: skill de Aragón (ruta no estándar `/ckan/api/3/action`)
- `comunidades-ai-ckan-castillalamancha`: Castilla-La Mancha (200+ datasets)
- `comunidades-ai-ckan-madrid`: Madrid
- `comunidades-ai-ckan-murcia`: Murcia
- `comunidades-ai-ckan-navarra`: Navarra
- `comunidades-ai-ckan-valencia`: C. Valenciana
- `comunidades-ai-skill-euskadi`: País Vasco — SPARQL + REST API
- `comunidades-ai-skill-cataluna`: Cataluña — Socrata API
- `comunidades-ai-skill-canarias`: Canarias — plataforma personalizada
- `comunidades-ai-skill-castillayleon`: Castilla y León — plataforma personalizada
- `comunidades-ai-stub-asturias`: Asturias — error de transporte, pendiente de reverificación
- `comunidades-ai-stub-cantabria`: Cantabria — error de transporte
- `comunidades-ai-stub-extremadura`: Extremadura — error de transporte
- `comunidades-ai-stub-galicia`: Galicia — error de transporte
- `comunidades-ai-stub-larioja`: La Rioja — error de transporte
- `comunidades-ai-stub-baleares`: Baleares — plataforma CKAN desconocida
- `comunidades-ai-stub-ceuta`: Ceuta — sin portal detectable
- `comunidades-ai-stub-melilla`: Melilla — sin portal detectable

### Capacidades modificadas
- Ninguna — todo el trabajo es nuevo. `skill-junta-andalucia.md` se migra a `comunidades-ai-ckan-andalucia`
  (se renombra y refactoriza contra la plantilla base).

## Enfoque

**Híbrido**: plantilla CKAN base compartida (`skill-ckan-base.md`) + archivos de configuración
por comunidad. Las comunidades CKAN heredan una plantilla común con endpoints, paginación,
formato `{success, result, help}` y ejemplos Python. Las comunidades no-CKAN (Euskadi,
Cataluña, Canarias, Castilla y León) obtienen skills independientes con su propia API y
formato de datos.

Instalador: un solo script bash con:
1. `detect_os()` → Linux (incluye WSL), macOS
2. `install_skills()` → copia cada skill a `~/.config/opencode/skills/`
3. `verify()` → comprueba que cada URL base responde con JSON válido (`curl -s -f`)

## Áreas afectadas

| Área | Impacto | Descripción |
|------|---------|-------------|
| `skills/` | Nuevos (17+) | 1 skill base CKAN + 9 configs comunidad + 4 standalone + 5 stubs + 1 instalador |
| `.atl/skill-registry.md` | Modificado | Se actualiza el registro para indexar todas las nuevas skills |
| `README.md` | Modificado | Se actualiza para reflejar cobertura real (de «solo Andalucía» a «todas las CCAA») |
| `openspec/specs/` | Nuevo | Se necesitan specs para instalador, plantilla CKAN y cada API no estándar |

## Riesgos

| Riesgo | Probabilidad | Mitigación |
|--------|-------------|------------|
| 2 CCAA sin portal (Ceuta, Melilla) | Alta | Stub con «no disponible» — no bloquear el resto |
| 5 errores de transporte (caídas temporales) | Media | Stub con nota de «pendiente de reverificación» + re-comprobación en spec |
| Aragón ruta no estándar `/ckan/api/3/action` | Alta (confirmado) | Parámetro `api_path` en la plantilla base |
| URLs de portal cambian | Baja | Incluir fecha de verificación en metadatos del skill |

## Plan de reversión

```bash
rm -rf ~/.config/opencode/skills/skill-*-comunidades-ai*
# Si el instalador falló: rm -rf ~/.config/opencode/skills/
# README: git checkout -- README.md
```

## Dependencias

Ninguna externa. El instalador necesita `curl`, `bash` y `~/.config/opencode/skills/`
(directorio que existe tras instalar OpenCode).

## Criterios de éxito

- [ ] Cada URL base de portal responde con HTTP 200 + JSON válido
- [ ] Instalador `install-comunidades-ai.sh` completa en Linux y macOS sin errores
- [ ] `skill-ckan-base.md` + cualquier config de comunidad son invocables por separado

## Ronda de preguntas de propuesta

Antes de pasar a la fase de specs, estas preguntas ayudarían a aclarar
requisitos de producto y alcance:

1. **Organización de archivos skill**: ¿prefieres un archivo `.md` por cada CCAA,
   o agrupar por tecnología (CKAN / Socrata / SPARQL / stubs) en subdirectorios?
2. **Modos del instalador**: ¿`--verbose` (muestra cada acción), `--dry-run` (solo
   simula), `--force` (sobrescribe si ya existe)?
3. **Comprobación de red**: ¿debería el instalador comprobar `curl -s <portal>/api/3`
   antes de instalar, o asumir que el usuario ya sabe que los portales están vivos?

### Asunciones de propuesta (para que el usuario confirme o corrija)

- 9 comunidades CKAN comparten una plantilla base con `api_path` configurable
- Las 2 sin portal (Ceuta, Melilla) reciben un stub informativo
- Los 5 errores de transporte se marcan como «pendiente de verificación» en spec
- No se necesita CI/CD ni autoupdate en esta iteración