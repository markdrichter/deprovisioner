#!/usr/bin/env bash

#
# Copyright 2018,2019 Mark D. Richter
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# sh buils.sh <gcp-project> <gcp-bucket> <environment> <registry>

export GOOGLE_CLOUD_PROJECT=$1
export BUCKET=$2
export ENV=$3
export REGISTRY=$4
gcloud config set project $GOOGLE_CLOUD_PROJECT
gsutil -m cp -r gs://${BUCKET}/gam .
gsutil cp gs://${BUCKET}/config.${ENV}.yml .
chmod +x gam/gam
docker build -f docker/Dockerfile --tag ${REGISTRY}/${GOOGLE_CLOUD_PROJECT}/deprovisioner .
rm -rf gam
docker push ${REGISTRY}/${GOOGLE_CLOUD_PROJECT}/deprovisioner:latest

