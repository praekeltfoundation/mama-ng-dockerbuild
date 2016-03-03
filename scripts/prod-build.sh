#!/bin/bash -e

$REGISTRY="prd-mama-router.ng.prk-host.net:5000/"
export REGISTRY=$REGISTRY

$REPO_DIR/scripts/docker-build.sh
