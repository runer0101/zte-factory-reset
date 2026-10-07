# Guía para contribuir

¡Gracias por tu interés en mejorar **zte-factory-reset**! Toda contribución es bienvenida: código, documentación, reportes de bugs, ideas, etc.

## 📋 Código de conducta

Al participar en este proyecto, aceptas seguir nuestro [Código de Conducta](CODE_OF_CONDUCT.md). Por favor léelo antes de empezar.

## 🐛 Reportar bugs

Antes de abrir un issue, busca en los [issues existentes](../../issues) para ver si ya fue reportado.

Si no existe, abre uno usando la [plantilla de bug](../../issues/new?template=bug_report.md) e incluye:

- Descripción clara del problema
- Pasos exactos para reproducir
- Salida completa con `./zte-reset.sh -v`
- Tu entorno (distro, versión, modelo del celular)
- Resultado de `lsusb | grep 19d2` y `fastboot devices`

## 💡 Proponer features

Abre un issue con la [plantilla de feature](../../issues/new?template=feature_request.md) y describe:

- El problema que resuelve
- Tu propuesta de solución
- Alternativas que consideraste
- Ejemplo de uso

## 🔧 Pull requests

### Flujo recomendado

1. **Fork** del repositorio
2. **Crea una rama** desde `main`:
   ```bash
   git checkout -b feature/mi-cambio
   ```
3. **Haz commits pequeños y descriptivos** siguiendo [Conventional Commits](https://www.conventionalcommits.org/):
   ```bash
   git commit -m "feat: añadir soporte para distro X"
   git commit -m "fix: corregir timeout cuando no detecta dispositivo"
   git commit -m "docs: mejorar sección de troubleshooting"
   ```
4. **Prueba localmente**:
   ```bash
   bash -n zte-reset.sh          # syntax check
   shellcheck zte-reset.sh        # lint
   ./zte-reset.sh --dry-run       # simulación
   ./zte-reset.sh --check         # verificación de entorno
   ```
5. **Actualiza el CHANGELOG.md** con tu cambio
6. **Push y abre el PR** usando la [plantilla de PR](../../compare)
7. **Espera review** — puede que te pida cambios

### Estilo de código

- **Bash**: sigue [Google's Shell Style Guide](https://google.github.io/styleguide/shellguide.html) cuando sea posible
- **Indentación**: 4 espacios (configurado en `.editorconfig`)
- **Variables**: `UPPER_SNAKE_CASE` para constantes, `lower_snake_case` para variables locales
- **Funciones**: `lower_snake_case`, con `local` para todas las variables
- **Comentarios**: en español para el usuario, en inglés para el código
- **Errores**: usa `die "mensaje"` y códigos de salida apropiados
- **Quoting**: siempre entrecomilla las variables: `"$VAR"`, no `$VAR`

### Antes de hacer PR, verifica

- [ ] `bash -n zte-reset.sh` pasa sin errores
- [ ] `shellcheck zte-reset.sh` pasa sin warnings (o con justificaciones)
- [ ] `./zte-reset.sh --help` muestra la ayuda correctamente
- [ ] `./zte-reset.sh --dry-run` simula correctamente
- [ ] El CHANGELOG.md está actualizado
- [ ] El README está actualizado si es necesario

## 🌐 Traducciones

Si quieres traducir el README a otro idioma, los PRs son bienvenidos. Estructura sugerida:

```
README.md       # Inglés (principal)
README.es.md    # Español
README.pt.md    # Portugués
```

## 📜 Licencia

Al contribuir, aceptas que tu código se publique bajo la misma licencia [MIT](LICENSE) del proyecto.

## 💬 Comunicación

- **Issues**: para bugs, features y preguntas
- **Discussions** (si están habilitadas): para preguntas generales y conversación abierta

---

¡Gracias por hacer este proyecto mejor! 🚀
