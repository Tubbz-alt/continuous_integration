#!/bin/bash

deploy() {
  local TARFILE=${1}
  local TARGET_DIR=${2}

  if [ ! -s "${TARFILE}" ]; then
    echo "Sorry, we couldn't retrieve ${TARFILE}, exiting"
    exit 1
  fi

  echo "Ensuring ${TARGET_DIR} is usable..."
  mkdir -p "${TARGET_DIR}"

  if [ ! -w "${TARGET_DIR}" ]; then
    echo "Sorry, ${TARGET_DIR} is not writeable by us, exiting"
    exit 1
  fi

  echo "Beginning deploy..."

  echo "Chowning ${TARGET_DIR} to nginx:nginx"
  chown nginx:nginx "${TARGET_DIR}"

  echo "Cleaning up ${TARGET_DIR}..."
  rm -rf "${TARGET_DIR}/*"

  echo "Setting api-down.json"
  echo -n '{"message":"The API is currently unavailable. Please try again later."}' > "${TARGET_DIR}/api-down.json"

  echo "Deploying from ${TARFILE} to ${TARGET_DIR}"
  tar -xJvC "${TARGET_DIR}/" --strip-components=2 --no-same-owner -f "${TARFILE}"

  echo "Setting ping.txt to OK"
  echo -n 'OK' > "${TARGET_DIR}/ping.txt"

  echo "Setting ${TARGET_DIR} permissions"
  chmod -R u=rwX,g=rX,o=rX "${TARGET_DIR}"

  echo "restorecon on ${TARGET_DIR}"
  restorecon -Rv "${TARGET_DIR}"

  echo "deploy complete"
}

deploy $1 $2