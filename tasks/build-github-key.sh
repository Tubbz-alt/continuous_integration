#!/bin/bash
OUTPUT_DIR=${PWD}/built-github-key
echo "Copying app contents..."
mv ./cloud-ui-client-app ${OUTPUT_DIR}
echo "Copying github key.."
echo "${GITHUB_PRIVATE_KEY}" >> ${OUTPUT_DIR}/id_rsa
echo "Done"