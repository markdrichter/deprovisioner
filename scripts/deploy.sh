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

# Deploys directly to App Engine

# Three environment variables contain GAM secrets

echo $CLIENT_SECRETS > client_secrets.json
echo $OAUTH2SERVICE > oauth2service.json
echo $OAUTH2TXT > oauth2.txt
gcloud app deploy --quiet
rm client_secrets.json
rm oauth2service.json
rm oauth2.txt
