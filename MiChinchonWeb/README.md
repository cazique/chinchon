# Chinchón - Juego de Cartas Multiplataforma

Implementación del juego de cartas Chinchón utilizando Godot Engine 4.4.1.

## Requisitos

- [Godot Engine 4.4.1](https://godotengine.org/download)
- [Visual Studio 2022](https://visualstudio.microsoft.com/es/vs/) (opcional, para edición de scripts)
- [.NET SDK](https://dotnet.microsoft.com/download) (opcional, para funcionalidades avanzadas)
- [Android SDK](https://developer.android.com/studio) (opcional, para exportar a Android)

## Estructura del Proyecto

El proyecto está organizado siguiendo una estructura orientada a facilitar el desarrollo multiplataforma y multilenguaje:

- /addons: Plugins y extensiones
- /assets: Recursos del juego (audio, imágenes, traducciones)
- /scenes: Escenas de Godot organizadas por funcionalidad
- /scripts: Scripts de GDScript organizados por funcionalidad
- /tests: Pruebas automatizadas

## Cómo Iniciar

1. Clona este repositorio
2. Ejecuta el script de inicialización \init_structure.ps1\ (Windows) o \init_structure.sh\ (macOS/Linux)
3. Abre el proyecto en Godot Engine 4.4.1

## Exportación del Proyecto

### WebGL
1. Abre el proyecto en Godot
2. Selecciona "Proyecto" > "Exportar"
3. Selecciona la configuración "Web"
4. Haz clic en "Exportar Proyecto"
5. Sube los archivos generados a tu servidor web

### Windows
1. Abre el proyecto en Godot
2. Selecciona "Proyecto" > "Exportar"
3. Selecciona la configuración "Windows Desktop"
4. Haz clic en "Exportar Proyecto"
5. Ejecuta el archivo .exe generado

### Android
1. Asegúrate de tener configurado el Android SDK
2. Abre el proyecto en Godot
3. Selecciona "Proyecto" > "Exportar"
4. Selecciona la configuración "Android"
5. Haz clic en "Exportar Proyecto"
6. Instala el APK generado en tu dispositivo

## Contribuciones

Las contribuciones son bienvenidas. Por favor, asegúrate de seguir las convenciones de código establecidas.

## Licencia

[Especificar licencia]
