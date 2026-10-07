# 📱 zte-factory-reset

> Asistente interactivo en **bash** para hacer factory reset del **ZTE Blade A56** (`P606F21` / `P606FZ1`) desde Linux, cuando se ha olvidado la contraseña de bloqueo.

[![Bash](https://img.shields.io/badge/bash-5.0%2B-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20WSL-FCC624?logo=linux&logoColor=black)](#-compatibilidad)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![ShellCheck](https://img.shields.io/badge/shellcheck-passing-brightgreen?logo=gnubash)](.github/workflows/shellcheck.yml)
[![Maintenance](https://img.shields.io/badge/maintained-yes-success)](https://github.com/<tu-usuario>/zte-factory-reset/graphs/commit-activity)
[![Issues](https://img.shields.io/github/issues/<tu-usuario>/zte-factory-reset)](https://github.com/<tu-usuario>/zte-factory-reset/issues)

---

## 📋 Tabla de contenidos

- [¿Qué hace?](#-qué-hace)
- [¿Qué NO hace?](#-qué-no-hace)
- [¿Por qué existe?](#-por-qué-existe)
- [Compatibilidad](#-compatibilidad)
- [Requisitos](#-requisitos)
- [Instalación](#-instalación)
- [Uso rápido](#-uso-rápido)
- [Opciones](#-opciones)
- [Cómo funciona](#-cómo-funciona)
- [Salida de ejemplo](#-salida-de-ejemplo)
- [Troubleshooting](#-troubleshooting)
- [Estructura del proyecto](#-estructura-del-proyecto)
- [Contribuir](#-contribuir)
- [Seguridad](#-seguridad)
- [Licencia](#-licencia)

---

## 🤔 ¿Qué hace?

Automatiza el proceso de **factory reset** del ZTE Blade A56 vía `fastboot`, sin necesidad de recordar la contraseña de la pantalla de bloqueo. Es ideal cuando:

- 🔒 **Olvidaste** el PIN, patrón o contraseña de la pantalla
- 🛠️ El reset desde el sistema te pide la contraseña que no recuerdas
- 💻 Prefieres hacer el proceso desde la línea de comandos
- 🔁 Quieres un proceso **repetible** y documentado

## 🚫 ¿Qué NO hace?

- ❌ **No bypasea el FRP** (Factory Reset Protection) de Google. Si después del reset el celular te pide la cuenta de Google, debes recuperarla por tu cuenta en [accounts.google.com/signin/recovery](https://accounts.google.com/signin/recovery).
- ❌ **No flashea ROMs** ni firmware de fabricante.
- ❌ **No es universal**: está pensado específicamente para el ZTE Blade A56. Otros modelos pueden funcionar si comparten el vendor ID USB `19d2`.
- ❌ **No contiene telemetría**: no hace llamadas a internet ni envía datos a ningún servidor.

## 💡 ¿Por qué existe?

Cuando olvidas la contraseña de un Android moderno, el reset desde el sistema pide la misma contraseña. En modo Recovery, el wipe debería funcionar sin contraseña, pero:

- La experiencia de usar `fastboot` desde cero (instalar paquetes, configurar udev, agregar grupos, recordar comandos) es tediosa para usuarios no técnicos.
- No hay scripts abiertos, mantenidos y bien documentados que automaticen todo el flujo.

Este script **encapsula** todo eso en una herramienta con detección de distro, manejo de errores, dry-run y logging.

## ✅ Compatibilidad

### Sistemas operativos

| Sistema                                | Soporte         |
|----------------------------------------|-----------------|
| 🐧 **Linux nativo**                    | ✅ Total         |
| 🪟 **WSL 2** (Windows Subsystem)       | ✅ Total         |
| 🪟 **WSL 1**                            | ⚠️ Limitado     |
| 🪟 **Git Bash / MSYS2 / Cygwin**        | ⚠️ Parcial      |
| 🪟 **Windows nativo (PowerShell/CMD)**  | ❌ No soportado |

> 📖 **¿Usas Windows?** Lee [`docs/WINDOWS.md`](docs/WINDOWS.md) — la opción recomendada es WSL 2 con [usbipd-win](https://github.com/dorssel/usbipd-win).

### Distribuciones Linux probadas

- Arch Linux, Manjaro, EndeavourOS, ArcoLinux, Garuda
- Debian 12+, Ubuntu 22.04+, Linux Mint, Pop!_OS, Zorin, elementaryOS
- Fedora 39+, RHEL/CentOS Stream, Rocky, Alma
- openSUSE Leap / Tumbleweed

> Si tu distro no está en la lista, puedes usar `--no-install` después de instalar `android-tools` manualmente.

### Dispositivos

- ✅ **ZTE Blade A56** (`P606F21` / `P606FZ1`) — caso principal soportado
- ⚠️ **Otros ZTE con vendor ID `19d2`** — probablemente funcione, no testeado

## 📦 Requisitos

- Linux (o WSL 2) con `bash` 5.0+
- `sudo` (para instalar paquetes y crear reglas udev)
- Cable USB que **transmita datos** (no solo carga)
- El celular ZTE Blade A56

## 🚀 Instalación

### Opción A: clonar el repositorio (recomendado)

```bash
git clone https://github.com/<tu-usuario>/zte-factory-reset.git
cd zte-factory-reset
chmod +x zte-reset.sh
```

### Opción B: descarga manual

1. Ve a la página de [**Releases**](../../releases) y descarga el `.tar.gz` o `.zip`.
2. Descomprime y entra al directorio.
3. `chmod +x zte-reset.sh`.

## 🎯 Uso rápido

### 1. Prepara el celular

1. **Apágalo**.
2. Enciéndelo en modo **Recovery** (típicamente: `Power + Vol+`).
3. Selecciona `Reboot to bootloader` con las teclas de volumen y confirma con `Power`.
4. Conecta el celular a la PC por **USB**.

### 2. Ejecuta el script

```bash
./zte-reset.sh
```

El script te guiará paso a paso. Si quieres ver qué haría sin ejecutar nada:

```bash
./zte-reset.sh --dry-run
```

Si solo quieres verificar que tu entorno está listo:

```bash
./zte-reset.sh --check
```

## ⚙️ Opciones

```bash
./zte-reset.sh --help
```

| Opción corta | Opción larga          | Descripción                                                |
|--------------|-----------------------|------------------------------------------------------------|
| `-h`         | `--help`              | Muestra la ayuda y sale                                    |
| `-V`         | `--version`           | Muestra la versión y sale                                  |
| `-c`         | `--check`             | Solo verifica el entorno (no toca nada)                    |
| `-n`         | `--dry-run`           | Simula todas las acciones sin ejecutarlas                  |
| `-y`         | `--yes`               | No pide confirmación (asume 'sí' en todo)                  |
| `-v`         | `--verbose`           | Muestra mensajes de debug                                  |
|              | `--no-install`        | No instala paquetes automáticamente                       |
|              | `--no-udev`           | No configura reglas udev                                   |
|              | `--timeout SEGUNDOS`  | Timeout para detectar el dispositivo (default: `60`)        |

### Ejemplos

```bash
# Simulación: ver qué haría sin tocar nada
./zte-reset.sh --dry-run

# Solo verificar entorno
./zte-reset.sh --check

# Sin confirmación (útil para CI)
./zte-reset.sh --yes

# Esperar más tiempo al dispositivo
./zte-reset.sh --timeout 120

# Verbose + simulación
./zte-reset.sh -v --dry-run
```

## 🔧 Cómo funciona

```
┌─────────────────────────────┐
│ ¿adb/fastboot instalado?    │── NO ──► Detecta distro
└─────────────┬───────────────┘              │
              │ SÍ                          ▼
              │             ┌──────────────────────────────┐
              │             │ Instala con el gestor         │
              │             │ correcto (pacman/apt/dnf/...) │
              │             └──────────────┬───────────────┘
              ▼                            ▼
┌─────────────────────────────┐
│ ¿Reglas udev para ZTE?      │── NO ──► Crea regla y agrega
└─────────────┬───────────────┘              usuario a 'plugdev'
              │ SÍ                          │
              ▼                            ▼
┌─────────────────────────────┐
│ Espera dispositivo en       │  ◄─── Usuario lo pone en
│ modo fastboot vía USB       │       modo fastboot manualmente
└─────────────┬───────────────┘
              │ detectado
              ▼
┌─────────────────────────────┐
│ Confirma con el usuario     │
│ (salvo --yes)               │
└─────────────┬───────────────┘
              │ sí
              ▼
┌─────────────────────────────┐
│ fastboot erase userdata     │  ◄─── BORRA TODOS LOS DATOS
│ fastboot erase cache        │
│ fastboot reboot             │
└─────────────────────────────┘
```

## 📺 Salida de ejemplo

```
╔══════════════════════════════════════════════════╗
║  ZTE Blade A56 — Factory Reset Helper         ║
║  v1.0.0  •  Licencia: MIT  •  Linux/WSL        ║
╚══════════════════════════════════════════════════╝

ℹ  Log:        /tmp/zte-reset-20251007-143022.log
ℹ  Repo:       https://github.com/<user>/zte-factory-reset

── Paso 1/4 — Instalación de dependencias ──
✓  android-tools ya está instalado

── Paso 2/4 — Configuración de udev ──
✓  Regla udev ya existe
✓  Usuario ya pertenece a plugdev

── Paso 3/4 — Esperando dispositivo en modo fastboot ──
ℹ  Conecta tu ZTE Blade A56 por USB en modo fastboot.
ℹ  Esperando dispositivo (timeout: 60s)...
.....✓  Dispositivo detectado: P606F21

── Paso 4/4 — Wipe de fábrica ──
┌──────────────────────────────────────────────────────────────┐
│  ⚠  ESTO VA A BORRAR TODOS LOS DATOS DEL CELULAR          │
└──────────────────────────────────────────────────────────────┘
¿Continuar con el wipe? [s/N]: s
ℹ  Borrando partición 'userdata'...
✓  userdata borrado
ℹ  Borrando partición 'cache'...
✓  cache borrado
✓  Wipe de fábrica completado
ℹ  Reiniciando el celular...
✓  Comando de reinicio enviado. El celular arrancará en unos segundos.

══════════════════════════════════════════════════════════════
  ✓  ¡Listo! El celular se está reiniciando.
══════════════════════════════════════════════════════════════

⚠  Si después del reinicio el celular te pide la cuenta de Google (FRP),
debes recuperarla en: https://accounts.google.com/signin/recovery
```

## 🐛 Troubleshooting

¿Problemas? Revisa primero la [**guía completa de troubleshooting**](docs/TROUBLESHOOTING.md).

Los problemas más comunes:

| Problema                                              | Solución                                                |
|-------------------------------------------------------|---------------------------------------------------------|
| `fastboot: command not found`                        | `sudo pacman -S android-tools` (o equivalente)          |
| `fastboot devices` no muestra nada                   | Revisa el cable, udev, modo fastboot del celular       |
| `no permissions`                                     | `sudo usermod -aG plugdev $USER` y cierra sesión       |
| `FAILED (remote: 'Permission denied')`                | Bootloader bloqueado → servicio técnico oficial ZTE    |
| Tras el reset pide la cuenta de Google               | Es el FRP → recupérala en accounts.google.com          |

## 📁 Estructura del proyecto

```
zte-factory-reset/
├── .editorconfig                # Estilo de código
├── .gitattributes               # Atributos de Git
├── .github/
│   ├── workflows/
│   │   └── shellcheck.yml       # CI: shellcheck + syntax check
│   ├── ISSUE_TEMPLATE/          # Plantillas para issues
│   └── PULL_REQUEST_TEMPLATE.md
├── .gitignore
├── CHANGELOG.md
├── CODE_OF_CONDUCT.md           # Contributor Covenant v2.1
├── CONTRIBUTING.md              # Guía para contribuir
├── LICENSE                      # MIT
├── README.md                    # ← estás aquí
├── SECURITY.md                  # Política de seguridad
├── docs/
│   ├── TROUBLESHOOTING.md       # Guía detallada de problemas
│   └── WINDOWS.md               # Instrucciones para Windows/WSL
└── zte-reset.sh                 # El script principal
```

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Por favor:

1. Lee [`CONTRIBUTING.md`](CONTRIBUTING.md) para conocer el flujo de PRs.
2. Sigue el [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).
3. Antes de hacer un PR, ejecuta:
   ```bash
   bash -n zte-reset.sh          # syntax check
   shellcheck zte-reset.sh        # lint
   ./zte-reset.sh --check         # verificación de entorno
   ./zte-reset.sh --dry-run       # simulación
   ```

### Roadmap de ideas

- [ ] Soporte para más modelos ZTE
- [ ] Tests automatizados con [bats](https://github.com/bats-core/bats-core)
- [ ] Traducciones del README (ES, PT, etc.)
- [ ] Detección automática del modo fastboot desde adb
- [ ] Versión en otros shells (zsh, fish)
- [ ] Empaquetado para AUR / Homebrew / scoop

## 🔒 Seguridad

Este proyecto es **seguro por diseño**:

- ❌ No contiene telemetría ni llamadas externas
- ✅ Es bash puro, ~500 líneas, **totalmente auditable**
- ✅ `sudo` se usa solo para: instalar paquetes, crear reglas udev, agregar al grupo `plugdev`
- ✅ Modo `--dry-run` para verificar antes de hacer cualquier cambio destructivo

Para reportar vulnerabilidades, lee [`SECURITY.md`](SECURITY.md).

## 📄 Licencia

[MIT](LICENSE) © 2025

---

> **Disclaimer**: este proyecto es solo con fines educativos y de recuperación de dispositivos propios. El autor no se hace responsable del mal uso de la herramienta. Respeta la privacidad y propiedad ajena.

<p align="center">
  Hecho con ❤️ para la comunidad Linux
</p>
