#!/usr/bin/env bash

# export CONFIG_YML=<your config.yml>
# sh build.sh <gcp-project> <gcp-bucket> <environment> <registry>

export GOOGLE_CLOUD_PROJECT=$1
export BUCKET=$2
export REGISTRY=$3
export CONFIG_YML=config.yml
gcloud config set project $GOOGLE_CLOUD_PROJECT
gsutil -m cp -r gs://${BUCKET}/gam .
chmod +x gam/gam
export THETAG=${REGISTRY}/${GOOGLE_CLOUD_PROJECT}/deprovisioner:latest
docker build --build-arg CONFIG=$CONFIG_YML -f docker/Dockerfile --tag ${THETAG} .
docker push ${REGISTRY}/${GOOGLE_CLOUD_PROJECT}/deprovisioner:latest
