#!/bin/sh

if [ ${CLIENT_SECRETS} ] 
then
  echo "production environment detected"
	gcloud config set project $1
	gsutil cp gs://$2/vars.sh .
	chmod +x vars.sh
	. ./vars.sh
	echo $CLIENT_SECRETS >./gam/src/client_secrets.json
	echo $OAUTH2SERVICE >./gam/src/oauth2service.json
	echo $OAUTH2TXT >./gam/src/oauth2.txt
	fi
ruby $HOME/deprovisioner/lib/engine.rb $*
