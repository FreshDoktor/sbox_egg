#!/bin/bash
set -e
IMAGE="${1:-ghcr.io/freshdoktor/yolks:sbox}"
echo "Building image: ${IMAGE}"
docker build -t "${IMAGE}" .
echo "Done. To push: docker push ${IMAGE}"
