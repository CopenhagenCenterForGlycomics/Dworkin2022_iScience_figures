#!/bin/sh

DOCKER_IMAGE=${DOCKER_IMAGE:-"figure_generation_pipeline:latest"}

docker run --rm -it -v "$PWD/mount":/home "figure_generation_pipeline:latest"

