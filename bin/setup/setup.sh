#!/usr/bin/env sh

set -e
. "functions.sh"

if not_installed "erl"; then

  pp_error "setup" "Pls install Erlang and run this script again."

fi

if not_installed "elixir"; then

  pp_error "setup" "Pls install Elixir and run this script again."

fi

if not_installed "mix"; then

  pp_error "setup" "Pls install Mix and run this script again."

fi

if not_installed "docker"; then

  pp_error "setup" "We are using docker for hosting our DB. Pls install it and run this script again."

  exit 1

else
  
  if ! docker info > /dev/null 2>&1; then
    pp_error "setup" "Docker does not seem to be running, start it and retry"
    exit 1
  fi

fi

if not_installed "docker-compose"; then

  pp_error "setup" "Pls install Docker-Compose and run this script again."

fi

pp_success "setup" "Everything is prepared.\n
     Start a database in root folder with:\n         docker-compose up -d \n
     Create a database setup with:\n         mix ecto.setup \n
     Initialize safira with:\n         mix phoenix.server \n
     To remove the database engine, run:\n         docker-compose down -v \n"
