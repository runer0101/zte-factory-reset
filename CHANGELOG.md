# Changelog

Todos los cambios notables de este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es/1.1.0/),
y este proyecto sigue [Semantic Versioning](https://semver.org/lang/es/).

## [1.0.0] - 2025-10-07

### ✨ Añadido

- Script principal `zte-reset.sh` (~500 líneas) con detección automática de distro
- Soporte para Arch, Debian/Ubuntu, Fedora/RHEL y openSUSE
- Configuración automática de reglas udev para ZTE (vendor ID `19d2`)
- Manejo automático del grupo `plugdev`
- Modo `--dry-run` para simular sin ejecutar
- Modo `--check` para verificar el entorno sin tocar nada
- Modo `--yes` para uso no interactivo
- Logging automático a `/tmp/zte-reset-<timestamp>.log`
- Output con colores (cuando hay terminal interactiva)
- Banner ASCII al inicio
- Manejo de timeouts configurable (`--timeout`)
- Mensajes de UI en español
- Traps para cleanup en señales
- README completo con badges, diagrama de flujo y ejemplos
- Documentación de Windows/WSL (`docs/WINDOWS.md`)
- Documentación de troubleshooting mejorada
- Plantillas de GitHub para issues y PRs
- GitHub Actions workflow para shellcheck
- Code of Conduct (Contributor Covenant v2.1)
- Contributing guide
- Security policy
- .editorconfig y .gitattributes
