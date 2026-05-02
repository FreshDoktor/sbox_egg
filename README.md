# s&box Dedicated Server - Pelican Egg

Pelican Egg and Docker image for the s&box Dedicated Server, running natively on Linux with .NET Runtime.

## Status / Disclaimer

This egg is experimental. The s&box dedicated server on native Linux is not officially supported by Facepunch and may break with any game update.
The initial startup may appear stuck — this is normal while assets are being downloaded. Monitor progress via the network graph in the panel.

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
| `GAME` | `facepunch.sandbox` | Game mode (e.g. `facepunch.sandbox`, `thieves.terrortown`) |
| `SERVER_NAME` | `s&box Server` | Server name in browser |
| `MAP` | (empty) | Map to load (empty = default) |
| `MAX_PLAYERS` | `8` | Maximum player count |
| `SBOX_EXTRA_ARGS` | (empty) | Additional startup arguments |
| `SBOX_AUTO_UPDATE` | `1` | Auto-update via SteamCMD on startup |
| `ENABLE_DIRECT_CONNECT` | `0` | Set to `1` to advertise direct connections and bypass Steam relay |
| `SERVER_PORT` | `27015` | UDP port — only used when `ENABLE_DIRECT_CONNECT=1` |
| `QUERY_PORT` | (empty) | Steam server browser query port, optional |
| `TOKEN` | (empty) | Steam Game Server Login Token, optional (hidden) |
| `SBOX_BRANCH` | (empty) | SteamCMD beta branch (hidden) |

## Building the Docker Image Locally

```bash
cd yolks/sbox
./build.sh
# or manually:
docker build -t ghcr.io/freshdoktor/yolks:sbox .
```

To build and push a beta image for testing on Wings without touching the production tag:

```bash
cd yolks/sbox
bash build.sh ghcr.io/freshdoktor/yolks:sbox-beta
docker push ghcr.io/freshdoktor/yolks:sbox-beta
```

In the Pelican panel, switch the server's Docker Image to `sbox-beta` under Startup to test it. Switch back to `sbox` once verified.

## Testing

```bash
docker run -it \
  -e GAME=facepunch.sandbox \
  -e SERVER_NAME=Test \
  -e MAX_PLAYERS=8 \
  -e SERVER_PORT=27015 \
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
