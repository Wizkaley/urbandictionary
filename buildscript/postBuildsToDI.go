package main

import (
	"crypto/tls"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
)

// http://local-core.gravitant.net O7d-iOHseIyoMyQM65ifIB6KSRx4taHChB8aEu_06Z_ihENnewwtqEtxmu2nkDu7 testScript 5d69de78674bf10001ed4123 http://localhost.com failed 100572000000 2021-07-10T02:42:00.185Z testBBBranch push 200 555333 GITACTIONS https://api.github.com https://testrepo.github.com

// variables to be picked from CI
var (
	// BRING YOUR OWN BUILD API ARGUMENTS
	DEVOPS_HOST         = os.Args[1]
	DEVOPS_BUILD_TOKEN  = os.Args[2]
	DEVOPS_SERVICE_NAME = os.Args[3]

	// BRING YOUR OWN BUILD PAYLOAD ARGUMENTS
	BUILD_ID             = os.Args[4]
	PROVIDER_HREF        = os.Args[5]
	BUILD_STATUS         = os.Args[6]
	BUILD_DURATION       = os.Args[7]
	BUILT_AT             = os.Args[8]
	BRANCH_NAME          = os.Args[9]
	EVENT_TYPE           = os.Args[10]
	PULL_REQUEST_NUMBER  = os.Args[11]
	BUILD_COMMIT         = os.Args[12]
	BUILD_ENGINE         = os.Args[13]
	CI_ENDPOINT_HOSTNAME = os.Args[14]
	REPO_URL             = os.Args[15]
)

// models for bring your own build
type BuildInfoModel struct {
	//
	// Build ID must be a unique for each service .
	// unique: true
	// required: true
	// example: "test_service"
	//
	BuildID string `json:"build_id" validate:"required"`
	//
	// The endpoint_service_id is the unique ID of a service on the endpoint.
	// eg, uuid for a service
	//
	EndPointServiceID string `json:"endpoint_service_id"`
	//
	// The endpoint_hostname is the server hostname where build ran.
	// eg, https://travis.com
	//
	EndPointHostname string `json:"endpoint_hostname"`
	//
	// The service broker API endpoint
	// read only: true
	//
	Href string `json:"href"`
	//
	// Date and time of build run . The date must be in rfc3339 format.
	// example: 2019-10-12T07:20:50.52Z
	// required: true
	//
	BuiltAt string `json:"built_at" validate:"required,date"`
	//
	// Status of build whether passed or failed
	// accepted values are "pass" "Pass" "PASS"
	// "passed" "Passed" "PASSED" "fail"
	// "Fail" "FAIL" "failed" "Failed" "FAILED"
	// example: passed
	// required: true
	//
	BuildStatus string `json:"build_status" validate:"required,oneof=pass Pass PASS passed Passed PASSED fail Fail FAIL failed Failed FAILED UNSTABLE unstable NOT_BUILT not_built ABORTED aborted"`
	//
	// Time required for the build to pass in nano seconds.
	// example: 100572000000
	// required: true
	//
	Duration uint64 `json:"duration" validate:"required"`
	//
	// URL of git repository
	// example: https://github.com/projects/test_project
	// required: false
	//
	RepoURL string `json:"repo_url"`
	//
	// Git repository branch name for which build has run . Default branch is master branch.
	// example: buildupdate
	// required: false
	//
	Branch string `json:"branch"`
	//
	// The event which triggered build . By default 'push'.
	// Available values are push , pull_request, cron, api
	// example: push
	// required: false
	//
	EventType string `json:"event_type"`
	//
	// Github commit ID for last commit on branch
	// example: d2bff1ef9bed5939d3619cb8f926ab37db6f72aa
	// required: false
	//
	Commit string `json:"commit"`
	//
	// Pull request number for which build run
	// example: 30
	// required: false
	//
	PullRequestNumber string `json:"pull_request_number"`
	//
	// Name of the build engine which executed build process
	// example: Jenkins
	// required: true
	//
	BuildEngine string `json:"build_engine" bson:"buildengine" validate:"required_without=BuildEngineAlt"`
	//
	// Alternative to build_engine tag . Provisioned to support older models . Use of build_engine tag is preferred .
	// If build_engine field not provided then this filed must be given
	// example: Jenkins
	//
	BuildEngineAlt string `json:"buildengine" validate:"required_without=BuildEngine"`
	//
	// Service Tag contains fields related to git organization. Fields are as following
	// GITHUB-NAMES - Combination of organization name / repo name
	// GITHUB-ORG-ID: Organization ID
	// GITHUB-ORG-NAME: Organization name
	// GITHUB-REPO-NAME: Repo name
	// required: false
	// example: "service_tag":{"GITHUB-NAMES":"devops/build","GITHUB-ORG-ID":"100001","GITHUB-ORG-NAME":"devops","GITHUB-REPO-NAME":"build"}
	//
	ServiceTag map[string]string `json:"service_tag"`
	//
	// Team Tag contains fields
	// GITHUB-ORG-ID: Organization ID
	// GITHUB-ORG-NAME: Organization name
	// required: false
	// example: "teamtag":{"GITHUB-ORG-ID":"100001","GITHUB-ORG-NAME":"devops"}
	//
	TeamTag map[string]string `json:"team_tag"`
	//
	// Details if there are any
	// required: false
	//
	Details interface{} `json:"details"`
	//
}

