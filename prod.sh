#!/usr/bin/env bash

helpFunction()
{
  echo ""
  echo "usage: $0 <action>"
  echo ""
  echo "actions: build | mount | load | up | down"
  echo ""
  echo "additional required parameters:"
  echo "- for mount: user@ip"
  echo "- for load: filepath"
  exit 1
}

action=$1
wd="$(pwd)"

# validate options
if [ -z "$action" ]; then
  echo "missing action parameter"
  helpFunction
fi

if [ "$action" == "build" ]; then
  cd kebapp_server
  docker build -f Dockerfile.production -t kebapp-server . --platform linux/arm64
  cd ..
fi

if [ "$action" == "mount" ]; then
  host=$2
  if [ -z "$host" ]; then
    echo "missing host parameter"
    helpFunction
  fi

  cd kebapp_server
  docker save -o "$wd/kebapp-server.tar" kebapp-server
  scp "$wd/kebapp-server.tar" $host:~/kebapp-server.tar
  rm "$wd/kebapp-server.tar"
  cd ..
fi

if [ "$action" == "load" ]; then
  file=$2
  if [ -z "$file" ]; then
    echo "missing file parameter"
    helpFunction
  fi

  docker load -i "$file"
fi

if [ "$action" == "up" ]; then
  cd kebapp_server
  docker compose -f docker-compose.production.yaml up -d
  sleep 1
  docker compose -f docker-compose.production.yaml ps
  cd ..
fi

if [ "$action" == "down" ]; then
  cd kebapp_server
  docker compose -f docker-compose.production.yaml down
  sleep 1
  docker compose -f docker-compose.production.yaml ps
  cd ..
fi
