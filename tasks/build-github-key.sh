#!/bin/bash
OUTPUT_DIR=${PWD}/built-github-key
mkdir -p ${OUTPUT_DIR}
echo "${GITHUB_PRIVATE_KEY}" >> ${OUTPUT_DIR}/id_rsa