type buildConflictResponse struct {
	ID string `json:"id"`
}

/////////////////////////////////////////////////////////////////////////

func main() {

	// make the build
	bringYourOwnBuild := BuildInfoModel{}
	bringYourOwnBuild.BuildID = BUILD_ID
	bringYourOwnBuild.Branch = BRANCH_NAME
	bringYourOwnBuild.BuildEngine = BUILD_ENGINE
	bringYourOwnBuild.BuildStatus = BUILD_STATUS
	bringYourOwnBuild.Commit = BUILD_COMMIT
	duration, err := strconv.Atoi(BUILD_DURATION)
	if err != nil {
		fmt.Printf("error while converting build duration :: %v", err)
	}
	bringYourOwnBuild.Duration = uint64(duration)
	bringYourOwnBuild.BuildEngineAlt = BUILT_AT
	bringYourOwnBuild.Href = PROVIDER_HREF
	bringYourOwnBuild.PullRequestNumber = PULL_REQUEST_NUMBER
	bringYourOwnBuild.RepoURL = REPO_URL
	bringYourOwnBuild.EventType = EVENT_TYPE
	bringYourOwnBuild.EndPointHostname = CI_ENDPOINT_HOSTNAME
	bringYourOwnBuild.BuiltAt = BUILT_AT

	// send this build over to DevOps Intelligence
	postBuildToDevOpsIntelligence(bringYourOwnBuild)
}

func checkRedirectFunc(req *http.Request, via []*http.Request) error {
	req.Header.Add("Authorization", via[0].Header.Get("Authorization"))
	return nil
}
func postBuildToDevOpsIntelligence(build BuildInfoModel) (err error) {

	fmt.Println("############################################")
	fmt.Println("####POSTING Build To DevOps Intelligence####")
	fmt.Println("############################################")

	buildPayload := encodeBuildModel(build)
	postURL := fmt.Sprintf("https://%s/dash/api/build/v1/services/%s/builds", DEVOPS_HOST, DEVOPS_SERVICE_NAME)
	fmt.Println("Posting the build to URL :: %s" + postURL)
	bod := strings.NewReader(string(buildPayload))
	status, conflict, err := makeRequest(bod, postURL, http.MethodPost, DEVOPS_BUILD_TOKEN)
	if err != nil && status != http.StatusConflict {
		fmt.Printf("error while talking to devops endpoints, most likely a server error :: %v", err)
		return
	}
	fmt.Printf("Response for Post Build :: %d \n", status)
	if err == nil && status == http.StatusConflict {
		fmt.Println("Got a conflict, PATCHING now")
		defer conflict.Body.Close()
		cResp := buildConflictResponse{}
		errDecode := json.NewDecoder(conflict.Body).Decode(&cResp)
		if errDecode != nil {
			fmt.Printf("error while decoding body for conflict response :: %v", err)
			return
		}

		patchURL := fmt.Sprintf("https://%s/dash/api/build/v1/builds/%s", DEVOPS_HOST, cResp.ID)
		log.Printf("Patching the Build Record on URL :: %s", patchURL)

		newBod := BuildInfoModel{}
		newBod.BuiltAt = build.BuiltAt
		newBod.Duration = build.Duration
		newBod.Href = build.Href
		newBod.BuildStatus = build.BuildStatus
		newBod.BuildEngine = build.BuildEngine
		newBod.Branch = build.Branch
		newBod.Commit = build.Commit
		newBod.RepoURL = build.RepoURL
		patchBuildPayload := encodeBuildModel(newBod)
		nBod := strings.NewReader(string(patchBuildPayload))

		statusPatch, errPatch, _ := makeRequest(nBod, patchURL, http.MethodPatch, DEVOPS_BUILD_TOKEN)
		if errPatch != nil {
			fmt.Printf("error while patching the same build which was sent earlier :: %v", errPatch)
			return
		}
		fmt.Printf("response for patch is :: %d \n", statusPatch)
		if statusPatch == http.StatusOK {
			fmt.Printf("Build Updated  Successfully with most recent information")
		}
	}
	return
}

func encodeBuildModel(build BuildInfoModel) (buildPayload []byte) {
	buildPayload, err := json.Marshal(&build)
	if err != nil {
		fmt.Printf("error while marshalling build payload :: %v", err)
		return
	}
	return
}

func makeRequest(body *strings.Reader, url, method, authToken string) (statusCode int, resp *http.Response, err error) {
	// req := http.Request{}

	req, err := http.NewRequest(method, url, body)
	req.Header.Set("Accept", "application/json")
	req.Header.Add("Authorization", "TOKEN "+authToken)
	req.Header.Add("Content-Type", "application/json")
	if err != nil {
		fmt.Printf("error while forming up request :: %v", err)
		return
	}
	transport := &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}
	client := &http.Client{Transport: transport}
	client.CheckRedirect = checkRedirectFunc

	resp, err = client.Do(req)
	if err != nil {
		fmt.Printf("error while making request to endpoint :: %v", err)
		return
	}
	return resp.StatusCode, resp, nil
}
