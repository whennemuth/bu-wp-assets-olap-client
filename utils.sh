#!/bin/bash

export MSYS_NO_PATHCONV=1

# Parse arguments passed to the script and set them as global variables
parseArgs() {
  for nv in $@ ; do
    [ -z "$(grep '=' <<< $nv)" ] && continue;
    name="$(echo $nv | cut -d'=' -f1)"
    value="$(echo $nv | cut -d'=' -f2-)"
    eval "${name^^}=$value" 2> /dev/null || true
  done
}

# Get the aws account number based on the available credentials
getAcctNbr() {
  if [ -n "$AWS_ACCOUNT_NBR" ] ; then
    echo "$AWS_ACCOUNT_NBR"
  else
    source $(pwd)/vars.env 2>&1 > /dev/null
    aws sts get-caller-identity | jq -r '.Account' 2> /dev/null
  fi
}

# Get the region from the environment, defaulting to us-east-1
getRegion() {
  [ -n "$REGION" ] && echo "$REGION" || echo "us-east-1"
}

# STRANGE AND FRUSTRATING BUG: Cannot feed the environment variables separately into the container using -e.
# They show up on the container when you run docker inspect, but when you shell into the container 
# and run the env command, the only one that shows up is AWS_SESSION_TOKEN, WTF!!!
# WORKAROUND: Putting the environment variables into a file and using --env-file.
# (Note: This is probably a windows/docker desktop/WSL bug - won't occur on linux and I doubt it would on a mac)
createEnvFile() {
  if [ -f vars.default.env ] ; then
    cat vars.default.env > vars.env
    echo "" >> vars.env
  else
    echo "#/bin/bash" > vars.env
  fi
  addcred() {
    local credvar="$1"
    local credval="$2"
    if [ -z "$(cat vars.default.env | grep $credvar)" ] ; then
      local val="${credval:-${!credvar}}"
      eval "echo "${credvar}=${val}" >> vars.env"
    fi
  }
  addcred 'AWS_ACCESS_KEY_ID'
  addcred 'AWS_SECRET_ACCESS_KEY'
  addcred 'AWS_SESSION_TOKEN'
  addcred 'AWS_ACCOUNT_NBR' "$(getAcctNbr)"
  addcred 'REGION' "$(getRegion)"
}