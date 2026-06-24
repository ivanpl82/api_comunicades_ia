#!/usr/bin/env bash
#
# install-comunidades-ai.sh — Instalador de skills de comunidades autónomas
#
# Copia los skills de datos abiertos de comunidades autónomas españolas
# al directorio de skills de OpenCode.
#
# Uso:
#   ./install-comunidades-ai.sh [opciones]
#
# Opciones:
#   --dry-run   Muestra qué se copiaría sin hacer cambios
#   --force     Sobrescribe sin preguntar
#   --verbose   Traza cada operación de archivo
#   --check     Verifica la accesibilidad de los portales tras instalar
#   -h, --help  Muestra esta ayuda

set -euo pipefail

# ──────────────────────────────────────────────
# Constants
# ──────────────────────────────────────────────

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../skills" && pwd)"
OPENCODE_SKILLS="${HOME}/.config/opencode/skills"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

# Flags
DRY_RUN=false
FORCE=false
VERBOSE=false
CHECK=false

# ──────────────────────────────────────────────
# Funciones auxiliares
# ──────────────────────────────────────────────

log() {
    if [[ "$VERBOSE" == true ]]; then
        echo "[${SCRIPT_NAME}] $*"
    fi
}

info() {
    echo "[${SCRIPT_NAME}] $*"
}

warn() {
    echo "[${SCRIPT_NAME}] ⚠️  $*" >&2
}

error() {
    echo "[${SCRIPT_NAME}] ❌ $*" >&2
    exit 1
}

usage() {
    cat <<EOF
Uso: ${SCRIPT_NAME} [opciones]

Instala los skills de datos abiertos de comunidades autónomas en
OpenCode.

Opciones:
  --dry-run   Muestra qué se copiaría sin hacer cambios
  --force     Sobrescribe sin preguntar
  --verbose   Traza cada operación de archivo
  --check     Verifica accesibilidad de portales tras instalar
  -h, --help  Muestra esta ayuda

Ejemplos:
  ${SCRIPT_NAME} --dry-run                # Vista previa
  ${SCRIPT_NAME} --force                  # Instalación completa
  ${SCRIPT_NAME} --force --check          # Instalar y verificar portales
  ${SCRIPT_NAME} --force --verbose        # Instalación detallada
EOF
    exit 0
}

# ──────────────────────────────────────────────
# detect_os — Detecta el sistema operativo
# ──────────────────────────────────────────────
detect_os() {
    local os

    case "$(uname -s)" in
        Linux*)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                os="wsl"
            else
                os="linux"
            fi
            ;;
        Darwin*)
            os="darwin"
            ;;
        *)
            os="unknown"
            ;;
    esac

    echo "$os"
}

# ──────────────────────────────────────────────
# verify_frontmatter — Valida frontmatter YAML básico
# ──────────────────────────────────────────────
verify_frontmatter() {
    local file="$1"
    local errors=0

    # Verificar que empieza con ---
    if ! head -1 "$file" | grep -q '^---$'; then
        warn "Frontmatter faltante: $file — no comienza con ---"
        return 1
    fi

    # Verificar que tiene name:
    if ! grep -q '^name:' "$file"; then
        warn "Campo 'name' faltante en: $file"
        errors=$((errors + 1))
    fi

    # Verificar que tiene description:
    if ! grep -q '^description:' "$file"; then
        warn "Campo 'description' faltante en: $file"
        errors=$((errors + 1))
    fi

    # Verificar que tiene license:
    if ! grep -q '^license:' "$file"; then
        warn "Campo 'license' faltante en: $file"
        errors=$((errors + 1))
    fi

    # Verificar que cierra el frontmatter
    if ! grep -q '^---' <(tail -n +2 "$file" | head -c 4096); then
        warn "Frontmatter sin cierre (segundo ---) en: $file"
        errors=$((errors + 1))
    fi

    return "$errors"
}

# ──────────────────────────────────────────────
# check_portal — Verifica accesibilidad de una URL
# ──────────────────────────────────────────────
check_portal() {
    local name="$1"
    local url="$2"

    if [[ -z "$url" ]]; then
        echo "   [${name}] Sin URL configurada — omitiendo"
        return 0
    fi

    if command -v curl &>/dev/null; then
        local code
        code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 --max-time 15 "$url" 2>/dev/null || echo "000")
        if [[ "$code" != "000" ]]; then
            echo "   [${name}] HTTP ${code} — $([ "$code" -lt 400 ] && echo "accesible" || echo "error")"
        else
            echo "   [${name}] ⚠️  No responde (timeout o error de red)"
        fi
    elif command -v wget &>/dev/null; then
        if wget --spider --timeout=10 --tries=1 "$url" 2>/dev/null; then
            echo "   [${name}] Accesible"
        else
            echo "   [${name}] ⚠️  No responde"
        fi
    else
        warn "Ni curl ni wget disponibles — no se puede verificar accesibilidad"
        return 1
    fi
}

