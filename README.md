# Deprovisioner

An account deprovisioning platform for heterogeneous systems.

## Commands

Here is a list of "commands" this tool supports. Some commands might encapsulate other commands.

* **deprovision user account_id** - Executes a work-flow with G Suite, Okta and other systems to 
deprovision a user when they leave the company. This command potentially can execute such 
a work-flow across heterogenous apps.
* **deprovision users** - Run **deprovision user** for all deprovisionable accounts.
* **get deprovisionable** - Produces a list of suspended accounts that were last accessed more than thirty days in the past.
* **get suspended** - Produces a list of suspended accounts and the date they were last accessed.
* **clear oauth** - Removes OAuth grants from all suspended accounts.
* **clear oauth account_id** - Removes OAuth grants from a particular account.
* **unsubscribe groups account_id** - Removes account_id as a member of all groups of which it is a member.
* **version** - Reveals the version of the Deprovisioner software you are using

## Dependencies

GAM (Google Apps Manager). This is downloaded and injected into the container during build.

## Build

Modify scripts/build.sh for _your_ container registry.
Run scripts/build.sh.

## Test

Run tests inside the container like this:

docker run -it [your_container_name] /app/units.sh

## Use

Once inside the container, you will need to configure GAM to work with your secret keys by running `gam info domain` and following the prompts.
With GAM configured, you will be able to run any of the commands listed above.

## Legal

Copyright 2018,2019 Mark D. Richter

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

