#!/bin/bash -e

# Set up Python environment
export WHEELHOUSE=/build/wheelhouse
export PIP_WHEEL_DIR=$WHEELHOUSE
export PIP_FIND_LINKS=$WHEELHOUSE
mkdir -p $WHEELHOUSE
. /appenv/bin/activate

# Build hellomama-registration
cd /hellomama-registration
pip wheel --no-cache-dir .
pip install --no-index hellomama-registration
./manage.py collectstatic --noinput
rm -rf /build/hellomama-registration-static
cp -r static /build/hellomama-registration-static