# ──────────────────────────────────────────────
# extract_skill_name — Extrae el campo 'name' del frontmatter YAML
# ──────────────────────────────────────────────
extract_skill_name() {
    local file="$1"
    # Lee línea por línea entre los --- y devuelve el valor de 'name:'
    while IFS= read -r line; do
        if [[ "$line" =~ ^name:[[:space:]]*(.+) ]]; then
            echo "${BASH_REMATCH[1]}" | tr -d "\"' "
            return 0
        fi
        if [[ "$line" =~ ^\.\.\.$ || "$line" =~ ^---$ ]]; then
            # Segundo --- o ... → fin del frontmatter, no encontramos name
            break
        fi
    done < <(tail -n +2 "$file")  # saltar el primer ---
    return 1
}

# ──────────────────────────────────────────────
# check_portals — Verifica portales según metadatos
# ──────────────────────────────────────────────
check_portals() {
    echo ""
    echo "── Verificación de portales ──"
    echo ""

    local found=0
    local checked=0

    while IFS= read -r -d '' skill_file; do
        found=$((found + 1))

        # Extraer metadatos del frontmatter
        local skill_name skill_status skill_url
        skill_name=$(grep -E '^name:' "$skill_file" | head -1 | sed 's/^name:[[:space:]]*//' | tr -d "\"'")
        skill_status=$(grep -E 'api_status:' "$skill_file" | head -1 | sed 's/.*api_status:[[:space:]]*//' | tr -d "\" ")

        # Extraer api_base
        skill_url=$(grep -E '^[[:space:]]*api_base:' "$skill_file" | head -1 | sed 's/.*api_base:[[:space:]]*//' | tr -d "\" ")

        # Si api_base está vacía o es un placeholder, probar investigation_url
        if [[ -z "$skill_url" || "$skill_url" == "<url_base>" ]]; then
            skill_url=$(grep -E 'investigation_url:' "$skill_file" | head -1 | sed 's/.*investigation_url:[[:space:]]*//' | tr -d "\" ")
        fi

        if [[ -z "$skill_status" ]]; then
            skill_status="desconocido"
        fi

        echo "  [${skill_name}] (${skill_status})"
        if [[ -n "$skill_url" && "$skill_url" != "<url_base>" ]]; then
            check_portal "$skill_name" "$skill_url"
            checked=$((checked + 1))
        else
            echo "   [${skill_name}] Sin URL de portal"
        fi
    done < <(find "$OPENCODE_SKILLS" -maxdepth 2 -name 'SKILL.md' -print0 | sort -z)

    echo ""
    echo "Skills encontrados: ${found} | Portales verificados: ${checked}"
}

