#!/bin/bash

BLUE='\e[34m'
GREEN='\e[32m'
YELLOW='\e[33m'
RED='\e[31m'
RESET='\e[39m'

pp() {
  printf "$1[$2]: $3${RESET}\n"
}

pp_info() {
  pp $BLUE "$1" "$2"
}

pp_success() {
  pp $GREEN "$1" "$2"
}

pp_error() {
  pp $RED "$1" "$2"
}

pp_warn() {
  pp $YELLOW "$1" "$2"
}

not_installed() {
  [ ! -x "$(command -v "$@")" ]
}

ask_confirmation() {
  read -r "confirmation?please confirm you want to continue [y/n] (default: y) "
  confirmation=${confirmation:-"y"}

  [[ "$confirmation" == "y" ]];
}
