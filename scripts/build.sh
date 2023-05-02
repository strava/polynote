#!/usr/bin/env bash


# package your code
(cd ..; sbt dist)

# Build and push Docker images for Polynote.
# set polynote specific variables
export POLYNOTE_VERSION=0.5.1
export SCALA_VERSION=2.12
export SPARK_VERSION=3.3.1

# Build and push Docker image with a commit and branch tag
set -e

# GIT_BRANCH=test
# GIT_SHA=1234556

if [ -z "$GIT_SHA" ]; then
    echo "Environment variable \$GIT_SHA expected to be set (by Butler)"
    exit 1
fi

if [ -z "$GIT_BRANCH" ]; then
    echo "Environment variable \$GIT_BRANCH expected to be set (by Butler)"
    exit 1
fi

REPO="docker.strava.com/polynote/polynote"
COMMIT_TAG="$REPO:$GIT_SHA"

# Can we potentially just upgrade JDK in-line to avoid dealing with two images?
docker build -t $COMMIT_TAG --build-arg POLYNOTE_VERSION=$POLYNOTE_VERSION --build-arg SCALA_VERSION=$SCALA_VERSION --build-arg SPARK_VERSION=$SPARK_VERSION ./docker/dev

# only push a new image if we are merging to main
if [[ "$GIT_BRANCH" == "main" ]]; then
    BRANCH_TAG="$REPO:$GIT_BRANCH"
    docker tag $COMMIT_TAG $BRANCH_TAG

    # docker push $REPO:latest-base
    docker push $COMMIT_TAG
    docker push $BRANCH_TAG
fi
