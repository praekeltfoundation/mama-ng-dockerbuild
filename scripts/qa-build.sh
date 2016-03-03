#!/bin/bash -e

$REGISTRY="qa-mesos-persistence.za.prk-host.net:5000/"
export REGISTRY=$REGISTRY

$REPO_DIR/scripts/docker-build.sh
