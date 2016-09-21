#! /bin/sh
# Do not change to /bin/bash; bash isn't installed on the build container

set -e

VERSION=$(cat ./version/number)
BUILT_RESOURCE=${PWD}/built-resource
FILENAME="pulse-ui-${ENVIRONMENT}-${VERSION}.txz"

mkdir -p ${BUILT_RESOURCE}/tmp/builds

cp -a -r ./cloud-ui-client-app/* /build

cd /build

PATH=$PATH:./node_modules/.bin

# Remove any existing builds, clean up dist folder.
rm -rf dist
rm -rf app/react
mkdir app/react

echo "Building React!"

# React build
NODE_ENV=production npm run build-js

echo "Building Ember!"

# Try to build ember
ember build --environment production

if [[ $? != 0 ]] ; then
  echo 'Ember build failed'
else
  echo "Build finished; tarring contents of dist directory into ${BUILT_RESOURCE}/$FILENAME"
  tar cfJ ${BUILT_RESOURCE}/$FILENAME ./dist/
fi
