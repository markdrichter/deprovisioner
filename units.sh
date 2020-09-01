#!/bin/sh

export REGISTRY=$1
export CONTAINER=$2
docker run -it $REGISTRY/$CONTAINER rspec spec/units --format documentation
