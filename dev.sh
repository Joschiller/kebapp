#!/usr/bin/env bash

helpFunction()
{
  echo ""
  echo "usage: $0 <action>"
  echo ""
  echo "actions: init | up | down"
  exit 1
}

action=$1

# validate options
if [ -z "$action" ]; then
  echo "missing action parameter"
  helpFunction
fi

if [ "$action" == "init" ]; then
  dart pub global activate serverpod_cli 2.9.2

  cd kebapp_client
  dart pub get
  cd ..

  cd kebapp_server
  dart pub get
  serverpod generate
  cd ..

  cd kebapp_flutter
  dart pub get
  dart run build_runner build
  cd ..
fi

if [ "$action" == "up" ]; then
  cd kebapp_server
  docker compose --env-file dev.env up -d
  dart run bin/main.dart --apply-migrations
  cd ..
fi

if [ "$action" == "down" ]; then
  cd kebapp_server
  docker compose --env-file dev.env down
  cd ..
fi
