# #!/usr/bin/env bash


# echo Event :: $GITHUB_EVENT_NAME
# echo service name :: $SERVICE_NAME
# echo built at :: $(date --utc +%FT%T.%3NZ)
# echo providerhref :: $GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID
# echo elapsed :: $ELAPSED
# echo status :: $STATUS
# echo duration :: $(($ELAPSED*1000000000))
# echo builtat $(date --utc +%FT%T.%3NZ)
# echo repourl :: $GITHUB_SERVER_URL/$GITHUB_REPOSITORY
# echo run id :: $BUILD_RUNID
# echo branch :: $BUILD_BRANCH
# echo pr num :: $PULL_REQUEST_NUMBER 
# echo commit :: $BUILD_COMMIT

# # get the build script 
# echo "Pulling the BRING YOUR OWN script ..."
# git clone --depth 1 https://github.com/Wizkaley/urbandictionary.git urbandictionary
# chmod +x urbandictionary/buildscript/postBuildsToDI
# # echo $DEV_SECOPS_HOST_TOKEN >> byob_secrets.json
# # hosts=($(jq -r '.[].host' byob_secrets.json))
# # tokens=($(jq -r '.[].byob_token' byob_secrets.json))
# # for i in "${!hosts[@]}"; do
# #     if [[ -z "${tokens[i]}" ]];then
# #         continue
# #     fi
#     if [[ $GITHUB_EVENT_NAME == "push" ]];then
#         pull_request_number="NIL"
#         ./urbandictionary/buildscript/postBuildsToDI $2 $3 $SERVICE_NAME $BUILD_RUNID "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID" $STATUS $(($ELAPSED*1000000000)) "$(date --utc +%FT%T.%3NZ)" $BUILD_BRANCH $GITHUB_EVENT_NAME $pull_request_number $BUILD_COMMIT "$BUILD_ENGINE" $GITHUB_SERVER_URL "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY"
#     elif [[ $GITHUB_EVENT_NAME == "pull_request" ]];then
#         ./urbandictionary/buildscript/postBuildsToDI $2 $3 $SERVICE_NAME $BUILD_RUNID "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID" $STATUS $(($ELAPSED*1000000000)) "$(date --utc +%FT%T.%3NZ)" $BUILD_BRANCH $GITHUB_EVENT_NAME $PULL_REQUEST_NUMBER $BUILD_COMMIT "$BUILD_ENGINE" $GITHUB_SERVER_URL "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY"
#     fi
# # done
