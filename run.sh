#!/bin/sh

if [ ${CLIENT_SECRETS} ] 
then
  echo "production environment detected"
	fi
ruby /app/lib/engine.rb $*
