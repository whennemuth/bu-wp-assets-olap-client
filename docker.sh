#!/bin/bash

source ./utils.sh

parseArgs $@

case "$SHIB" in
  'true')
    cd baseline
    sh docker.sh task=build
    cd ../shibboleth
    sh docker.sh $@
    ;;
  default)
    cd baseline
    sh docker.sh $@
    ;;
esac
