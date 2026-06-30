# 🎁 Sorteo Regalon Footloose (Desktop)

Aplicación de escritorio creada en Flutter para gestionar sorteos especiales como Navidad o Día de la Madre. La app es fácilmente configurable y expandible para nuevos eventos.

---

## 📁 Estructura de configuración

### `config/special_days.dart`

Define los días especiales con la enumeración:

```dart
enum SpecialDays { christmas, mothersDay }
```

También contiene funciones para:

- Obtener la imagen del evento (`getFileImage`)
- Mostrar un flyer personalizado (`getFlyerImage`)

### `config/environment.dart`

Controla el entorno y el evento actual:

```dart
class Environment {
  static const current = Environments.dev;
  static SpecialDays currentSpecialDay = SpecialDays.mothersDay;
}
```

> 🔄 Para cambiar el evento mostrado, modifica `currentSpecialDay`.

---

## 🛠️ Compilar la app para Windows

1. Asegúrate de cerrar cualquier ventana del ejecutable abierta.
2. Limpia y vuelve a instalar dependencias:

```bash
flutter clean
flutter pub get
```

3. Genera el ejecutable:

```bash
flutter build windows
```

El ejecutable se genera en:  
`build/windows/x64/runner/Release/raffle_footloose.exe`

---

## 💾 Crear el instalador con Inno Setup

Usamos **Inno Setup** para generar un instalador `.exe`:

1. Copia y renombra `generador.issis` (ej: `sorteo_navidad.iss`).
2. Edita los valores necesarios:

   - `OutputBaseFilename`
   - `MyAppName`, `MyAppVersion`, etc.
   - `SetupIconFile` para cambiar el ícono

3. Compila con Inno Setup.

---

## 🧯 Cambiar el favicon (ícono)

### Ícono del ejecutable (thumbnail)

1. Reemplaza este archivo:

```
windows/runner/resources/app_icon.ico
```

2. Luego ejecuta:

```bash
flutter clean
flutter build windows
```

### Ícono del acceso directo (Inno Setup)

1. Agrega en `[Files]`:

```ini
Source: "lib/assets/favicon.ico"; DestDir: "{app}"; DestName: "app_icon.ico"; Flags: ignoreversion
```

2. En `[Icons]`:

```ini
Name: "{autodesktop}\Sorteo Regalon Footloose"; Filename: "{app}\raffle_footloose.exe"; IconFilename: "{app}\app_icon.ico"; Tasks: desktopicon
```

---

## ✅ Recomendaciones

- Probar el instalador en una máquina limpia o virtual.
- Crear un `.iss` por campaña (Navidad, Día de la Madre, etc.)
- Expandir la enum `SpecialDays` con nuevos eventos.

## Configuración desktop

Para configurar notifaciones en Desktop, ocultamos lo de notificaciones en dispositivos móviles. (services/notification/notification_mobile.dart)

---

## 👨‍💻 Créditos

Desarrollado con ♥️ por [Pierre Juarez](https://www.linkedin.com/in/pierre-juarez/) 😊
