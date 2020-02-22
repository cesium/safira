#!/usr/bin/env sh

set -e
. "functions.sh"

if not_installed "docker"; then
  pp_error "setup" "
  We are using docker for hosting our DB. pls insall it and run this script again.
  "

  exit 1
else
  docker_state=$(docker info >/dev/null 2>&1)
  if [[ $? -ne 0 ]]; then
    pp_error "setup" "Docker does not seem to be running, run it first and retry"
    exit 1
  fi

fi

pp_info "setup" "Creating PostgreSQL container"

make

pp_success "setup" "Container is up-and-running"
