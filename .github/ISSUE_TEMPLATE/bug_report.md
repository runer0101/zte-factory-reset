---
name: 🐛 Bug report
about: Reportar un problema con el script
title: "[BUG] "
labels: bug
assignees: ''
---

## Descripción del problema

<!-- Una descripción clara y concisa del bug. -->

## Pasos para reproducir

1. …
2. …
3. …

## Comportamiento esperado

<!-- Qué esperabas que pasara. -->

## Comportamiento actual

<!-- Qué pasó realmente. -->

## Salida del script

<!-- Pega aquí la salida completa de `./zte-reset.sh -v`. -->

<details>
<summary>Salida (click para expandir)</summary>

```
pegar aquí
```

</details>

## Entorno

- **Distro y versión**: (ej: `Arch Linux 2025.10.01`)
- **Versión del script**: (ej: `v1.0.0`)
- **Modelo exacto del celular**: (ej: `ZTE Blade A56 P606F21`)
- **¿Lo conectas por USB directamente, hub, dock…?**:

## Diagnóstico

Ejecuta estos comandos y pega la salida:

```bash
# ¿Aparece el dispositivo?
lsusb | grep -i "19d2"

# ¿Tu usuario está en plugdev?
groups

# ¿fastboot detecta algo?
fastboot devices
```

## Notas adicionales

<!-- Cualquier contexto extra, screenshots, etc. -->
