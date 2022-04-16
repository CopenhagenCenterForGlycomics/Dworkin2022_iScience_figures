#!/bin/sh

DOCKER_IMAGE=${DOCKER_IMAGE:-"figure_generation_pipeline:latest"}

docker run --rm -it --entrypoint /bin/bash -v "$PWD/input":/results/input "figure_generation_pipeline:latest"
# docker run --rm -it -v "$PWD/input/":/results/input "figure_generation_pipeline:latest:
# docker run --rm -it -v "$PWD/":"$PWD" -w "$PWD" "$DOCKER_IMAGE"

