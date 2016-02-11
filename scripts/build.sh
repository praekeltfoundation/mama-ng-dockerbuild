#!/bin/bash -e

# Make sure we have an up to date clone of the mama-ng-control repo.
if [ ! -d "mama-ng-control" ]; then
    git clone https://github.com/praekelt/mama-ng-control.git mama-ng-control
fi
(cd mama-ng-control; git checkout develop; git pull)

# Make sure we have an up to date clone of the mama-ng-contentstore repo.
if [ ! -d "mama-ng-contentstore" ]; then
    git clone https://github.com/praekelt/mama-ng-contentstore.git mama-ng-contentstore
fi
(cd mama-ng-contentstore; git checkout develop; git pull)

# Make sure we have an up to date clone of the mama-ng-scheduler repo.
if [ ! -d "mama-ng-scheduler" ]; then
    git clone https://github.com/praekelt/mama-ng-scheduler.git mama-ng-scheduler
fi
(cd mama-ng-scheduler; git checkout develop; git pull)

# Make sure we have an up to date clone of the hellomama-registration repo.
if [ ! -d "hellomama-registration" ]; then
    git clone https://github.com/praekelt/hellomama-registration.git hellomama-registration
fi
(cd hellomama-registration; git checkout develop; git pull)

# Prepare folders
REPO_DIR="$(pwd)/$REPO"
mkdir -p $REPO_DIR/docker/build
TARGET_DIR="$BUILDDIR/mama-ng-dockerbuild"
mkdir $TARGET_DIR

# Build the images
$REPO_DIR/build-images.sh --all \
    --base-dir "$REPO_DIR" \
    --control-dir "$(pwd)/mama-ng-control" \
    --contentstore-dir "$(pwd)/mama-ng-contentstore" \
    --scheduler-dir "$(pwd)/mama-ng-scheduler" \
    --registration-dir "$(pwd)/hellomama-registration" \
    --tags-file "$TARGET_DIR/images.txt" \
    --tag-prefix "qa-mesos-persistence.za.prk-host.net:5000/"

# Push the images
for image in $(cat $TARGET_DIR/images.txt); do
    docker push $image
done
