# HLS Proxy en Docker

Docker container to run HLS Proxy Server, an HLS streaming server with restreaming capabilities and EPG management.

**[Documentación en Español](README_es.md)**

## Docker Hub Images

Pre-built images are available at: **[https://hub.docker.com/r/jopsis/hlsproxy](https://hub.docker.com/r/jopsis/hlsproxy)**

To use the image directly from Docker Hub:
```bash
docker pull jopsis/hlsproxy:latest
```

### Automated CI/CD

This repository includes a GitHub Actions workflow that:
- **Push to main**: Automatically builds and publishes with the `latest` tag
- **Version tags**: When creating a tag, builds and publishes with the **exact tag name**
- Builds for `linux/amd64` and `linux/arm64` platforms
- Uses GitHub Actions cache to speed up builds

#### Tag usage examples

```bash
# Create and publish a new version
git tag v8.4.8
git push origin v8.4.8
```

This will automatically generate on Docker Hub:
- `jopsis/hlsproxy:v8.4.8` (exact tag name)
- `jopsis/hlsproxy:latest` (always updated from main)

#### Requirements

For the workflow to work, you must configure the following secrets in your GitHub repository:
- `DOCKER_HUB_USR`: Your Docker Hub username
- `DOCKER_HUB_PWD`: Your Docker Hub access token (or password)

## Dockerfile

The Dockerfile creates a **multiplatform** image based on Ubuntu that supports ARM64 and x86_64 architectures.

### Features

- **Base**: Ubuntu latest
- **Exposed port**: 38050
- **Supported architectures**:
  - linux/arm64 (aarch64)
  - linux/amd64 (x86_64)
- **Installed dependencies**:
  - `wget`: To download the HLS Proxy binary
  - `unzip`: To decompress the downloaded file
  - `mc`: Midnight Commander for file management
  - `nano`: Text editor
  - `ffmpeg`: For video stream processing
  - `tzdata`: Timezone configuration (Europe/Berlin)

### Build process

1. Updates and installs necessary packages
2. Configures timezone to Europe/Berlin
3. **Automatically detects system architecture** (`uname -m`)
4. Downloads the correct HLS Proxy v8.4.8 binary based on architecture:
   - ARM64: `hls-proxy-8.4.8.linux-arm64.zip`
   - x86_64: `hls-proxy-8.4.8.linux-x64.zip`
5. Decompresses and cleans temporary files to reduce image size
6. Sets execution permissions for `/opt/hls-proxy`
7. Defines the container startup command

The image automatically detects the platform during build, so you don't need to manually specify which version to download.

## Configuration: local.json

The `local.json` file contains the HLS Proxy server configuration:

### Server
```json
"SERVER": {
    "address": "0.0.0.0",           // Listen on all interfaces
    "port": 38050,                   // Server port
    "password": "changeme",          // Access password (change in production)
    "secret": "changeme",            // Secret key (change in production)
    "isAllowUsersWithAnyToken": true,
    "isRestreamer": true             // Enable restreaming functionality
}
```

### EPG (Electronic Program Guide)
```json
"epg": {
    "tvGuideUrl": [                  // EPG guide URLs
        "https://raw.githubusercontent.com/davidmuma/EPG_dobleM/refs/heads/master/guiaiptv.xml",
        "https://www.tdtchannels.com/epg/TV.xml.gz"
    ],
    "historyDays": 2,                // EPG history days
    "isAddUrlEpgToEXTINF": true
}
```

### Streaming Configuration
- `maxSimultaneousStreamCountPerClientDefault`: 100 simultaneous streams per client
- `safeChunkSeq`: 3 safety chunks
- `fastStartChunks`: 4 chunks for fast start
- `getTsChunkRetries`: 4 retries to get chunks
- `retriesForError403/404`: Retries for HTTP errors
- `httpResponseStallTimeout`: 45000ms timeout
- `preferableBandwidth`: 800000 bps

### Enabled Features
- `isXtreamCodesApiEnabled`: true - Xtream Codes API active
- `isHtmlPlayerEnabled`: true - HTML player active
- `isPlaylistAvailableFromOutside`: true - Playlists externally accessible
- `isCacheInMemory`: false - Disk cache
- `isReadChunksFromCacheDir`: true - Read chunks from cache

### Recording
```json
"RECORDING": {
    "isEnabled": false               // Recording disabled by default
}
```

## Usage

### Building the image

#### Simple build (current platform)
```bash
docker build -t hlsproxy .
```

#### Multiplatform build with buildx
To build images for both architectures (ARM64 and x86_64):

```bash
# Create a multiplatform builder (first time only)
docker buildx create --name multiplatform --use

# Build for multiple platforms
docker buildx build --platform linux/amd64,linux/arm64 -t your-user/hlsproxy:latest .

# Build and push to a registry
docker buildx build --platform linux/amd64,linux/arm64 -t your-user/hlsproxy:latest --push .
```

#### Build for a specific platform
```bash
# ARM64 only
docker buildx build --platform linux/arm64 -t hlsproxy:arm64 --load .

# x86_64/AMD64 only
docker buildx build --platform linux/amd64 -t hlsproxy:amd64 --load .
```

### Running the container

#### Using local image
```bash
docker run -d -p 38050:38050 -v $(pwd)/local.json:/opt/local.json hlsproxy
```

#### Using Docker Hub image
```bash
docker run -d -p 38050:38050 -v $(pwd)/local.json:/opt/local.json jopsis/hlsproxy:latest
```

## Security Notes

**IMPORTANT**: Before using in production, change the following values in `local.json`:
- `SERVER.password`
- `SERVER.secret`
