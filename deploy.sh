#!/bin/bash -e

R=`dirname $0`

rm -rf $R/.build
cactus build

set -x
aws s3 sync $R/.build s3://engineers.coffee --exclude "*.mp3" --cache-control max-age=300
aws s3 sync $R/.build s3://engineers.coffee --include "*.mp3" --cache-control max-age=600
