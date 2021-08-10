#!/usr/bin/env bash


event=$1
echo Event :: $GITHUB_EVENT_NAME
echo service name :: $SERVICE_NAME
echo built at :: $(date --utc +%FT%T.%3NZ)
echo providerhref :: $GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID
echo elapsed :: $ELAPSED
echo status :: $status
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
        ./buildscript/postBuildsToDI $2 $3 $SERVICE_NAME $BUILD_RUN_ID "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID" $status $duration "$(date --utc +%FT%T.%3NZ)" $BUILD_BRANCH $GITHUB_EVENT_NAME $pull_request_number $BUILD_COMMIT "$BUILD_ENGINE" $GITHUB_SERVER_URL "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY"
    elif [[ $event == "pull_request" ]];then
        # go run $GOPATH/src/github.kyndryl.net/MCMP-DevOps-Intelligence/dash_deploy/byobscript/postBuildsToDI.go ${hosts[i]} ${tokens[i]} $serviceName $BUILD_RUNID $providerHref $status $duration $builtat $TRAVIS_PULL_REQUEST_BRANCH $GITHUB_EVENT_NAME $TRAVIS_PULL_REQUEST $TRAVIS_COMMIT "$BUILD_ENGINE" $GITHUB_SERVER_URL $repourl
        ./buildscript/postBuildsToDI $2 $3 $SERVICE_NAME $BUILD_RUN_ID "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID" $status $duration "$(date --utc +%FT%T.%3NZ)" $BUILD_BRANCH $GITHUB_EVENT_NAME $PULL_REQUEST_NUMBER $BUILD_COMMIT "$BUILD_ENGINE" $GITHUB_SERVER_URL "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY"
    fi
# done
