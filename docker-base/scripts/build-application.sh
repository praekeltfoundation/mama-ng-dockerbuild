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
