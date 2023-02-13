#!/bin/bash

source ../utils.sh

source ./credentials.sh

parseArgs $@

build() {
  docker build -t bu-wp-assets-olap:latest .
  docker rmi $(docker images --filter dangling=true -q) 2> /dev/null || true
}

run() {

  [ -n "$PROFILE" ] && setLocalCredentials $PROFILE

  [ ! -d logs ] && mkdir logs || rm -rf logs/*

  createEnvFile && \
    echo "OLAP=$OLAP" >> vars.env
  
  docker run \
    -d \
    --name ol \
    -p 80:80 \
    -p 443:443 \
    --env-file vars.env \
    -v $(pwd)/default.conf:/etc/apache2/sites-enabled/default.conf \
    -v $(pwd)/logs:/var/log/apache2 \
    bu-wp-assets-olap:latest
}

kill() {
  docker rm -f ol 2> /dev/null || true
}

case "$TASK" in
  run)
    kill && run
    ;;
  build)
    kill && build
    ;;
  deploy)
    kill && build && run
    ;;
esac
