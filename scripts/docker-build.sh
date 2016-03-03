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

# Make sure we have an up to date clone of the hellomama-registration repo.
if [ ! -d "hellomama-registration" ]; then
    git clone https://github.com/praekelt/hellomama-registration.git hellomama-registration
fi
(cd hellomama-registration; git checkout develop; git pull)

# Make sure we have an up to date clone of the seed-identity-store repo.
if [ ! -d "seed-identity-store" ]; then
    git clone https://github.com/praekelt/seed-identity-store.git seed-identity-store
fi
(cd seed-identity-store; git checkout develop; git pull)

# Make sure we have an up to date clone of the seed-stage-based-messaging repo.
if [ ! -d "seed-stage-based-messaging" ]; then
    git clone https://github.com/praekelt/seed-stage-based-messaging.git seed-stage-based-messaging
fi
(cd seed-stage-based-messaging; git checkout develop; git pull)

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
    --registration-dir "$(pwd)/hellomama-registration" \
    --identity-store-dir "$(pwd)/seed-identity-store" \
    --stage-based-messaging-dir "$(pwd)/seed-stage-based-messaging" \
    --tags-file "$TARGET_DIR/images.txt" \
    --tag-prefix "$REGISTRY"

# Push the images
for image in $(cat $TARGET_DIR/images.txt); do
    docker push $image
done
