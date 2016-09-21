#! /bin/sh

set -e

export TMPDIR=${TMPDIR:-/tmp}
export INPUT_DIR=./ci/tasks
export BUILT_RESOURCE=pulse-ui-rc

load_key() {
  local private_key_path=$TMPDIR/$1

  echo "$2" > $private_key_path

  if [ -s $private_key_path ]; then
    chmod 0600 $private_key_path
    SSH_ASKPASS=$INPUT_DIR/askpass.sh DISPLAY= ssh-add $private_key_path >/dev/null
  fi
}

start_ssh_agent(){
  eval $(ssh-agent) >/dev/null 2>&1
  mkdir -p ~/.ssh
  cat > ~/.ssh/config <<EOF
StrictHostKeyChecking no
LogLevel quiet
EOF
  chmod 0600 ~/.ssh/config
  trap stop_ssh_agent EXIT
}

stop_ssh_agent() {
  kill $SSH_AGENT_PID
}

start_ssh_agent
load_key remote-key "$REMOTE_PRIVATE_KEY"

if [ -n "$NAT_PRIVATE_KEY" ]; then
  load_key nat-key "$NAT_PRIVATE_KEY"
fi

TARFILE=$(ls -Art $BUILT_RESOURCE | grep txz | tail -n 1)

echo "Beginning deploy of built resource ($TARFILE) to remote hosts ${REMOTE_HOSTS}..."

NAT_PORT=22
REMOTE_PORT=22
STAGING_DIR=${STAGING_DIR:-"/tmp/builds"}
STAGED_TARFILE="${STAGING_DIR}/${TARFILE}"
if [ -n "$REMOTE_HOSTS" ]; then
  for REMOTE_HOST in $REMOTE_HOSTS
  do
    echo "Deploying to remote host ${REMOTE_HOST}"

    PROXY_CMD=
    if [ -n "$NAT_HOST" ]; then
      echo "Setting up remote proxy through NAT host ${NAT_HOST} with user ${NAT_USERNAME}"
      PROXY_CMD="-o ProxyCommand ssh -v ${NAT_USERNAME}@${NAT_HOST} -p ${NAT_PORT} '/usr/bin/nc ${REMOTE_HOST} ${REMOTE_PORT}'"
    fi

    echo "Ensuring staging dir (${STAGING_DIR}) exists on remote host"
    ssh "${PROXY_CMD}" ${REMOTE_USERNAME}@${REMOTE_HOST} "/bin/bash -c 'mkdir -p ${STAGING_DIR}'"
    echo "Copying ${TARFILE} and deploy-ui.sh to remote host"
    scp "${PROXY_CMD}" ${BUILT_RESOURCE}/${TARFILE} ${INPUT_DIR}/deploy-ui.sh ${REMOTE_USERNAME}@${REMOTE_HOST}:${STAGING_DIR}
    echo "Executing deploy-ui.sh on remote host"
    ssh "${PROXY_CMD}" ${REMOTE_USERNAME}@${REMOTE_HOST} "/bin/bash -c 'sudo ${STAGING_DIR}/deploy-ui.sh ${STAGED_TARFILE} ${REMOTE_DIR}; rm ${STAGING_DIR}/deploy-ui.sh'"
    echo "Deploy to remote host ${REMOTE_HOST} complete"
  done
fi

echo "All done; deploy complete."