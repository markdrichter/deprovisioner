#!/usr/bin/env bash

# export CONFIG_YML=<your config.yml>
# sh build.sh <gcp-project> <gcp-bucket> <environment> <registry>

export GOOGLE_CLOUD_PROJECT=$1
export BUCKET=$2
export ENV=$3
export REGISTRY=$4
gcloud config set project $GOOGLE_CLOUD_PROJECT
gsutil -m cp -r gs://${BUCKET}/gam .
gsutil cp gs://${BUCKET}/config.${ENV}.yml config.yml
chmod +x gam/gam
docker build --build-arg CONFIG=$CONFIG_YML -f docker/Dockerfile --tag ${REGISTRY}/${GOOGLE_CLOUD_PROJECT}/deprovisioner .
rm -rf gam
docker push ${REGISTRY}/${GOOGLE_CLOUD_PROJECT}/deprovisioner:latest

