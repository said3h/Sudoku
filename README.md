# Sudoku Premium

Sudoku Premium es una app Flutter con tema oscuro premium, motor de Sudoku, guardado automatico de partida y estadisticas basicas.

## Funcionalidades

- Nueva partida por dificultad
- Reanudacion automatica de la ultima partida guardada
- Modo notas, pista, deshacer y contador de errores
- Estadisticas locales con mejores tiempos por dificultad
- Soporte Flutter para Android, iOS, Web, Windows, macOS y Linux

## Desarrollo local

```bash
flutter pub get
flutter analyze
flutter run
```

## Builds

- Android APK local: `flutter build apk --release`
- Web local: `flutter build web`
- iOS IPA: se genera en GitHub Actions con macOS usando `--no-codesign`

## Artefactos CI

El workflow de GitHub Actions `mobile-build.yml` publica estos artefactos:

- `sudoku-premium-apk`
- `sudoku-premium-ipa`

El `ipa` esta pensado para descarga manual y posterior instalacion con Sideloadly.
