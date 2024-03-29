#!/bin/bash

# license_finder report --format json --columns=name version licenses approved --enabled-package-managers gomodules > license.json
# sed -i '1d' license.json

# We somehow need to read the list of allowed/permitted and denied/prohibited licenses in these variables
# either using a file or fetch from an api.
# list of allowed licenses
allowed=("MIT" "GPL")
# list of denied license
denied=("New BSD")

branch=$(echo "\"$TRAVIS_BRANCH\"")
repo=$(echo "\"$TRAVIS_REPO_SLUG\"")
# TRAVIS_COMMIT=12344

# we need to find a way  to populate these arrays(allowed & denied), for now just hard coding them
allowed=("MIT")
denied=("New BSD" "\"Apache 2.0,MIT\"")


postLicenseScanResults() {
# 	echo $branch "\"$branch\"" "\"$repo\""
# 	CODE=$(curl --location --request POST -sSL -w '%{http_code}' ''"$1"'"$URL_HERE"' \
#  	--header 'Authorization: Token '"$2"'' \
# 	--header 'Content-Type: application/json' \
# 	--data-raw  "${all[@]}"  -k)
#     if [[ "$CODE" == *"200"* ]]; then
#     # server return 2xx response
#         echo "Posted License Scan Results Successfully :: "$CODE
#     else
#         echo "Error while posting License Scan Results :: $CODE"
#     fi
}


# list=$(license_finder --prepare-no-fail --format=json --no-recursive --no-debug | awk '!/^[A-Z]/' | jq '.dependencies[].licenses[]')
listcsv=$(license_finder --prepare-no-fail --format=csv --no-recursive --no-debug | awk '!/^[A-Z]/' > ll.csv)


arr=()

while IFS="," read -r rec_column1 rec_column2 rec_column3 
do
  arr+=("$rec_column3")
done < <(tail -n +2 ll.csv)

echo "Done"
echo "Allowed Licenses : "${allowed[@]}
echo "Denied Denied : "${denied[@]}

# uniques=($(for v in "${arr[@]}"; do echo "'$v'";done| sort| uniq| xargs))

IFS=$'\n' uniques=(`printf "%s\n" "${arr[@]}" |sort -u`)

# uniques=($(printf "%s\n" "${arr[@]}" | sort -u))

echo "List of Unique Licenses found in the Project~" 
echo "------------------"
for v in "${uniques[@]}";do
  echo "$v"
done
echo "------------------"

all=('[]') #this array will hold the payload to be sent to DevOps Intelligence
for i in "${uniques[@]}"; do # traverse through the uniques and check if they are allowed, denied or uncategorized.
  if [[ "${allowed[*]}" == *"$i"* ]]; then
    # echo $i is allowed
        payload=$( jq -n \
                  --arg ln "$i" \
                  --arg ad "$(date +%FT%T.%3NZ)" \
                  --arg st "allowed" \
                  '{name: $ln, analysis_date: $ad, status: $st}' )
        all=$(echo $all | jq ".+=[$payload]")
  elif [[ "${denied[*]}" == *"$i"* ]]; then
    # echo $i is denied
        payload=$( jq -n \
                  --arg ln "$i" \
                  --arg ad "$(date +%FT%T.%3NZ)" \
                  --arg st "denied" \
                  '{license_name: $ln, analysis_date: $ad, status: $st}' )
        all=$(echo $all | jq ".+=[$payload]")
  else 
    # echo $i is uncategorized
        payload=$( jq -n \
                  --arg ln "$i" \
                  --arg ad "$(date +%FT%T.%3NZ)" \
                  --arg st "uncategorized" \
                  '{license_name: $ln, analysis_date: $ad, status: $st}' )
        all=$(echo $all | jq ".+=[$payload]")
  fi
done

echo Payload : 
echo ${all[0]}

echo host :: "$CUSTOM_HOST" $CUSTOM_HOST
echo token :: "$CUSTOM_TOKEN" $CUSTOM_TOKEN

postLicenseScanResults "$CUSTOM_HOST" "$CUSTOM_TOKEN"
