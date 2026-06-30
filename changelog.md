# Changelog

Este archivo mantiene un registro detallado de los cambios realizados en el proyecto.
Sigue el formato de [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) y respeta la semántica de versionado según [Semantic Versioning](https://semver.org/).

---

## Formato de las versiones

Las versiones están estructuradas como `MAJOR.MINOR.PATCH`, donde:

- **MAJOR**: Cambios incompatibles con versiones anteriores.
- **MINOR**: Nuevas características compatibles con versiones anteriores.
- **PATCH**: Corrección de errores y mejoras menores.

---

```bash
git tag -a v1.1.0+5 1c015e9 -m "Versión 1.1.0(5) - Soporte a exportación, notificaciones y mejoras UX"
```

## [1.1.0] (5) - 2025-06-05

### Added

- Soporte para exportación de archivos (ej. CSV/Excel).
- Validación y gestión de enfoque en inputs de premio y número de ganadores.

### Changed

- Refactor de estructura de proyecto Android y actualización de dependencias.
- Refactor en las pantallas Home y CardRaffle para mejorar gestión de estado e interacción del usuario.

### Fixed

- Corrección de nombre del premio obtenido.
- Visualización del botón limpiar al mostrar ganadores.
- Redirección y visualización de detalles de ganadores.

---

## Cómo contribuir al changelog

1. **Añadir cambios**: Durante el desarrollo, actualiza la sección `[Unreleased]` con los cambios que realices.
2. **Categorías disponibles**:
   - `Added`: Para nuevas características.
   - `Changed`: Para cambios en características existentes.
   - `Deprecated`: Para funcionalidades que serán eliminadas en el futuro.
   - `Removed`: Para funcionalidades eliminadas.
   - `Fixed`: Para corrección de errores.
   - `Security`: Para problemas de seguridad solucionados.
3. **Actualizar versiones**: Cuando se lance una nueva versión, mueve los cambios de `[Unreleased]` a una nueva sección con la versión correspondiente.
