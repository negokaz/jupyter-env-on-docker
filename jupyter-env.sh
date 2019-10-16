#!/bin/bash

readonly script_name="$(basename "$0")"
readonly base_dir="$(dirname "$0")"
readonly docker_dir="${base_dir}/docker"
readonly docker_compoe_file="${docker_dir}/docker-compose.yml"
readonly env_file="${docker_dir}/.env"

[ -f "${env_file}" ] && source "${env_file}"

function print_usage {
  cat - <<EOL
Jupyter Environment on Docker

Usage: ${script_name} [COMMAND] [ARGS...]

Commands:
  up      Create and start Jupyter 
  build   Rebuild Jupyter container
EOL
}

function main {
  local sub_command="$1"; shift 1
  case "${sub_command:-up}" in
    'build' )
      build
      ;;
    'up' )
      up "$@"
      ;;
    *'help' )
      print_usage
      exit 0
      ;;
    * )
      echo "Unknown command: ${sub_command}"
      print_usage
      exit 1
  esac
}

function up/print_usage {
  cat - <<EOL

Usage: ${script_name} up [options...]

Options:
  --workdir <directory>   Set jupyter working directory
                          (default: $(pwd))
EOL
}

function up {
  up/parse_arguments "$@"
  if ! [ -z "${workdir}" ]
  then
    cd "${workdir//\\//}"
  fi

  docker_compose down

  up/wait_open_browser &

  trap up/on_exit EXIT

  docker_compose up
}

workdir=''

function up/parse_arguments {
  while [ $# -gt 0 ]
  do
    case "$1" in
      *'help' )
        up/print_usage
        exit 0
        ;;
      '--workdir' )
        workdir="$2"
        shift 2
        ;;
      -* )
        echo "Unknown option: $1"
        up/print_usage
        exit 1
        ;;
    esac
  done
}

function up/wait_open_browser {
	local url="http://${BIND_IP:-127.0.0.1}:${BIND_PORT:-8888}"

    until test "$(curl "${url}" -m 1 -o /dev/null -w '%{http_code}\n' -s)" = "302"
    do
      sleep 3
    done

    if which start &> /dev/null; then
      # for windows
      start "${url}"
    elif which open &> /dev/null; then
      # for mac
      open "${url}"
    elif which xdg-open &> /dev/null; then
      # for linux
      xdg-open "${url}"
    fi
    echo
    echo 'Please open the following URL in your browser:'
    echo 
    echo "${url}"
    echo
}

function up/on_exit {
  docker_compose down
  /usr/bin/env kill -PIPE -- -$$
}

function build {
  docker_compose build \
    --no-cache \
    ${http_proxy:+--build-arg "http_proxy=${http_proxy}"} \
    ${https_proxy:+--build-arg "https_proxy=${https_proxy}"}
}

function docker_compose {
  env WORKDIR="$(pwd)" docker-compose --file "${docker_compoe_file}" "$@"
}

main "$@"