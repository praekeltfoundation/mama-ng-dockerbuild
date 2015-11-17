#!/bin/bash -e

BUILD_BASE="NO"
BUILD_BUILDER="NO"
TAG_LATEST="YES"
TAG_PREFIX=""
EXTRA_RUNARGS=""

BASE_DIR="$(pwd)"
VERSION_TAG=`date +%Y%m%d%H%M`

while [[ $# > 0 ]]; do
    key="$1"; shift

    case "$key" in
        -a|--all)
            BUILD_BASE="YES"
            BUILD_BUILDER="YES"
            ;;
        --no-latest)
            TAG_LATEST="NO"
            ;;
        --version-tag)
            VERSION_TAG="$1"; shift
            ;;
        --base-dir)
            BASE_DIR="$1"; shift
            ;;
        --build-requirements-dir)
            BUILD_REQUIREMENTS_DIR="$1"; shift
            ;;
        --app-dir)
            APP_DIR="$1"; shift
            ;;
        --tags-file)
            TAGS_FILE="$1"; shift
            ;;
        --tag-prefix)
            TAG_PREFIX="$1"; shift
            ;;
        --extra-runargs)
            EXTRA_RUNARGS="$1"; shift
            ;;
        *)
            # Unknown option
            echo "Unknown parameter: $key" 1>&2
            exit 1
            ;;
    esac
done

# Set APP_DIR and BUILD_REQUIREMENTS_DIR to default if not provided
APP_DIR="${APP_DIR-$BASE_DIR/application}"
BUILD_REQUIREMENTS_DIR="${BUILD_REQUIREMENTS_DIR-$BASE_DIR}"

function writetag() {
    local tag="$1"; shift

    if [ -n "$TAGS_FILE" ]; then
        echo "$tag" >> $TAGS_FILE
    fi
}

function mkimage() {
    local name="$1"; shift
    local dir="$BASE_DIR/${1-docker}"; shift || true

    local versiontag="$TAG_PREFIX$name:$VERSION_TAG"
    docker build --pull=false -t $versiontag -f $dir/$name.dockerfile $dir
    writetag $versiontag
    if [ "$TAG_LATEST" = "YES" ]; then
        local latesttag="$TAG_PREFIX$name:latest"
        docker tag -f $versiontag $latesttag
        if [ -n "$TAG_PREFIX" ]; then
            docker tag -f $versiontag "$name:latest"
        fi
        writetag $latesttag
    fi
}

function runimage() {
    image=$1; shift
    docker images | grep -q "^$image\\s\\+latest" || {
        echo "Image $image:latest not found"
        exit 1
    }
    docker run --rm $EXTRA_RUNARGS "$@" $image
}

function buildapp() {
    local REQ_DIR="$BASE_DIR/docker/build/"
    cp "$BUILD_REQUIREMENTS_DIR"/requirements.txt "$REQ_DIR"
    cp "$BUILD_REQUIREMENTS_DIR"/package.json "$REQ_DIR"
    runimage "$@" \
             -v "$APP_DIR":/application \
             -v "$BASE_DIR"/docker/build:/build
}

if [ "$BUILD_BASE" = "YES" ]; then
    echo "Building base image..."
    mkimage mama-ng-base docker-base
fi

if [ "$BUILD_BUILDER" = "YES" ]; then
    echo "Building builder image..."
    mkimage mama-ng-builder docker-base
fi

# Build app in builder image
echo "Building app in builder container..."
buildapp mama-ng-builder

# Build run images
echo "Building run image..."
mkimage mama-ng-run

echo "Building infr images..."
mkimage go-metrics-api
mkimage jssandbox
mkimage vumi-http-api
mkimage vumi
mkimage vxfreeswitch

echo "Building app images..."
# TODO

echo "Done."