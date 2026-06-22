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
# Constantes
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
# check_portals — Verifica portales según metadatos
# ──────────────────────────────────────────────
check_portals() {
    echo ""
    echo "── Verificación de portales ──"
    echo ""

    local found=0
    local checked=0

    for skill_file in "$OPENCODE_SKILLS"/skill-*.md; do
        [[ -f "$skill_file" ]] || continue
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
    done

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

    echo "  Skills a instalar: ${#files[@]}"
    echo ""

    # Dry-run: mostrar solo el plan
    if [[ "$DRY_RUN" == true ]]; then
        echo "── Modo dry-run — no se realizarán cambios ──"
        echo ""
        for f in "${files[@]}"; do
            local basename
            basename="$(basename "$f")"
            local target="${OPENCODE_SKILLS}/${basename}"

            if [[ -f "$target" ]]; then
                if diff -q "$f" "$target" &>/dev/null; then
                    echo "  ✓ ${basename} — ya existe y está actualizado"
                else
                    echo "  ~ ${basename} — se actualizaría (versión diferente)"
                fi
            else
                echo "  + ${basename} — se crearía"
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

    for f in "${files[@]}"; do
        local basename
        basename="$(basename "$f")"
        local target="${OPENCODE_SKILLS}/${basename}"

        # Validar frontmatter antes de copiar
        if verify_frontmatter "$f" >/dev/null 2>&1; then
            :
        else
            warn "Frontmatter inválido en ${basename} — se copiará igualmente"
        fi

        if [[ -f "$target" && "$FORCE" != true ]]; then
            if diff -q "$f" "$target" &>/dev/null; then
                log "  ✓ ${basename} — sin cambios, omitiendo"
                skipped=$((skipped + 1))
                continue
            fi

            echo -n "  ¿Sobrescribir ${basename}? [s/N]: "
            read -r confirm
            if [[ ! "$confirm" =~ ^[sS] ]]; then
                log "  - ${basename} — omitido"
                skipped=$((skipped + 1))
                continue
            fi
        fi

        if cp "$f" "$target"; then
            log "  + ${basename} → ${target}"
            copied=$((copied + 1))
        else
            warn "  ✗ Error al copiar ${basename}"
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
        info "Reinicia o recarga OpenCode para que los nuevos skills estén disponibles."
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
