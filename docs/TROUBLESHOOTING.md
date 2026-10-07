# Troubleshooting

Guía completa para resolver problemas al usar `zte-reset.sh`.

> 💡 **Antes de empezar**: ejecuta `./zte-reset.sh --check` para diagnosticar el estado de tu entorno.

## Tabla de problemas frecuentes

| # | Síntoma                                                      | Sección     |
|---|--------------------------------------------------------------|-------------|
| 1 | `fastboot: command not found`                                | [§1](#1)    |
| 2 | `fastboot devices` no muestra nada                           | [§2](#2)    |
| 3 | `no permissions` al ejecutar fastboot                        | [§3](#3)    |
| 4 | `FAILED (remote: 'Permission denied')`                       | [§4](#4)    |
| 5 | Después del reset pide cuenta de Google (FRP)                | [§5](#5)    |
| 6 | Distribución no reconocida                                   | [§6](#6)    |
| 7 | `error: device unauthorized`                                 | [§7](#7)    |
| 8 | `fastboot erase` se queda colgado                            | [§8](#8)    |
| 9 | `bash: ./zte-reset.sh: Permission denied`                    | [§9](#9)    |
| 10| El log no se genera                                         | [§10](#10)  |
| 11| Script se cierra sin error claro                             | [§11](#11)  |

---

## 1. `fastboot: command not found`

**Causa**: el paquete `android-tools` no está instalado y el script no pudo instalarlo (por falta de `sudo` o distro no soportada).

**Solución**:

| Distro              | Comando                                                |
|---------------------|--------------------------------------------------------|
| Arch / Manjaro      | `sudo pacman -S android-tools`                         |
| Debian / Ubuntu     | `sudo apt install android-tools-adb android-tools-fastboot` |
| Fedora              | `sudo dnf install android-tools`                       |
| openSUSE            | `sudo zypper install android-tools`                    |

Luego ejecuta `./zte-reset.sh`. Si la distro no está soportada, usa `--no-install`:

```bash
./zte-reset.sh --no-install
```

## 2. `fastboot devices` no muestra nada

Causas posibles (en orden de probabilidad):

### 2.1 Cable que solo carga

Muchos cables USB solo llevan los pines de alimentación, no los de datos. **Prueba con otro cable.** Si tienes uno de un disco duro externo o de un dispositivo de datos, suele funcionar.

### 2.2 Puerto USB

- Prueba con otro puerto (preferentemente USB 2.0 trasero si es desktop).
- Evita hubs USB sin alimentación propia.
- En laptops, evita los puertos compartidos con otros dispositivos.

### 2.3 Celular no está en modo fastboot

Revisa la pantalla del celular: debe mostrar "Fastboot mode" o el logo de ZTE con texto pequeño, NO el menú recovery ni el sistema operativo.

Para entrar en modo fastboot desde recovery:
- Volumen hasta `Reboot to bootloader`
- Power para confirmar

### 2.4 Reglas udev

Ejecuta `./zte-reset.sh` **sin** `--no-udev` para que las configure automáticamente.

Verificación manual:
```bash
lsusb | grep -i "19d2"
# Debe aparecer algo como: Bus 001 Device 005: ID 19d2:xxxx ZTE Corp
```

Si `lsusb` no muestra nada, es problema de cable o puerto. Si `lsusb` lo ve pero `fastboot devices` no, es problema de permisos/udev.

### 2.5 Grupo plugdev

Tu usuario debe estar en `plugdev`. Tras agregarlo, **cierra sesión y vuelve a entrar**:

```bash
sudo usermod -aG plugdev $USER
# Cerrar sesión completamente (no solo cerrar la terminal)
```

## 3. `no permissions` al ejecutar fastboot

```bash
# Verifica tu grupos actuales
groups

# Si no ves 'plugdev', agrégate
sudo usermod -aG plugdev $USER

# IMPORTANTE: cierra sesión y vuelve a entrar
# Para forzar en la terminal actual:
newgrp plugdev
```

## 4. `FAILED (remote: 'Permission denied')`

El **bootloader está bloqueado** por el fabricante. Esto no es un bug del script: es una decisión de ZTE para proteger el dispositivo.

**Opciones:**

- 🏪 **Servicio técnico oficial ZTE** (recomendado): con la factura y el IMEI, pueden desbloquearlo.
- 🔓 `fastboot oem unlock` — puede que no funcione, pero no hace daño intentar:
  ```bash
  fastboot oem unlock
  ```
  ⚠️ Esto **borrará todo** y normalmente requiere confirmación en pantalla, que no podrás hacer si el dispositivo está bloqueado.
- 🔍 Esperar a exploits públicos (no garantizado, no recomendable en producción).

## 5. Después del reset, el celular pide la cuenta de Google

Esto es el **FRP (Factory Reset Protection)**. **No es un bug**: es la medida antirrobo de Google, activada por defecto en Android 5.0+.

**Soluciones:**

### 5.1 Recuperar la cuenta de Google

Entra desde el navegador a [accounts.google.com/signin/recovery](https://accounts.google.com/signin/recovery) con:

- El correo de la cuenta que estaba en el celular, o
- El número de teléfono asociado

Google te guiará con opciones de recuperación (correo alternativo, número de teléfono, preguntas de seguridad).

### 5.2 Servicio técnico oficial

Con la factura de compra y el IMEI (`866465072475401` o `866465072475419` para el ZTE Blade A56), pueden levantar el FRP con herramientas de fabricante.

### 5.3 Lo que NO funciona

- Ningún `fastboot` o `adb` bypasea el FRP. Quien diga lo contrario te miente.
- Sitios web de "desbloqueo gratuito" → scam o malware.
- Imágenes de sistema modificadas → pueden desactivar la garantía o contener malware.

## 6. Distribución no reconocida

Si tu distro no está en la lista (Arch, Debian/Ubuntu, Fedora/RHEL, openSUSE), el script sugiere los comandos pero no los ejecuta.

**Solución**: instala manualmente y luego ejecuta con `--no-install`:

```bash
# Encuentra el comando para tu distro
# Por ejemplo, Alpine: sudo apk add android-tools
# Luego:
./zte-reset.sh --no-install
```

## 7. `error: device unauthorized`

Este error aparece si el celular muestra un diálogo de "Permitir depuración USB". Como la pantalla está bloqueada, **no puedes aceptarlo**.

**Solución**: este método no funciona para tu caso directo. Necesitas:

- Recordar la contraseña y habilitar USB debug desde el sistema, o
- Servicio técnico oficial.

Alternativamente, si el fastboot está habilitado (suele ser el caso en dispositivos de bajo costo como el A56), `fastboot erase` debería funcionar sin necesidad de autorización de USB debug.

## 8. `fastboot erase` se queda colgado

Síntoma: el comando no termina nunca.

**Causas y soluciones:**

- **Cable defectuoso o muy largo**: prueba con cable más corto y de mejor calidad (≤1m, preferentemente).
- **Puerto USB inestable**: prueba con otro puerto.
- **Celular con batería baja**: conecta el celular a cargar mientras operas.
- **USB 3.0 problemático**: si usas un puerto USB 3.0 (azul), prueba con USB 2.0 (negro).

Para salir del comando colgado: `Ctrl+C`.

## 9. `bash: ./zte-reset.sh: Permission denied`

El script no tiene permisos de ejecución:

```bash
chmod +x zte-reset.sh
./zte-reset.sh
```

## 10. El log no se genera

El log se guarda en `/tmp/zte-reset-<timestamp>.log`. Si `/tmp` no es escribible, fallará. Verifica:

```bash
ls -ld /tmp
mount | grep tmp
```

## 11. Script se cierra sin error claro

Esto puede pasar si `set -e` está activo y un comando falla sin mensaje. Revisa el log:

```bash
# El último log generado
ls -lt /tmp/zte-reset-*.log | head -1

# O ejecuta con verbose para ver todo
./zte-reset.sh -v
```

---

## 🆘 Si nada funciona

Abre un [issue](../../issues) con la siguiente información:

1. **Distro y versión**: salida de `cat /etc/os-release`
2. **Salida completa**: `./zte-reset.sh -v` (con el celular conectado)
3. **Diagnóstico**:
   - `lsusb | grep 19d2`
   - `groups`
   - `fastboot devices`
4. **Modelo exacto del celular**: lo encuentras en la etiqueta trasera (como `P606F21`).
5. **Qué has probado** y qué resultado dio.

Sin esta información, es muy difícil ayudarte. Cuanta más info, más rápido se resuelve. 🛠️
