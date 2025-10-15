# hlsproxy-docker

Contenedor Docker para ejecutar HLS Proxy Server, un servidor de streaming HLS con capacidades de restreaming y gestión de EPG.

## Dockerfile

El Dockerfile crea una imagen basada en Ubuntu que incluye:

- **Base**: Ubuntu latest
- **Puerto expuesto**: 38050
- **Dependencias instaladas**:
  - `wget`: Para descargar el binario de HLS Proxy
  - `mc`: Midnight Commander para gestión de archivos
  - `nano`: Editor de texto
  - `ffmpeg`: Para procesamiento de streams de video
  - `tzdata`: Configuración de zona horaria (Europe/Berlin)

### Proceso de construcción

1. Actualiza e instala paquetes necesarios
2. Configura la zona horaria a Europe/Berlin
3. Descarga HLS Proxy v8.4.8 (linux-arm64) desde hls-proxy.com
4. Limpia archivos temporales y caché para reducir el tamaño de la imagen
5. Establece permisos de ejecución para `/opt/hls-proxy`
6. Define el comando de inicio del contenedor

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
```bash
docker build -t hlsproxy .
```

### Ejecutar el contenedor
```bash
docker run -d -p 38050:38050 -v $(pwd)/local.json:/opt/local.json hlsproxy
```

## Notas de Seguridad

**IMPORTANTE**: Antes de usar en producción, cambia los siguientes valores en `local.json`:
- `SERVER.password`
- `SERVER.secret`
