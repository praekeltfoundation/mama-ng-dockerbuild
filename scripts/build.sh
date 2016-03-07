#!/bin/bash -e

# Prepare folders
REPO_DIR="$(pwd)/$REPO"
mkdir -p $REPO_DIR/docker/build
TARGET_DIR="$BUILDDIR/mama-ng-dockerbuild"
mkdir $TARGET_DIR

# Build the images
$REPO_DIR/build-images.sh --all \
    --base-dir "$REPO_DIR" \
    --tags-file "$TARGET_DIR/images.txt" \
    --tag-prefix "qa-mesos-persistence.za.prk-host.net:5000/"

# Push the images
for image in $(cat $TARGET_DIR/images.txt); do
    docker push $image
done