# ──────────────────────────────────────────────
# install_skills — Copia skills al directorio de OpenCode
# ──────────────────────────────────────────────
install_skills() {
    local os
    os=$(detect_os)

    echo "── Instalación de skills api-comunidades-ai ──"
    echo ""
    echo "  Sistema detectado: ${os} ($([ "$os" == "wsl" ] && echo "tratado como Linux" || echo "$os"))"
    echo "  Origen:  ${SKILL_DIR}"
    echo "  Destino: ${OPENCODE_SKILLS}"
    echo ""

    # Verificar que el directorio origen existe
    if [[ ! -d "$SKILL_DIR" ]]; then
        error "Directorio de origen no encontrado: ${SKILL_DIR}"
    fi

    # Recopilar archivos a copiar
    local files=()
    while IFS= read -r -d '' f; do
        files+=("$f")
    done < <(find "$SKILL_DIR" -maxdepth 1 -name 'skill-*.md' -print0 | sort -z)

    if [[ ${#files[@]} -eq 0 ]]; then
        error "No se encontraron skills (skill-*.md) en ${SKILL_DIR}"
    fi

    # Filtrar skills plantilla (api_base con placeholder <...>)
    local installable=()
    for f in "${files[@]}"; do
        local api_base
        api_base=$(grep -E '^[[:space:]]*api_base:' "$f" | head -1 | sed 's/.*api_base:[[:space:]]*//' | tr -d "\"'")
        if [[ "$api_base" =~ ^\<.*\>$ ]]; then
            local name
            name=$(extract_skill_name "$f" 2>/dev/null || echo "$(basename "$f" .md)")
            log "Omitiendo plantilla: ${name} (api_base placeholder)"
            continue
        fi
        installable+=("$f")
    done

    echo "  Skills a instalar: ${#installable[@]} (${#files[@]} encontrados, $(( ${#files[@]} - ${#installable[@]} )) plantillas omitidas)"
    echo ""

    # Dry-run: mostrar solo el plan
    if [[ "$DRY_RUN" == true ]]; then
        echo "── Modo dry-run — no se realizarán cambios ──"
        echo ""
        for f in "${installable[@]}"; do
            local skill_name
            skill_name=$(extract_skill_name "$f" || echo "unknown-$(basename "$f" .md)")
            local dest_dir="${OPENCODE_SKILLS}/${skill_name}"
            local target="${dest_dir}/SKILL.md"

            if [[ -f "$target" ]]; then
                if diff -q "$f" "$target" &>/dev/null; then
                    echo "  ✓ ${skill_name} — ya existe y está actualizado"
                else
                    echo "  ~ ${skill_name} — se actualizaría (versión diferente)"
                fi
            else
                echo "  + ${skill_name}/SKILL.md — se crearía"
            fi
        done
        echo ""
        echo "── Fin de dry-run (0 cambios realizados) ──"
        return 0
    fi

    # Crear directorio destino si no existe
    if [[ ! -d "$OPENCODE_SKILLS" ]]; then
        if [[ "$FORCE" != true ]]; then
            echo -n "  ¿Crear directorio ${OPENCODE_SKILLS}? [S/n]: "
            read -r confirm
            if [[ "$confirm" =~ ^[nN] ]]; then
                warn "Instalación cancelada por el usuario"
                return 1
            fi
        fi
        mkdir -p "$OPENCODE_SKILLS"
        log "Creado directorio: ${OPENCODE_SKILLS}"
    fi

    # Copiar archivos
    local copied=0
    local skipped=0
    local failed=0

    for f in "${installable[@]}"; do
        local skill_name
        skill_name=$(extract_skill_name "$f" || echo "unknown-$(basename "$f" .md)")
        local dest_dir="${OPENCODE_SKILLS}/${skill_name}"
        local target="${dest_dir}/SKILL.md"

        # Validar frontmatter antes de copiar
        if verify_frontmatter "$f" >/dev/null 2>&1; then
            :
        else
            warn "Frontmatter inválido en ${f} — se copiará igualmente"
        fi

        if [[ -f "$target" && "$FORCE" != true ]]; then
            if diff -q "$f" "$target" &>/dev/null; then
                log "  ✓ ${skill_name} — sin cambios, omitiendo"
                skipped=$((skipped + 1))
                continue
            fi

            echo -n "  ¿Sobrescribir ${skill_name}? [s/N]: "
            read -r confirm
            if [[ ! "$confirm" =~ ^[sS] ]]; then
                log "  - ${skill_name} — omitido"
                skipped=$((skipped + 1))
                continue
            fi
        fi

        # Crear directorio para el skill si no existe
        mkdir -p "$dest_dir"

        if cp "$f" "$target"; then
            log "  + ${skill_name}/SKILL.md → ${target}"
            copied=$((copied + 1))
        else
            warn "  ✗ Error al copiar ${skill_name}"
            failed=$((failed + 1))
        fi
    done

    echo ""
    echo "── Resumen de instalación ──"
    echo "  Copiados:  ${copied}"
    echo "  Omitidos:  ${skipped}"
    echo "  Fallidos:  ${failed}"

    if [[ "$CHECK" == true ]]; then
        check_portals
    fi

    if [[ "$copied" -gt 0 || "$failed" -gt 0 ]]; then
        echo ""
        info "Instalación completada."
        info "OpenCode reconocerá los skills automáticamente al reiniciar la sesión."
        info "Los skills se instalaron en: ${OPENCODE_SKILLS}/<nombre>/SKILL.md"
        echo ""

        # Actualizar registro de skills si se copió algún skill nuevo
        if [[ "$copied" -gt 0 ]]; then
            update_registry "${installable[@]}"
        fi

    fi
}


# ──────────────────────────────────────────────
# update_registry — Actualiza el registro de skills
# ──────────────────────────────────────────────
update_registry() {
    local skills_to_register=("$@")

    if [[ ${#skills_to_register[@]} -eq 0 ]]; then
        return 0
    fi

    echo ""
    echo "── Actualizando registro de skills ──"
    echo ""

    # Detectar skill-registry del sistema
    local REGISTRY_SKILL="${HOME}/.config/opencode/skills/skill-registry"
    local ATL_DIR
    ATL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.atl" && pwd 2>/dev/null || echo "")"

    # Buscar el .atl más cercano (primero en $SKILL_DIR/../.atl, luego en $HOME)
    if [[ -z "$ATL_DIR" || ! -d "$ATL_DIR" ]]; then
        if [[ -d "${SKILL_DIR}/../.atl" ]]; then
            ATL_DIR="$(cd "${SKILL_DIR}/../.atl" && pwd)"
        elif [[ -d "${HOME}/.atl" ]]; then
            ATL_DIR="${HOME}/.atl"
        fi
    fi

    local REGISTRY_CACHE="${ATL_DIR}/skills-cache.md"

    # Construir tabla de skills instalados
    local table=""
    local count=0
    for f in "${skills_to_register[@]}"; do
        local skill_name skill_desc
        skill_name=$(extract_skill_name "$f" || echo "unknown")
        skill_desc=$(grep -E '^description:' "$f" | head -1 | sed 's/^description:[[:space:]]*//; s/^"//; s/"$//' 2>/dev/null || echo "")
        local dest_path="${OPENCODE_SKILLS}/${skill_name}/SKILL.md"
        table="${table}| \`${skill_name}\` | ${skill_desc} | user | \${HOME}/.config/opencode/skills/${skill_name}/SKILL.md |\n"
        count=$((count + 1))
    done

    if [[ -f "${REGISTRY_SKILL}/SKILL.md" ]]; then
        info "Skill-registry detectado — escribiendo caché local"

        mkdir -p "$(dirname "$REGISTRY_CACHE")"
        cat > "$REGISTRY_CACHE" <<-REGEOF
# Skill Registry — Comunidades Autónomas (instalado)

Generado por install-comunidades-ai.sh el $(date +%Y-%m-%d)

| Skill | Trigger / description | Scope | Path |
|-------|----------------------|-------|------|
$(echo -e "$table")
REGEOF
        info "Registro escrito en ${REGISTRY_CACHE} (${count} skills)"

        # Invocar skill-registry si gentle-ai está disponible
        if command -v gentle-ai &>/dev/null; then
            echo ""
            info "¿Ejecutar skill-registry refresh? Es necesario para que los agentes"
            echo -n "  detecten las skills en sus búsquedas. [S/n]: "
            read -r confirm
            if [[ ! "$confirm" =~ ^[nN] ]]; then
                info "Ejecutando: gentle-ai skill-registry refresh --force"
                gentle-ai skill-registry refresh --force --cwd "$(dirname "${SKILL_DIR}")" 2>&1 || \
                    warn "Error al ejecutar skill-registry (puedes ejecutarlo manualmente)"
            else
                info "Puedes ejecutarlo más tarde con:"
                info "  gentle-ai skill-registry refresh --force"
            fi
        else
            echo ""
            info "Para que los agentes detecten las skills, ejecuta desde OpenCode:"
            info "  gentle-ai skill-registry refresh --force"
        fi
    else
        warn "Skill-registry no encontrado — el registro se actualizará al próximo scan de OpenCode"
        # Aún así escribir el caché local
        mkdir -p "$(dirname "$REGISTRY_CACHE")"
        cat > "$REGISTRY_CACHE" <<-REGEOF
# Skill Registry — Comunidades Autónomas (instalado)

Generado por install-comunidades-ai.sh el $(date +%Y-%m-%d)

| Skill | Trigger / description | Scope | Path |
|-------|----------------------|-------|------|
$(echo -e "$table")
REGEOF
        info "Registro local escrito en ${REGISTRY_CACHE} (${count} skills)"
    fi
}

# ──────────────────────────────────────────────
# Punto de entrada
# ──────────────────────────────────────────────

main() {
    # Parsear argumentos
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)  DRY_RUN=true ;;
            --force)    FORCE=true ;;
            --verbose)  VERBOSE=true ;;
            --check)    CHECK=true ;;
            -h|--help)  usage ;;
            *)
                error "Opción desconocida: $1${NL}Usa --help para ver las opciones disponibles."
                ;;
        esac
        shift
    done

    install_skills
}

main "$@"
