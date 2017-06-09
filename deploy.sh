#!/bin/bash -e

if [[ $# -ne 1 ]]; then
	echo "$0 <episode number>"
	exit 1
fi

episode=$1
epath=static/episodes/2017/engineers.coffee.2017.${episode}.mp3

R=`dirname $0`

rm -rf $R/.build
cactus build

set -x

aws s3 sync $R/.build s3://engineers.coffee --exclude "*.mp3" --cache-control max-age=600 --profile analog

aws s3 cp $R/.build/${epath} s3://engineers.coffee/${epath} --cache-control max-age=1800 --profile analog


# Cloudfront invalidation
INVALIDATION_ID=$(date +"%s")
INVALIDATION_JSON="{
    \"DistributionId\": \"ETIZ8M4U1N92S\",
    \"InvalidationBatch\": {
        \"Paths\": {
            \"Quantity\": 3,
            \"Items\": [
                \"/rss.xml\",
                \"/index.html\",
		\"/\"
            ]
        },
        \"CallerReference\": \"$INVALIDATION_ID\"
    }
}"

aws cloudfront create-invalidation --cli-input-json "$INVALIDATION_JSON" --profile analog
