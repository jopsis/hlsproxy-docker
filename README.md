# HLS Proxy en Docker

Contenedor Docker para ejecutar HLS Proxy Server, un servidor de streaming HLS con capacidades de restreaming y gestión de EPG.

## Imágenes Docker Hub

Las imágenes pre-construidas están disponibles en: **[https://hub.docker.com/r/jopsis/hlsproxy](https://hub.docker.com/r/jopsis/hlsproxy)**

Para usar la imagen directamente desde Docker Hub:
```bash
docker pull jopsis/hlsproxy:latest
```

### CI/CD Automático

Este repositorio incluye un workflow de GitHub Actions que:
- **Push a main**: Compila y publica automáticamente con el tag `latest`
- **Tags de versión**: Al crear un tag, compila y publica con el **nombre exacto del tag**
- Compila para las plataformas `linux/amd64` y `linux/arm64`
- Utiliza caché de GitHub Actions para acelerar las compilaciones

#### Ejemplos de uso de tags

```bash
# Crear y publicar una nueva versión
git tag v8.4.8
git push origin v8.4.8
```

Esto generará automáticamente en Docker Hub:
- `jopsis/hlsproxy:v8.4.8` (nombre exacto del tag)
- `jopsis/hlsproxy:latest` (siempre actualizado desde main)

#### Requisitos

Para que el workflow funcione, debes configurar los siguientes secrets en tu repositorio de GitHub:
- `DOCKER_HUB_USR`: Tu usuario de Docker Hub
- `DOCKER_HUB_PWD`: Tu token de acceso de Docker Hub (o contraseña)

## Dockerfile

El Dockerfile crea una imagen **multiplataforma** basada en Ubuntu que soporta arquitecturas ARM64 y x86_64.

### Características

- **Base**: Ubuntu latest
- **Puerto expuesto**: 38050
- **Arquitecturas soportadas**:
  - linux/arm64 (aarch64)
  - linux/amd64 (x86_64)
- **Dependencias instaladas**:
  - `wget`: Para descargar el binario de HLS Proxy
  - `unzip`: Para descomprimir el archivo descargado
  - `mc`: Midnight Commander para gestión de archivos
  - `nano`: Editor de texto
  - `ffmpeg`: Para procesamiento de streams de video
  - `tzdata`: Configuración de zona horaria (Europe/Berlin)

### Proceso de construcción

1. Actualiza e instala paquetes necesarios
2. Configura la zona horaria a Europe/Berlin
3. **Detecta automáticamente la arquitectura del sistema** (`uname -m`)
4. Descarga el binario correcto de HLS Proxy v8.4.8 según la arquitectura:
   - ARM64: `hls-proxy-8.4.8.linux-arm64.zip`
   - x86_64: `hls-proxy-8.4.8.linux-x64.zip`
5. Descomprime y limpia archivos temporales para reducir el tamaño de la imagen
6. Establece permisos de ejecución para `/opt/hls-proxy`
7. Define el comando de inicio del contenedor

La imagen detecta automáticamente la plataforma durante la construcción, por lo que no necesitas especificar manualmente qué versión descargar.

## Configuración: local.json

El archivo `local.json` contiene la configuración del servidor HLS Proxy:

### Servidor
```json
"SERVER": {
    "address": "0.0.0.0",           // Escucha en todas las interfaces
    "port": 38050,                   // Puerto del servidor
    "password": "changeme",          // Contraseña de acceso (cambiar en producción)
    "secret": "changeme",            // Secret key (cambiar en producción)
    "isAllowUsersWithAnyToken": true,
    "isRestreamer": true             // Habilita funcionalidad de restreaming
}
```

### EPG (Guía de Programación Electrónica)
```json
"epg": {
    "tvGuideUrl": [                  // URLs de las guías EPG
        "https://raw.githubusercontent.com/davidmuma/EPG_dobleM/refs/heads/master/guiaiptv.xml",
        "https://www.tdtchannels.com/epg/TV.xml.gz"
    ],
    "historyDays": 2,                // Días de historial EPG
    "isAddUrlEpgToEXTINF": true
}
```

### Configuración de Streaming
- `maxSimultaneousStreamCountPerClientDefault`: 100 streams simultáneos por cliente
- `safeChunkSeq`: 3 chunks de seguridad
- `fastStartChunks`: 4 chunks para inicio rápido
- `getTsChunkRetries`: 4 reintentos para obtener chunks
- `retriesForError403/404`: Reintentos para errores HTTP
- `httpResponseStallTimeout`: 45000ms timeout
- `preferableBandwidth`: 800000 bps

### Características Habilitadas
- `isXtreamCodesApiEnabled`: true - API Xtream Codes activa
- `isHtmlPlayerEnabled`: true - Reproductor HTML activo
- `isPlaylistAvailableFromOutside`: true - Playlists accesibles externamente
- `isCacheInMemory`: false - Cache en disco
- `isReadChunksFromCacheDir`: true - Lectura de chunks desde caché

### Grabación
```json
"RECORDING": {
    "isEnabled": false               // Grabación deshabilitada por defecto
}
```

## Uso

### Construcción de la imagen

#### Construcción simple (plataforma actual)
```bash
docker build -t hlsproxy .
```

#### Construcción multiplataforma con buildx
Para construir imágenes para ambas arquitecturas (ARM64 y x86_64):

```bash
# Crear un builder multiplataforma (solo la primera vez)
docker buildx create --name multiplatform --use

# Construir para múltiples plataformas
docker buildx build --platform linux/amd64,linux/arm64 -t tu-usuario/hlsproxy:latest .

# Construir y subir a un registry
docker buildx build --platform linux/amd64,linux/arm64 -t tu-usuario/hlsproxy:latest --push .
```

#### Construcción para una plataforma específica
```bash
# Solo para ARM64
docker buildx build --platform linux/arm64 -t hlsproxy:arm64 --load .

# Solo para x86_64/AMD64
docker buildx build --platform linux/amd64 -t hlsproxy:amd64 --load .
```

### Ejecutar el contenedor

#### Usando imagen local
```bash
docker run -d -p 38050:38050 -v $(pwd)/local.json:/opt/local.json hlsproxy
```

#### Usando imagen de Docker Hub
```bash
docker run -d -p 38050:38050 -v $(pwd)/local.json:/opt/local.json jopsis/hlsproxy:latest
```

## Notas de Seguridad

**IMPORTANTE**: Antes de usar en producción, cambia los siguientes valores en `local.json`:
- `SERVER.password`
- `SERVER.secret`
