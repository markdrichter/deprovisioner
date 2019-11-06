#!/bin/sh

gcloud config set project $1
gsutil cp gs://$2/vars.sh .
chmod +x vars.sh
. ./vars.sh
echo $CLIENT_SECRETS >./gam/src/client_secrets.json
echo $OAUTH2SERVICE >./gam/src/oauth2service.json
echo $OAUTH2TXT >./gam/src/oauth2.txt
alias 
python /app/gam/src/gam.py $3 $4 $5 $6 $7 $8 $9 $10 $11 $12