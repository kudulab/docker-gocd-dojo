#!/bin/bash

set -e

BRANCH=${BRANCH:-master}

cd /ide/work
if [ -z "$REPO" ]; then
  # repository is not set, just built with local contents
  echo "Building Go from local workspace at /ide/work"
elif [ -n "$COMMIT" ]; then
  echo "Building Go from ${REPO} commit ${COMMIT}"
  git remote add build "${REPO}"
  git fetch build
  git checkout "$COMMIT"
else
  echo "Building Go from ${REPO} branch ${BRANCH}"
  git fetch "${REPO}" "${BRANCH}"
  git reset --hard FETCH_HEAD
fi

gradle clean prepare fatJar
