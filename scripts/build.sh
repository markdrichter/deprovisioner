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



if [[ -z ${GO_SERVER_URL} ]]; then
  echo "Local dev environment detected"
  if [[ -f vars.sh ]]; then
    echo "Loading vars.sh"
    source vars.sh 2> /dev/null
  else
    cp vars.sh.example vars.sh
    echo "Fill the required environment variables on vars.sh"
    echo "file created for you. DO NOT COMMIT THIS FILE"
    exit 1
  fi
fi

IMAGE_NAME=${ROOT_NAME}_${ENV_TYPE}

buildContainer() {
  echo "Building container"
`which docker` build \
  --build-arg "ENV_TYPE=${ENV_TYPE}" \
  -t ${IMAGE_NAME} \
  -f docker/Dockerfile \
  .

}

tagPushContainer() {
  echo "Tagging container"
  docker tag \
    ${IMAGE_NAME} \
    ${REGISTRY}${IMAGE_NAME}:${PIPELINE_COUNTER}
  echo "Pushing container"
  docker push ${REGISTRY}${IMAGE_NAME}:${PIPELINE_COUNTER}
}

buildContainer
tagPushContainer

