#!/bin/bash -e

# Set up Python environment
export WHEELHOUSE=/build/wheelhouse
export PIP_WHEEL_DIR=$WHEELHOUSE
export PIP_FIND_LINKS=$WHEELHOUSE
mkdir -p $WHEELHOUSE
. /appenv/bin/activate

# All applications have been removed
