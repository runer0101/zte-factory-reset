#!/usr/bin/env bash
#===============================================================================
#  zte-reset.sh
#
#  Asistente interactivo para hacer factory reset del ZTE Blade A56
#  (modelo P606F21 / P606FZ1) desde Linux, cuando se ha olvidado la
#  contraseña de bloqueo.
#
#  ----------------------------------------------------------------------------
#  AVISO IMPORTANTE
#  ----------------------------------------------------------------------------
#  Este script NO bypasea el Factory Reset Protection (FRP) de Google. Si
#  el dispositivo te pide la cuenta de Google después del reset, debes
#  recuperarla por tu cuenta. Más info en la sección FRP del README.
#
#  ----------------------------------------------------------------------------
#  USO
#  ----------------------------------------------------------------------------
#  ./zte-reset.sh                    # Modo interactivo (recomendado)
#  ./zte-reset.sh --dry-run          # Simular sin ejecutar nada destructivo
#  ./zte-reset.sh --check            # Solo verificar el entorno
#  ./zte-reset.sh --help             # Ver todas las opciones
#
#  ----------------------------------------------------------------------------
#  Licencia: MIT
#  Repo:     https://github.com/runer0101/zte-factory-reset
#===============================================================================

set -euo pipefail
IFS=$'\n\t'

#===============================================================================
# CONSTANTES
#===============================================================================
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_NAME
readonly VERSION="1.0.0"
readonly ZTE_VENDOR_ID="19d2"
readonly UDEV_RULE_FILE="/etc/udev/rules.d/51-android-zte.rules"
LOG_FILE="/tmp/zte-reset-$(date +%Y%m%d-%H%M%S).log"
readonly LOG_FILE
readonly REPO_URL="https://github.com/runer0101/zte-factory-reset"

#===============================================================================
# COLORES (solo si la salida es una terminal interactiva)
#===============================================================================
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly CYAN='\033[0;36m'
    readonly BOLD='\033[1m'
    readonly DIM='\033[2m'
    readonly NC='\033[0m'
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly CYAN=''
    readonly BOLD=''
    readonly DIM=''
    readonly NC=''
fi

#===============================================================================
# VARIABLES GLOBALES (seteadas en parse_args)
#===============================================================================
DRY_RUN=false
ASSUME_YES=false
VERBOSE=false
NO_INSTALL=false
NO_UDEV=false
TIMEOUT=60
CHECK_ONLY=false

#===============================================================================
# FUNCIONES DE LOGGING
#===============================================================================
_log() {
    local level="$1"
    shift
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    local clean_msg="$*"
    clean_msg="${clean_msg//$'\033'/<ESC>}"
    echo "${timestamp} [${level}] ${clean_msg}" >> "$LOG_FILE"
    echo -e "$@" >&2
}

info()    { _log "INFO"  "${BLUE}${BOLD}ℹ${NC}  ${*}"; }
success() { _log "OK"    "${GREEN}${BOLD}✓${NC}  ${*}"; }
warn()    { _log "WARN"  "${YELLOW}${BOLD}⚠${NC}  ${*}"; }
error()   { _log "ERROR" "${RED}${BOLD}✗${NC}  ${*}"; }

debug() {
    if [[ "$VERBOSE" == true ]]; then
        _log "DEBUG" "${CYAN}${BOLD}→${NC}  ${*}"
    fi
}

section() {
    echo
    _log "SECTION" "${BOLD}${CYAN}── ${*} ──${NC}"
    echo
}

die() {
    error "$*"
    exit 1
}

#===============================================================================
# UTILIDADES GENERALES
#===============================================================================
command_exists() { command -v "$1" >/dev/null 2>&1; }

# Trap para limpieza en señales
cleanup() {
    local exit_code=$?
    if [[ -t 1 ]]; then
        printf '\033[?25h' 2>/dev/null
    fi
    if [[ $exit_code -ne 0 ]] && [[ $exit_code -ne 130 ]]; then
        error "Script terminado con error (código: $exit_code)"
        info "Log completo en: $LOG_FILE"
    fi
    exit "$exit_code"
}
trap cleanup EXIT
trap 'exit 130' INT TERM

