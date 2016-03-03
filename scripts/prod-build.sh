#!/bin/bash -e

export REGISTRY="prd-mama-router.ng.prk-host.net:5000/"

$REPO_DIR/scripts/docker-build.sh
