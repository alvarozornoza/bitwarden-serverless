#!/usr/bin/env bash
set -e

function cleanup {
  serverless remove --stage ${STAGE} --region ${REGION}
}

trap cleanup EXIT
trap cleanup INT


./node_modules/.bin/eslint .

STAGE="test${GITHUB_RUN_ID:-$RANDOM}"
REGION=${REGION:-eu-west-3}

serverless deploy --stage ${STAGE} --region ${REGION}
API_URL=$(serverless info --stage ${STAGE} --region ${REGION} --verbose | grep ServiceEndpoint | cut -d":" -f2- | xargs) \
node_modules/.bin/mocha --timeout 10000 --require mocha-steps --require "@babel/register" --colors test/*

