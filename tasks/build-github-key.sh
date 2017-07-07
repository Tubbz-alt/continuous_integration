#!/bin/bash
OUTPUT_DIR=${PWD}/built-github-key
# note the trailing period after the app name; this is important to ensure that hidden files also get copied
INPUT_DIR=./${APP_RESOURCE_NAME}/.
mkdir -p ${OUTPUT_DIR}
echo "Copying app contents..."
cp -r ${INPUT_DIR} ${OUTPUT_DIR}
echo "Copying github key.."
echo "${GITHUB_PRIVATE_KEY}" >> ${OUTPUT_DIR}/id_rsa
echo "Done"