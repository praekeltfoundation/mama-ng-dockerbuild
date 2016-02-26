#!/bin/bash -e

BUILD_BASE="NO"
BUILD_BUILDER="NO"
BUILD_WHEELS="YES"
BUILD_CONTROL="YES"
BUILD_CONTENTSTORE="YES"
BUILD_SCHEDULER="YES"
BUILD_REGISTRATION="YES"
BUILD_IDENTITY_STORE="YES"
BUILD_STAGE_BASED_MESSAGING="YES"
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
        --no-control)
            BUILD_CONTROL="NO"
            ;;
        --no-contentstore)
            BUILD_CONTENTSTORE="NO"
            ;;
        --no-scheduler)
            BUILD_SCHEDULER="NO"
            ;;
        --no-registration)
            BUILD_REGISTRATION="NO"
            ;;
        --no-identity-store)
            BUILD_IDENTITY_STORE="NO"
            ;;
        --no-stage-based-messaging)
            BUILD_STAGE_BASED_MESSAGING="NO"
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
        --registration-dir)
            REGISTRATION_DIR="$1"; shift
            ;;
        --identity-store-dir)
            IDENTITY_STORE_DIR="$1"; shift
            ;;
        --stage-based-messaging-dir)
            STAGE_BASED_MESSAGING_DIR="$1"; shift
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
REGISTRATION_DIR="${REGISTRATION_DIR-$BASE_DIR/hellomama-registration}"
IDENTITY_STORE_DIR="${IDENTITY_STORE_DIR-$BASE_DIR/seed-identity-store}"
STAGE_BASED_MESSAGING_DIR="${STAGE_BASED_MESSAGING_DIR-$BASE_DIR/seed-stage-based-messaging}"

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
             -v "$REGISTRATION_DIR":/hellomama-registration \
             -v "$IDENTITY_STORE_DIR":/seed-identity-store \
             -v "$STAGE_BASED_MESSAGING_DIR":/seed-stage-based-messaging \
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

if [ "$BUILD_REGISTRATION" = "YES" ]; then
    echo "Building registration image..."
    mkimage hellomama-registration
fi

if [ "$BUILD_IDENTITY_STORE" = "YES" ]; then
    echo "Building identity store image..."
    mkimage seed-identity-store
fi

if [ "$BUILD_STAGE_BASED_MESSAGING" = "YES" ]; then
    echo "Building stage-based messaging image..."
    mkimage seed-stage-based-messaging
fi


echo "Done."
