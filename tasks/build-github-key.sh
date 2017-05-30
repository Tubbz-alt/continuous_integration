#!/bin/bash
OUTPUT_DIR=${PWD}/built-github-key
mkdir -p ${OUTPUT_DIR}
echo "Copying app contents..."
# note the trailing period after the app name; this is important to ensure that hidden files also get copied
cp -r ./cloud-ui-client-app/. ${OUTPUT_DIR}
echo "Copying github key.."
echo "${GITHUB_PRIVATE_KEY}" >> ${OUTPUT_DIR}/id_rsa
echo "Done"