detect_distro() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        printf '%s' "${ID:-unknown}"
    else
        printf '%s' "unknown"
    fi
}

is_wsl() {
    [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null
}

print_banner() {
    cat <<EOF
${BOLD}${CYAN}╔══════════════════════════════════════════════════╗
${BOLD}${CYAN}║${NC}${BOLD}  ZTE Blade A56 — Factory Reset Helper${NC}${BOLD}${CYAN}         ║
${BOLD}${CYAN}║${NC}${DIM}  v${VERSION}  •  Licencia: MIT  •  Linux/WSL${NC}${BOLD}${CYAN}              ║
${BOLD}${CYAN}╚══════════════════════════════════════════════════╝${NC}
EOF
}

#===============================================================================
# VERIFICACIÓN DE ENTORNO
#===============================================================================
check_environment() {
    section "Verificando entorno"

    local has_errors=false

    if is_wsl; then
        info "Entorno: WSL (Windows Subsystem for Linux) ✓"
    elif [[ "$(uname -s)" == "Linux" ]]; then
        local distro
        distro="$(detect_distro)"
        info "Entorno: Linux (${distro}) ✓"
    else
        error "Sistema operativo no soportado: $(uname -s)"
        error "Este script solo funciona en Linux o WSL."
        has_errors=true
    fi

    if command_exists fastboot && command_exists adb; then
        local fastboot_ver
        fastboot_ver="$(fastboot --version 2>&1 | head -1 || echo 'desconocida')"
        success "fastboot: ${fastboot_ver}"
    else
        error "fastboot/adb no encontrado"
        info "Instala con: sudo pacman -S android-tools  (o el equivalente de tu distro)"
        has_errors=true
    fi

    if [[ -f "$UDEV_RULE_FILE" ]] && grep -q "$ZTE_VENDOR_ID" "$UDEV_RULE_FILE" 2>/dev/null; then
        success "Reglas udev para ZTE configuradas ✓"
    else
        warn "Reglas udev para ZTE no configuradas"
        info "Se configurarán automáticamente al ejecutar el script."
    fi

    if groups "${USER:-root}" 2>/dev/null | grep -qw plugdev; then
        success "Usuario en grupo plugdev ✓"
    else
        warn "Usuario no está en grupo 'plugdev'"
        info "Se agregará automáticamente (requiere logout tras la primera ejecución)."
    fi

    if command_exists sudo; then
        success "sudo disponible ✓"
    else
        error "sudo no encontrado (se requiere para instalar paquetes y configurar udev)"
        has_errors=true
    fi

    echo
    if [[ "$has_errors" == true ]]; then
        die "Hay problemas en el entorno que deben resolverse antes de continuar."
    fi
    success "Entorno listo para continuar"
}

#===============================================================================
# INSTALACIÓN DE DEPENDENCIAS
#===============================================================================
install_dependencies() {
    section "Paso 1/4 — Instalación de dependencias"

    if [[ "$NO_INSTALL" == true ]]; then
        warn "Saltando instalación de paquetes (--no-install)"
        return 0
    fi

    if command_exists fastboot && command_exists adb; then
        success "android-tools ya está instalado"
        return 0
    fi

    info "Faltan herramientas. Detectando gestor de paquetes..."
    local distro
    distro="$(detect_distro)"

    case "$distro" in
        arch|manjaro|endeavouros|arcolinux|garuda)
            info "Distro: Arch Linux (o derivado) → pacman"
            if [[ "$DRY_RUN" == true ]]; then
                info "[DRY-RUN] sudo pacman -S --needed --noconfirm android-tools"
            else
                sudo pacman -S --needed --noconfirm android-tools
            fi
            ;;
        debian|ubuntu|linuxmint|pop|zorin|elementary|kali)
            info "Distro: Debian/Ubuntu (o derivado) → apt"
            if [[ "$DRY_RUN" == true ]]; then
                info "[DRY-RUN] sudo apt update && sudo apt install -y android-tools-adb android-tools-fastboot"
            else
                sudo apt update
                sudo apt install -y android-tools-adb android-tools-fastboot
            fi
            ;;
        fedora|rhel|centos|rocky|alma)
            info "Distro: Fedora/RHEL (o derivado) → dnf"
            if [[ "$DRY_RUN" == true ]]; then
                info "[DRY-RUN] sudo dnf install -y android-tools"
            else
                sudo dnf install -y android-tools
            fi
            ;;
        opensuse*|sles)
            info "Distro: openSUSE → zypper"
            if [[ "$DRY_RUN" == true ]]; then
                info "[DRY-RUN] sudo zypper install -y android-tools"
            else
                sudo zypper install -y android-tools
            fi
            ;;
        *)
            error "Distribución no reconocida: $distro"
            error "Instala 'android-tools' manualmente y vuelve a ejecutar con --no-install"
            return 1
            ;;
    esac

    success "Dependencias instaladas correctamente"
}

