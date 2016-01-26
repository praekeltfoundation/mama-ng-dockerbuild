#!/bin/bash -e

BUILD_BASE="NO"
BUILD_BUILDER="NO"
BUILD_WHEELS="YES"
BUILD_INFR="YES"
BUILD_CONTROL="YES"
BUILD_CONTENTSTORE="YES"
BUILD_SCHEDULER="YES"
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
        --no-wheels)
            BUILD_WHEELS="NO"
            ;;
        --no-infr)
            BUILD_INFR="NO"
            ;;
        --no-control)
            BUILD_CONTROL="NO"
            ;;
        --no-contentstore)
            BUILD_CONTENTSTORE="NO"
            ;;
        --no-scheduler)
            BUILD_SCHEDULER="NO"
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
        --control-dir)
            CONTROL_DIR="$1"; shift
            ;;
        --contentstore-dir)
            CONTENTSTORE_DIR="$1"; shift
            ;;
        --scheduler-dir)
            SCHEDULER_DIR="$1"; shift
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

# Set BUILD_REQUIREMENTS_DIR and app directories to default if not provided
BUILD_REQUIREMENTS_DIR="${BUILD_REQUIREMENTS_DIR-$BASE_DIR}"
CONTROL_DIR="${CONTROL_DIR-$BASE_DIR/mama-ng-control}"
CONTENTSTORE_DIR="${CONTENTSTORE_DIR-$BASE_DIR/mama-ng-contentstore}"
SCHEDULER_DIR="${SCHEDULER_DIR-$BASE_DIR/mama-ng-scheduler}"

function writetag() {
    local tag="$1"; shift

    if [ -n "$TAGS_FILE" ]; then
        echo "$tag" >> $TAGS_FILE
    fi
}

function mkimage() {
    local name="$1"; shift
    local dir="${1-$BASE_DIR/docker}"; shift || true
    local dockerfile="$dir/${1-$name.dockerfile}"; shift || true

    local versiontag="$TAG_PREFIX$name:$VERSION_TAG"
    docker build --pull=false -t $versiontag -f $dockerfile $dir
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
             -v "$CONTROL_DIR":/mama-ng-control \
             -v "$CONTENTSTORE_DIR":/mama-ng-contentstore \
             -v "$BASE_DIR"/docker/build:/build
}

if [ "$BUILD_BASE" = "YES" ]; then
    echo "Building base image..."
    mkimage mama-ng-base $BASE_DIR/docker-base
fi

if [ "$BUILD_BUILDER" = "YES" ]; then
    echo "Building builder image..."
    mkimage mama-ng-builder $BASE_DIR/docker-base
fi

# Build app in builder image
if [ "$BUILD_WHEELS" = "YES" ]; then
    echo "Building app in builder container..."
    buildapp mama-ng-builder
fi

# Build run images
echo "Building run image..."
mkimage mama-ng-run

if [ "$BUILD_INFR" = "YES" ]; then
    echo "Building infr images..."
    mkimage go-metrics-api
    mkimage jssandbox
    mkimage vumi-http-api
    mkimage vumi
    mkimage vxfreeswitch
fi

if [ "$BUILD_CONTROL" = "YES" ]; then
    echo "Building mama-ng-control image..."
    mkimage mama-ng-control
fi
if [ "$BUILD_CONTENTSTORE" = "YES" ]; then
    echo "Building mama-ng-contentstore image..."
    mkimage mama-ng-contentstore
fi

if [ "$BUILD_SCHEDULER" = "YES" ]; then
    echo "Building scheduler image..."
    mkimage mama-ng-scheduler $SCHEDULER_DIR Dockerfile
fi

echo "Done."
