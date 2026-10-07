# Uso en Windows

> ⚠️ **Este proyecto está pensado principalmente para Linux.** La funcionalidad completa se obtiene en Linux nativo o WSL. En Windows nativo **no funciona directamente** porque depende de `bash`, `udev` y herramientas Unix.

## Tabla de compatibilidades

| Entorno                          | Soporte | Notas                                                                |
|----------------------------------|---------|----------------------------------------------------------------------|
| **Linux nativo**                 | ✅ Total | Soporte completo. Es el caso de uso principal.                        |
| **WSL 1**                        | ⚠️ Parcial | `fastboot` puede no detectar dispositivos USB (limitación de WSL 1). |
| **WSL 2**                        | ✅ Total | Soporte completo. Necesitas [usbipd-win](https://github.com/dorssel/usbipd-win) para pasar el dispositivo USB a WSL. |
| **Git Bash en Windows**          | ⚠️ Parcial | `fastboot`/`adb` funcionan, pero `udev` no existe. Habría que ejecutar fastboot como admin y configurar permisos manualmente. |
| **Cygwin / MSYS2**               | ⚠️ Parcial | Similar a Git Bash. `udev` no está.                                   |
| **Windows nativo (PowerShell)**  | ❌ No   | El script no es compatible. Necesitarías un port a PowerShell.        |

## Opción recomendada: WSL 2

### 1. Instala WSL 2

```powershell
# PowerShell como administrador
wsl --install
wsl --set-default-version 2
```

Instala una distro (Ubuntu, Debian, Arch desde la Microsoft Store).

### 2. Instala distro Linux dentro de WSL

Recomendado: **Ubuntu 24.04 LTS** o **Arch Linux**.

### 3. Pasa el USB del celular a WSL con usbipd-win

```powershell
# En PowerShell como administrador
winget install dorssel.usbipd-win

# Lista los dispositivos USB (busca el ZTE)
usbipd list

# Anota el BUSID del dispositivo ZTE (ej: 1-3)
# Adjúntalo a WSL
usbipd bind --busid <BUSID>
usbipd attach --wsl --busid <BUSID>
```

### 4. Dentro de WSL, sigue las instrucciones del README

```bash
# Ya dentro de tu distro WSL
git clone https://github.com/<tu-usuario>/zte-factory-reset.git
cd zte-factory-reset
chmod +x zte-reset.sh
./zte-reset.sh
```

### 5. Tras terminar, desconecta el USB

```powershell
# En PowerShell como administrador
usbipd detach --busid <BUSID>
```

## Opción alternativa: Git Bash (sin WSL)

⚠️ **Limitaciones importantes:**
- `udev` no existe → tendrás que correr `fastboot` como administrador
- `getent group` y otros comandos Unix faltan → el script puede fallar en la verificación de entorno
- `--no-udev` te puede ayudar, pero aún así necesitas permisos elevados

### Pasos

1. Instala [Git for Windows](https://git-scm.com/download/win)
2. Abre **Git Bash como administrador** (clic derecho → "Run as administrator")
3. Descarga [platform-tools de Google](https://developer.android.com/tools/releases/platform-tools) y agrégalos al PATH
4. Ejecuta:
   ```bash
   ./zte-reset.sh --no-udev --no-install
   ```

## Verificar si estás en WSL

```bash
grep -qi microsoft /proc/version && echo "Estás en WSL" || echo "No estás en WSL"
```

O simplemente:

```bash
ls /proc/version
# Si ves "Microsoft" en la salida, es WSL
```

## Limitaciones específicas de WSL 1

WSL 1 **no soporta USB** directamente. Las alternativas son:

- Actualizar a WSL 2 (`wsl --set-version <Distro> 2`)
- Usar un emulador de Android (no aplica para nuestro caso)
- Hacer el proceso desde un Linux nativo (live USB de Ubuntu, por ejemplo)

## Soporte

Si tienes problemas con Windows/WSL, abre un [issue](../../issues) con la etiqueta `windows` y la salida de:

```bash
# Dentro de WSL
uname -a
cat /etc/os-release
./zte-reset.sh --check
```

---

> 💡 **Recomendación honesta**: si puedes, usa un Linux nativo (USB live de Ubuntu funciona perfecto) o WSL 2. Te vas a ahorrar muchos dolores de cabeza.
