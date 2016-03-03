#!/bin/bash -e

export REGISTRY="qa-mesos-persistence.za.prk-host.net:5000/"

$REPO/scripts/docker-build.sh