#===============================================================================
# CONFIGURACIÓN DE UDEV
#===============================================================================
setup_udev() {
    section "Paso 2/4 — Configuración de udev"

    if [[ "$NO_UDEV" == true ]]; then
        warn "Saltando configuración de udev (--no-udev)"
        return 0
    fi

    info "Configurando acceso USB para ZTE (vendor ID: ${ZTE_VENDOR_ID})..."

    if ! getent group plugdev >/dev/null 2>&1; then
        info "Creando grupo 'plugdev'..."
        if [[ "$DRY_RUN" == false ]]; then
            sudo groupadd plugdev
        fi
    fi

    local rule='SUBSYSTEM=="usb", ATTR{idVendor}=="'"${ZTE_VENDOR_ID}"'", MODE="0666", GROUP="plugdev"'
    if [[ -f "$UDEV_RULE_FILE" ]] && grep -q "$ZTE_VENDOR_ID" "$UDEV_RULE_FILE" 2>/dev/null; then
        success "Regla udev ya existe"
    else
        if [[ "$DRY_RUN" == true ]]; then
            info "[DRY-RUN] echo '$rule' | sudo tee $UDEV_RULE_FILE"
        else
            echo "$rule" | sudo tee "$UDEV_RULE_FILE" >/dev/null
            sudo udevadm control --reload-rules
            sudo udevadm trigger
            success "Regla udev creada y recargada"
        fi
    fi

    if groups "${USER:-root}" 2>/dev/null | grep -qw plugdev; then
        success "Usuario ya pertenece a plugdev"
    else
        warn "Agregando usuario '${USER:-actual}' al grupo 'plugdev'..."
        if [[ "$DRY_RUN" == false ]]; then
            sudo usermod -aG plugdev "${USER:-root}"
            warn "⚠  IMPORTANTE: cierra sesión y vuelve a entrar para que el cambio tome efecto."
        else
            info "[DRY-RUN] sudo usermod -aG plugdev ${USER:-actual}"
        fi
    fi
}

#===============================================================================
# ESPERA DEL DISPOSITIVO EN FASTBOOT
#===============================================================================
wait_for_device() {
    section "Paso 3/4 — Esperando dispositivo en modo fastboot"

    local timeout="${1:-60}"
    local elapsed=0

    info "Conecta tu ZTE Blade A56 por USB en modo fastboot."
    info "Si aún no lo hiciste: apágalo, enciéndelo en modo Recovery,"
    info "elige 'Reboot to bootloader' y conéctalo a la PC."
    echo
    info "Esperando dispositivo (timeout: ${timeout}s)..."

    while (( elapsed < timeout )); do
        local device_line
        device_line="$(fastboot devices 2>/dev/null | awk '/fastboot$/{print; exit}')"
        if [[ -n "$device_line" ]]; then
            echo
            local device
            device="$(echo "$device_line" | awk '{print $1}')"
            success "Dispositivo detectado: ${device}"
            debug "fastboot devices: ${device_line}"
            return 0
        fi
        sleep 2
        (( elapsed += 2 ))
        printf '%s' "${DIM}."
    done
    echo
    die "No se detectó ningún dispositivo en modo fastboot. Revisa el cable USB y el modo del celular."
}

