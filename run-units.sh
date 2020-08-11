#!/bin/sh

docker run -it $REGISTRY/$CONTAINER:$VERSION rspec spec/units --format documentation
