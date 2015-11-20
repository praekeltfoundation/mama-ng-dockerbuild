#!/bin/bash -e
set -x

# Set up Python environment
export WHEELHOUSE=/build/wheelhouse
export PIP_WHEEL_DIR=$WHEELHOUSE
export PIP_FIND_LINKS=$WHEELHOUSE
mkdir -p $WHEELHOUSE
. /appenv/bin/activate

# Install requirements
pip wheel --no-cache-dir -r /build/requirements.txt

# Build node_modules
cd /build
rm -rf /build/node_modules
npm install --production

# Build mama-ng-control
cd /mama-ng-control
pip wheel --no-cache-dir .
# No collectstatic to do but some static files to include
rm -rf /build/mama-ng-control-static
cp -r static /build/mama-ng-control-static

# Build mama-ng-contentstore
cd /mama-ng-contentstore
pip wheel --no-cache-dir .
pip install --no-index mama-ng-contentstore
./manage.py collectstatic --noinput
rm -rf /build/mama-ng-contentstore-static
cp -r static /build/mama-ng-contentstore-static
