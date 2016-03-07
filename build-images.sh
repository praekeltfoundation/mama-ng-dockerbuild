#!/bin/bash -e

BUILD_BASE="NO"
BUILD_BUILDER="NO"
BUILD_WHEELS="YES"
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
        --no-latest)
            TAG_LATEST="NO"
            ;;
        --version-tag)
            VERSION_TAG="$1"; shift
            ;;
        --base-dir)
            BASE_DIR="$1"; shift
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
    runimage "$@" \
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

echo "Done."
