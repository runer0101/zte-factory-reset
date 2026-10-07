# Política de seguridad

## Versiones soportadas

| Versión | Soporte            |
|---------|--------------------|
| 1.0.x   | ✅ Soportada       |
| < 1.0   | ❌ Sin soporte     |

## Reportar una vulnerabilidad

Si descubres una vulnerabilidad de seguridad en este proyecto, **por favor no abras un issue público**. En su lugar:

1. **Envía un email** a los maintainers (ver perfil en GitHub) con:
   - Descripción detallada de la vulnerabilidad
   - Pasos para reproducir
   - Impacto potencial
   - Cualquier PoC (proof of concept)

2. **Espera respuesta** en un plazo de 72 horas.

3. **Coordinación**: trabajaremos contigo para entender el problema, validar el fix y coordinar la divulgación responsable.

## Divulgación responsable

Damos crédito a quienes reportan vulnerabilidades de forma responsable (a menos que prefieran mantenerse anónimos). El tiempo objetivo para resolver vulnerabilidades es de 30 días.

## Alcance de seguridad

Este script:

- ❌ **NO** contiene telemetría ni llamadas a internet
- ❌ **NO** envía datos a ningún servidor externo
- ✅ **SÍ** requiere `sudo` solo para: instalar paquetes, crear reglas udev y agregar el usuario a grupos del sistema
- ✅ **SÍ** es ejecutable y auditable (es bash puro, ~500 líneas)

Si encuentras algún comportamiento sospechoso, repórtalo.

## Buenas prácticas al usar este script

- 🔍 Lee el código antes de ejecutarlo (`cat zte-reset.sh`)
- 🧪 Usa `--dry-run` antes del primer uso real
- 📁 Haz backup de cualquier dato importante antes del reset
- 🔌 Usa un cable USB de confianza (evita cables de origen dudoso en lugares públicos)

---

> Este proyecto es solo con fines educativos. Úsalo únicamente en dispositivos de tu propiedad.
