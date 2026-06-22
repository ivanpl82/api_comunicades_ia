# comunas-ai-install — Instalador de skills CCAA

## Propósito

Un script bash que instala todas las skills de comunidades autónomas en
`~/.config/opencode/skills/` detectando el sistema operativo y validando
que los portales responden correctamente.

## Requisitos

### R1: Detección de SO

El script SHALL detectar el sistema operativo en tiempo de ejecución:
| SO | Comportamiento |
|----|----------------|
| Linux (incluye WSL) | Proceder normalmente |
| macOS | Proceder normalmente |
| Otro | Mostrar error y salir con código 1 |

#### Escenario: Linux detectado correctamente

- GIVEN el script se ejecuta en un sistema Linux o WSL
- WHEN se llama a `detect_os()`
- THEN devuelve `linux`

#### Escenario: macOS detectado correctamente

- GIVEN el script se ejecuta en macOS
- WHEN se llama a `detect_os()`
- THEN devuelve `macos`

#### Escenario: SO no soportado

- GIVEN el script se ejecuta en un SO no soportado (ej. Windows nativo sin WSL)
- WHEN se llama a `detect_os()`
- THEN muestra `Error: SO no soportado` y sale con código 1

### R2: Instalación en destino correcto

El script SHALL copiar los skills a `~/.config/opencode/skills/`. No SHALL
contener rutas absolutas hardcodeadas sensibles.

#### Escenario: Instalación exitosa

- GIVEN `~/.config/opencode/skills/` existe y es escribible
- WHEN se ejecuta el script sin flags
- THEN copia cada skill `.md` al directorio de destino
- AND muestra resumen de archivos instalados

#### Escenario: Directorio destino no existe

- GIVEN `~/.config/opencode/skills/` no existe
- WHEN se ejecuta el script sin `--force`
- THEN muestra `Error: ~/.config/opencode/skills/ no encontrado`
- AND sugiere instalar OpenCode primero
- AND sale con código 1

### R3: Flags del instalador

El script SHALL soportar estos flags:

| Flag | Efecto |
|------|--------|
| `--dry-run` | Simula la instalación sin copiar archivos |
| `--force` | Crea el directorio destino si no existe |
| `--verbose` | Muestra cada acción en detalle |
| `--check` | Verifica instalación previa (no instala) |

#### Escenario: `--dry-run` simula sin copiar

- GIVEN el script se ejecuta con `--dry-run`
- WHEN recorre todos los skills
- THEN imprime lo que haría pero NO copia ningún archivo
- AND sale con código 0

#### Escenario: `--force` crea el directorio destino

- GIVEN `~/.config/opencode/skills/` no existe
- WHEN se ejecuta el script con `--force`
- THEN crea el directorio destino
- AND procede con la instalación normal

#### Escenario: `--verbose` muestra acciones detalladas

- GIVEN el script se ejecuta con `--verbose`
- WHEN copia cada skill
- THEN imprime `[COPY] skill-xyz.md → ~/.config/opencode/skills/skill-xyz.md`

### R4: Verificación con `--check`

El script SHALL verificar la instalación existente con `--check`:
- Comprobar que cada skill `.md` existe en destino
- Comprobar que `opencode.json` (o `~/.config/opencode/`) existe

#### Escenario: Todo instalado correctamente

- GIVEN todos los skills están en `~/.config/opencode/skills/`
- AND `opencode.json` existe
- WHEN se ejecuta `instalar-comunidades-ai.sh --check`
- THEN muestra `✓ Todos los skills instalados correctamente (N/N)`
- AND sale con código 0

#### Escenario: Falta algún skill

- GIVEN faltan 2 skills en el directorio destino
- WHEN se ejecuta `instalar-comunidades-ai.sh --check`
- THEN muestra `✗ Faltan 2 skills: skill-foo.md, skill-bar.md`
- AND sale con código 1

### R5: Sin rutas hardcodeadas sensibles

El script SHALL derivar la ruta destino de `$HOME` o `~`. No SHALL
contener `/home/usuario` ni rutas absolutas de entornos de desarrollo.

#### Escenario: Ruta derivada de $HOME

- GIVEN el script usa `$HOME/.config/opencode/skills/`
- WHEN se inspecciona el código fuente
- THEN no contiene ninguna ruta absoluta que no use `$HOME` o `~`
