#!/bin/bash
OUTPUT_DIR=${PWD}/built-github-key
mkdir -p ${OUTPUT_DIR}
echo "Copying github key.."
echo "${GITHUB_PRIVATE_KEY}" >> ${OUTPUT_DIR}/id_rsa
echo "Copying app contents..."
cp -a -r ./cloud-ui-client-app/* ${OUTPUT_DIR}
echo "Done"