#===============================================================================
# WIPE Y REBOOT
#===============================================================================
do_wipe() {
    section "Paso 4/4 — Wipe de fábrica"

    cat <<EOF
${YELLOW}${BOLD}┌──────────────────────────────────────────────────────────────┐
${YELLOW}${BOLD}│${NC}${BOLD}  ⚠  ESTO VA A BORRAR TODOS LOS DATOS DEL CELULAR        ${YELLOW}${BOLD}│
${YELLOW}${BOLD}│${NC}    Fotos, apps, mensajes, cuentas: TODO se perderá.       ${YELLOW}${BOLD}│
${YELLOW}${BOLD}└──────────────────────────────────────────────────────────────┘${NC}
EOF
    echo

    if [[ "$ASSUME_YES" == false ]]; then
        if ! confirm "¿Continuar con el wipe?"; then
            die "Operación cancelada por el usuario"
        fi
    fi

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] fastboot erase userdata"
        info "[DRY-RUN] fastboot erase cache"
        info "[DRY-RUN] fastboot reboot"
        return 0
    fi

    info "Borrando partición 'userdata'..."
    fastboot erase userdata || die "Falló 'fastboot erase userdata'"
    success "userdata borrado"

    info "Borrando partición 'cache'..."
    fastboot erase cache || die "Falló 'fastboot erase cache'"
    success "cache borrado"

    success "Wipe de fábrica completado"
}

do_reboot() {
    info "Reiniciando el celular..."
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] fastboot reboot"
        return 0
    fi
    fastboot reboot
    success "Comando de reinicio enviado. El celular arrancará en unos segundos."
}

