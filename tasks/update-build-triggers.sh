#!/bin/bash

set -x

touch /tmp/deps.txt
touch /tmp/build.txt

pushd app-resource
  latest_commit=$(git rev-parse --verify HEAD)
  echo "$latest_commit" > /tmp/build.txt
  if [ -z "${dependency_paths}" ]; then
    echo "No dependency_paths param specified; only updating build.txt"
    dependency_diff=
  else
    touch ../build-triggers-resource/deps.txt
    for dependency_path in $dependency_paths
    do
      dependency_commit=$(git rev-list -1 HEAD ${dependency_path})
      echo "${dependency_path}=${dependency_commit}" >> /tmp/deps.txt
    done
    dependency_diff=$(git diff --shortstat ../build-triggers-resource/deps.txt /tmp/deps.txt)
  fi
popd

git clone build-triggers-resource updated-build-triggers
pushd updated-build-triggers
  git config --global user.email "nobody@concourse.ci"
  git config --global user.name "Concourse"
  if [ -z "$dependency_diff" ]; then
    # dependencies have not changed; update build.txt to kick off the build
    echo "No dependency changes to push; updating build.txt with latest commit"
    mv /tmp/build.txt .
    git add .
    git commit -m "Bumped revision in build.txt"
  else
    # dependencies have changed; update deps.txt to kick off rebuild of dependencies
    echo "Dependency changes found; updating deps.txt to reflect latest revisions."
    mv /tmp/deps.txt .
    git add .
    git commit -m "Updated dependency commits in deps.txt"
  fi
popd