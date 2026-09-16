# Wavelen

Cliente de musica multiplataforma de codigo abierto, en Flutter, con
estilo Material 3 Expressive + "liquid glass". La busqueda y la
reproduccion ya son reales (via `youtube_explode_dart` + `just_audio`,
mismo enfoque que Metrolist: sin API key, resolviendo todo contra los
endpoints internos de YouTube). La Biblioteca (`library_screen.dart`)
todavia usa playlists de muestra: crear/guardar playlists reales es el
siguiente paso pendiente.

Android y Windows se compilan desde este mismo codigo Flutter (antes el
Windows era otro proyecto/tecnologia; como no habia forma de recuperar
ese codigo, arrancamos el Windows de nuevo pero ya con este mismo
diseno, para que ambos salgan de un solo repo y un solo Release).

## Estructura

```
lib/
  main.dart                  punto de entrada, arma el MaterialApp
  theme/app_theme.dart       tema Material 3 "expressive" (formas, tipografia)
  state/app_settings.dart    color de acento, tema claro/oscuro, blur, etc.
  models/                    Song y Playlist
  data/sample_data.dart      canciones y playlists de muestra (placeholder)
  widgets/
    glass_panel.dart         panel con efecto vidrio esmerilado (blur)
    pill_dock.dart           dock inferior en forma de pildora
    mini_player.dart         barra mini-reproductor sobre el dock
  screens/
    home_shell.dart          arma el dock + las 3 secciones
    search_screen.dart       busqueda
    library_screen.dart      biblioteca / playlists
    personalization_screen.dart  color, tema, blur
    player_screen.dart       reproductor a pantalla completa + letras
```

## Por que no hay carpetas `android/` ni `windows/` en el repo

Como venimos compilando todo por GitHub Actions (sin Flutter instalado en
la PC/celular), el workflow genera esas carpetas de cero en cada build
(`flutter create --platforms=android .` y `--platforms=windows .`),
usando siempre la version de Flutter que instala el runner. Asi el repo
se mantiene liviano y no hay archivos generados desincronizados con la
version del SDK.

## Compilar y publicar (Releases)

El workflow `.github/workflows/release.yml` tiene 3 jobs: compila el
APK (Android), compila el .exe (Windows) y despues junta los dos en un
mismo Release de GitHub.

1. Crea un repo en GitHub y sube el contenido de esta carpeta (todo lo
   que esta fuera de `.github/` va en la raiz del repo).
2. Empuja a la rama `main`, o entra a la pestana **Actions** del repo y
   corre el workflow **"Build & Release"** manualmente (boton "Run
   workflow").
3. Cuando terminen los 3 jobs (unos 5-8 min, el de Windows tarda mas),
   entra a la pestana **Releases** del repo: vas a encontrar un release
   llamado **"Ultimo build (Android + Windows)"** con el `.apk` y el
   `wavelen-windows.zip` (adentro esta el `.exe` y sus archivos
   necesarios) como archivos adjuntos.
4. Cada vez que vuelvas a correr el workflow, ese mismo release se
   actualiza con los archivos mas nuevos (no se crean releases nuevas
   cada vez).

## Pendiente para la siguiente etapa

- Conectar la capa de datos real usando el mismo enfoque de Metrolist
  (API interna de YouTube Music / InnerTube) en vez de los datos de
  muestra en `data/sample_data.dart`.
- Reproduccion de audio real (por ahora el reproductor es una simulacion
  visual con un Timer).
- Icono de la app y `applicationId` propio (por ahora usa el paquete por
  defecto `com.example.wavelen`; se puede cambiar agregando `--org` al
  comando `flutter create` del workflow).