#===============================================================================
# UI: CONFIRMACIÓN INTERACTIVA
#===============================================================================
confirm() {
    local prompt="${1:-¿Continuar?}"
    local response
    # shellcheck disable=SC2162
    read -r -p "$(printf '%s' "${YELLOW}${prompt}${NC} [s/N]: ")" response
    case "${response:-}" in
        [sSyY]|[sSyY][iI]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

#===============================================================================
# AYUDA Y VERSIÓN
#===============================================================================
show_version() {
    printf '%s v%s\n' "${SCRIPT_NAME}" "${VERSION}"
    printf 'Licencia: MIT\n'
    printf 'Repo:     %s\n' "${REPO_URL}"
}

show_help() {
    cat <<EOF
${BOLD}${SCRIPT_NAME}${NC} v${VERSION} — Asistente para reset de fábrica del ZTE Blade A56

${BOLD}SINTAXIS:${NC}
    $SCRIPT_NAME [opciones]

${BOLD}OPCIONES:${NC}
    -h, --help              Muestra esta ayuda y sale
    -V, --version           Muestra la versión y sale
    -c, --check             Solo verifica el entorno (no toca nada)
    -n, --dry-run           Simula todas las acciones sin ejecutarlas
    -y, --yes               No pide confirmación (asume 'sí' en todo)
    -v, --verbose           Muestra mensajes de debug
    --no-install            No instala paquetes automáticamente
    --no-udev               No configura reglas udev
    --timeout SEGUNDOS      Timeout para detectar el dispositivo (default: 60)

${BOLD}DESCRIPCIÓN:${NC}
    Automatiza el factory reset del ZTE Blade A56 cuando se ha olvidado
    la contraseña de bloqueo.

    Pasos que ejecuta:
      1. Verifica e instala android-tools (adb / fastboot) si hace falta
      2. Configura reglas udev y grupo plugdev para ZTE (vendor 19d2)
      3. Espera a que el celular esté conectado en modo fastboot
      4. Ejecuta 'fastboot erase userdata' + 'fastboot erase cache'
      5. Envía 'fastboot reboot'

${BOLD}COMPATIBILIDAD:${NC}
    • Linux: soportado completamente (cualquier distro con android-tools)
    • WSL (Windows Subsystem for Linux): soportado
    • Git Bash en Windows: parcial (udev no funciona, pero adb/fastboot sí)
    • Windows nativo (PowerShell/CMD): NO soportado

${BOLD}IMPORTANTE:${NC}
    Este script NO bypasea el Factory Reset Protection (FRP) de Google.
    Si el dispositivo pide la cuenta de Google tras el reset, debes
    recuperarla por tu cuenta en:
        https://accounts.google.com/signin/recovery

${BOLD}EJEMPLOS:${NC}
    $SCRIPT_NAME                    # Modo interactivo (recomendado)
    $SCRIPT_NAME -c                 # Solo verificar entorno
    $SCRIPT_NAME -n                 # Simulación (ver qué haría)
    $SCRIPT_NAME -y                 # Sin confirmación
    $SCRIPT_NAME --timeout 120      # Esperar 2 minutos al dispositivo
    $SCRIPT_NAME -v --dry-run       # Verbose + simulación

${BOLD}ARCHIVOS:${NC}
    Log:    $LOG_FILE
    Regla:  $UDEV_RULE_FILE

${BOLD}MÁS INFO:${NC}
    README:  ${REPO_URL}#readme
    Issues:  ${REPO_URL}/issues
EOF
}

#===============================================================================
# PARSEO DE ARGUMENTOS
#===============================================================================
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)              show_help; exit 0 ;;
            -V|--version)           show_version; exit 0 ;;
            -c|--check)             CHECK_ONLY=true; shift ;;
            -n|--dry-run)           DRY_RUN=true; shift ;;
            -y|--yes)               ASSUME_YES=true; shift ;;
            -v|--verbose)           VERBOSE=true; shift ;;
            --no-install)           NO_INSTALL=true; shift ;;
            --no-udev)              NO_UDEV=true; shift ;;
            --timeout)              TIMEOUT="$2"; shift 2 ;;
            --timeout=*)            TIMEOUT="${1#*=}"; shift ;;
            --)                     shift; break ;;
            -*)                     die "Opción desconocida: $1. Usa --help para ver las opciones." ;;
            *)                      die "Argumento posicional no soportado: $1" ;;
        esac
    done
}

#===============================================================================
# MAIN
#===============================================================================
main() {
    parse_args "$@"
    print_banner

    echo
    info "Log:        $LOG_FILE"
    info "Repo:       $REPO_URL"
    if [[ "$DRY_RUN" == true ]]; then
        warn "DRY-RUN: no se ejecutará nada destructivo"
    fi
    if [[ "$ASSUME_YES" == true ]]; then
        warn "Modo --yes: no pedirá confirmación"
    fi
    if [[ "$CHECK_ONLY" == true ]]; then
        warn "Modo --check: solo verificando entorno"
    fi
    echo

    if [[ "$CHECK_ONLY" == true ]]; then
        check_environment
        echo
        success "Verificación completada. Todo listo (o se listaron los problemas)."
        exit 0
    fi

    check_environment || true
    echo
    install_dependencies
    setup_udev
    wait_for_device "$TIMEOUT"
    do_wipe
    do_reboot

    echo
    cat <<EOF
${GREEN}${BOLD}══════════════════════════════════════════════════════════════${NC}
${GREEN}${BOLD}  ✓  ¡Listo! El celular se está reiniciando.${NC}
${GREEN}${BOLD}══════════════════════════════════════════════════════════════${NC}
EOF
    echo
    warn "Si después del reinicio el celular te pide la cuenta de Google (FRP),"
    warn "debes recuperarla en: https://accounts.google.com/signin/recovery"
    echo
    info "Log guardado en: $LOG_FILE"
    echo
}

main "$@"
