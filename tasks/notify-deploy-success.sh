#! /bin/sh

set -e -x

if [ -z "$FLOW_TOKEN" ]; then
  echo "Must specify FLOW_TOKEN task param in order to perform flowdock notification."
  exit 1
fi

VERSION=$(ls -Art ./pulse-ui-rc | grep txz | tail -n 1 | sed 's/pulse-ui-*//' | sed -e 's/\.txz$//')

cd ./cloud-ui-client-app

REPO=`git remote -v | head -n 1 | awk -v N=2 '{print $N}'`
COMMIT=`git rev-parse HEAD`
MESSAGE=`git log -1 --format=format:%B`
AUTHOR=`git log -1 --format=format:%an`
AUTHOR_DATE=`git log -1 --format=format:%ai`
BRANCH=`git show-ref --heads | sed -n "s/^$(git rev-parse HEAD) refs\/heads\/\(.*\)/\1/p"`
GIT_TAGS=$(git tag --points-at HEAD)

formatUserTags(){
local USERS="$1"
local TAGS=
for user in $USERS; do
  if [ -n "$TAGS" ]; then
    TAGS="${TAGS}, \"@${user}\""
  else
    TAGS="\"@${user}\""
  fi
done
echo $TAGS
}

USER_TAGS=$(formatUserTags "${USERS_TO_NOTIFY}")
PAYLOAD=$(cat <<-END
'{
  "flow_token": "${FLOW_TOKEN}",
  "event": "activity",
  "author": {
    "name": "Pwnie Engineer Notifications"
  },
  "tags": [
    ${USER_TAGS}
  ],
  "title": "Build ${VERSION} of cloud-ui-client-app deployed to ${ENVIRONMENT}",
  "external_thread_id": "deploy:cloud-ui-client-app:${VERSION}:${ENVIRONMENT}",
  "thread": {
    "title": "${ENVIRONMENT} - Build ${VERSION} of cloud-ui-client-app",
    "fields": [
      {
        "label": "environment",
        "value": "${ENVIRONMENT}"
      },
      {
        "label": "version",
        "value": "${VERSION}"
      },
      {
        "label": "repository",
        "value": "${REPO}"
      },
      {
        "label": "branch",
        "value": "${BRANCH}"
      },
      {
        "label": "commit",
        "value": "${COMMIT}"
      },
      {
        "label": "commit_message",
        "value": "${MESSAGE}"
      },
      {
        "label": "author",
        "value": "${AUTHOR}"
      },
      {
        "label": "author_date",
        "value": "${AUTHOR_DATE}"
      },
      {
        "label": "tags",
        "value": "${GIT_TAGS}"
      }
    ],
    "body": "A new version of cloud-ui-client-app has been built and deployed to ${ENVIRONMENT}.",
    "external_url": "http://concourse1bq:8080/pipelines/pulse-ui/jobs/deploy-rc",
    "status": {
      "color": "green",
      "value": "deployed"
    }
  }
}'
END
)

CURL_CMD=$(cat <<-END
curl -i -X POST -H 'Content-Type: application/json' -d ${PAYLOAD} https://api.flowdock.com/messages
END
)
eval $CURL_CMD # have to do it this stupid way to avoid issues with string quoting in  bash variables
