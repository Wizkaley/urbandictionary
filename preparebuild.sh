#!/usr/bin/env bash


event=$1
echo Event :: $GITHUB_EVENT_NAME
echo service name :: $SERVICE_NAME
echo built at :: $(date --utc +%FT%T.%3NZ)
echo providerhref :: $GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID
echo elapsed :: $ELAPSED
echo duration :: $(($ELAPSED*1000000000))
echo builtat $(date --utc +%FT%T.%3NZ)
echo repourl :: $GITHUB_SERVER_URL/$GITHUB_REPOSITORY
# echo $DEV_SECOPS_HOST_TOKEN >> byob_secrets.json
# hosts=($(jq -r '.[].host' byob_secrets.json))
# tokens=($(jq -r '.[].byob_token' byob_secrets.json))
# for i in "${!hosts[@]}"; do
#     if [[ -z "${tokens[i]}" ]];then
#         continue
#     fi
    if [[ $event == "push" ]];then
        pull_request_number="NIL"
        # go run $GOPATH/src/github.kyndryl.net/MCMP-DevOps-Intelligence/dash_deploy/byobscript/postBuildsToDI.go ${hosts[i]} ${tokens[i]} $serviceName $BUILD_RUNID $providerHref $status $duration $builtat $TRAVIS_BRANCH $GITHUB_EVENT_NAME $pull_request_number $TRAVIS_COMMIT "$BUILD_ENGINE" $GITHUB_SERVER_URL $repourl
        ./buildscript/postBuildsToDI $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $pull_request_number $13 "$14" $15 $16
    elif [[ $event == "pull_request" ]];then
        # go run $GOPATH/src/github.kyndryl.net/MCMP-DevOps-Intelligence/dash_deploy/byobscript/postBuildsToDI.go ${hosts[i]} ${tokens[i]} $serviceName $BUILD_RUNID $providerHref $status $duration $builtat $TRAVIS_PULL_REQUEST_BRANCH $GITHUB_EVENT_NAME $TRAVIS_PULL_REQUEST $TRAVIS_COMMIT "$BUILD_ENGINE" $GITHUB_SERVER_URL $repourl
        ./buildscript/postBuildsToDI $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13 "$14" $15 $16
    fi
# done
