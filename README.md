# WIP s&box Dedicated Server - Pelican Egg WIP - CURRENTLY NOT FUNCTIONAL

Pelican Egg and Docker image for the s&box Dedicated Server, running natively on Linux with .NET Runtime.

## Overview

- **Docker Image**: `ghcr.io/freshdoktor/yolks:sbox`
- **Base**: `ghcr.io/parkervcp/yolks:ubuntu` with .NET 10 Runtime and SteamCMD
- **Steam App ID**: `1892930`
- **Stop Signal**: `^C` (SIGINT)

## Project Structure

```
.
├── egg-sbox.json                        # Pelican Egg definition
├── yolks/sbox/
│   ├── Dockerfile                       # Docker image (runtime)
│   ├── entrypoint.sh                    # Server startup script
│   └── build.sh                         # Local build script
├── scripts/
│   ├── install.sh                       # Readable copy of egg install script
│   └── entrypoint.sh                    # Readable copy of entrypoint script
└── .github/workflows/
    └── docker-publish.yml               # CI/CD: build + push to GHCR
```

The `scripts/` directory contains readable copies of the scripts embedded in `egg-sbox.json` and `yolks/sbox/entrypoint.sh` for easier review. The actual scripts used are the ones in the egg JSON and the Docker image.

### Install vs Runtime

- **Install** (`egg-sbox.json` script): Runs once in `ghcr.io/parkervcp/installers:ubuntu` as root. Downloads SteamCMD and s&box server files to `/mnt/server`.
- **Runtime** (`yolks/sbox/`): Custom image based on `ghcr.io/parkervcp/yolks:ubuntu` with .NET 10 Runtime and SteamCMD pre-installed. Runs the server via `dotnet sbox-server.dll` as non-root `container` user.

## Variables

| Variable | Default | Description |
|---|---|---|
| `GAME` | `facepunch.sandbox` | Game mode |
| `SERVER_NAME` | `s&box Server` | Server name in browser |
| `MAP` | (empty) | Map (empty = default) |
| `MAX_PLAYERS` | (empty) | Maximum player count |
| `SBOX_EXTRA_ARGS` | (empty) | Additional startup arguments |
| `SBOX_AUTO_UPDATE` | `1` | Auto-update via SteamCMD on startup |
| `TOKEN` | (empty) | Steam Game Server Login Token (hidden) |
| `SBOX_BRANCH` | (empty) | SteamCMD beta branch (hidden) |

## Building the Docker Image Locally

```bash
cd yolks/sbox
./build.sh
# or manually:
docker build -t ghcr.io/freshdoktor/yolks:sbox .
```

## Testing

```bash
docker run -it \
  -e GAME=facepunch.sandbox \
  -e SERVER_NAME=Test \
  -e SBOX_AUTO_UPDATE=1 \
  ghcr.io/freshdoktor/yolks:sbox
```

The server should start and output "Loading game" or "Server started".

## Pelican Installation

1. Import `egg-sbox.json` in the Pelican Panel under Eggs.
2. Create a new server and select the egg.
3. The image `ghcr.io/freshdoktor/yolks:sbox` is used automatically.

## CI/CD

The GitHub Actions workflow automatically builds and pushes the Docker image to `ghcr.io/freshdoktor/yolks:sbox` on:

- Push to `main` with changes to `yolks/sbox/Dockerfile`, `yolks/sbox/entrypoint.sh`, or the workflow itself
- Manual trigger via `workflow_dispatch`
