#!/bin/bash -e

export REGISTRY="qa-mesos-persistence.za.prk-host.net:5000/"

$REPO_DIR/scripts/docker-build.sh
