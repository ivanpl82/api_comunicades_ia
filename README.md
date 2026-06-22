# api_comunicades_ia

Repositorio de skills OpenCode para acceder a los portales de datos abiertos de las comunidades autónomas de España.

Cubre **17 comunidades autónomas + Ceuta + Melilla** (19 portales/ubicaciones), clasificados por estado y tipo de plataforma.

## Cobertura

### CKAN — Portal con CKAN v3 ✅

| Comunidad | Portal | Skill | Estado |
|-----------|--------|-------|--------|
| Andalucía | `juntadeandalucia.es/datosabiertos/portal` | `skill-ckan-andalucia.md` | ✅ Operativo |
| Aragón | `opendata.aragon.es` (ruta `/ckan/api/3/action`) | `skill-ckan-aragon.md` | ✅ Operativo |
| Castilla-La Mancha | `datosabiertos.castillalamancha.es` | `skill-ckan-castillalamancha.md` | ✅ Operativo |
| Comunidad de Madrid | `datos.comunidad.madrid` | `skill-ckan-madrid.md` | ✅ Operativo |
| Comunidad Valenciana | `dadesobertes.gva.es` | `skill-ckan-valencia.md` | ✅ Operativo |
| Navarra | `datos.navarra.es` | `skill-ckan-navarra.md` | ✅ Operativo |
| Región de Murcia | `datosabiertos.regiondemurcia.es` | `skill-ckan-murcia.md` | ✅ Operativo |

Todos los skills CKAN heredan de `skill-ckan-base.md` (plantilla compartida con api_path configurable).

### Standalone — API propia ✅

| Comunidad | Portal | API | Skill | Estado |
|-----------|--------|-----|-------|--------|
| Cataluña | `analisi.transparenciacatalunya.cat` | Socrata SODA | `skill-cataluna.md` | ✅ Operativo |
| Euskadi | `api.euskadi.eus` | SPARQL + REST | `skill-euskadi.md` | ✅ Operativo |

### Standalone — Pendiente de investigación ⚠️

| Comunidad | Portal | Skill | Estado |
|-----------|--------|-------|--------|
| Canarias | `datos.canarias.es` | `skill-canarias.md` | ⚠️ Plataforma custom — API pública no confirmada |
| Castilla y León | `datosabiertos.jcyl.es` | `skill-castillayleon.md` | ⚠️ Portal institucional — API REST no encontrada |
| Illes Balears | `catalegdades.caib.cat` | `skill-baleares.md` | ⚠️ 14.724+ datasets; tipo de plataforma no determinado |

### Stub — Error de transporte ⚠️

| Comunidad | Portal | Skill | Estado |
|-----------|--------|-------|--------|
| Asturias | `datos.asturias.es` | `skill-asturias.md` | ⚠️ Portal no responde (error de transporte) |
| Cantabria | `datos.cantabria.es` | `skill-cantabria.md` | ⚠️ Portal no responde (error de transporte) |
| Extremadura | `datosabiertos.juntaex.es` | `skill-extremadura.md` | ⚠️ Portal no responde (error de transporte) |
| Galicia | `datos.xunta.gal` | `skill-galicia.md` | ⚠️ Portal no responde (error de transporte) |
| La Rioja | `larioja.org/datos-abiertos` | `skill-la-rioja.md` | ⚠️ Portal no responde (error de transporte) |

### Stub — Sin portal ❌

| Comunidad | Skill | Estado |
|-----------|-------|--------|
| Ceuta | `skill-ceuta.md` | ❌ No se ha encontrado portal de datos abiertos |
| Melilla | `skill-melilla.md` | ❌ No se ha encontrado portal de datos abiertos |

## Instalación

```bash
bash scripts/install-comunidades-ai.sh
```

### Flags

| Flag | Efecto |
|------|--------|
| `--dry-run` | Simula la instalación sin copiar archivos |
| `--force` | Sobrescribe skills existentes sin preguntar |
| `--verbose` | Muestra cada operación de archivo |
| `--check` | Tras instalar, verifica que los portales responden |
| `-h, --help` | Muestra la ayuda completa |

Ejemplos:

```bash
# Vista previa
bash scripts/install-comunidades-ai.sh --dry-run

# Instalación completa con verificación de portales
bash scripts/install-comunidades-ai.sh --force --check

# Instalación detallada
bash scripts/install-comunidades-ai.sh --force --verbose
```

## Requisitos

- [OpenCode](https://opencode.ai/) instalado (crea `~/.config/opencode/skills/`)
- Bash (Linux, macOS, o WSL en Windows)
- `curl` (opcional, para `--check`)

## Estructura del proyecto

```
skills/
├── skill-ckan-base.md          ← Plantilla base CKAN v3
├── skill-ckan-{comunidad}.md   ← Skills CKAN por comunidad
├── skill-{comunidad}.md        ← Skills standalone (SPARQL, Socrata, custom)
├── skill-{comunidad}.md        ← Stubs (error de transporte / sin portal)
scripts/
└── install-comunidades-ai.sh   ← Instalador
```

## Nota sobre `--check`

El flag `--check` verifica la accesibilidad de los portales vía HTTP después de instalar los skills. No se ejecuta por defecto. Los stubs con error de transporte y sin portal emitirán advertencias, lo cual es el comportamiento esperado.

## Verificación de skills instalados

```bash
ls ~/.config/opencode/skills/skill-*.md | wc -l
# Debería mostrar 21 skills
```