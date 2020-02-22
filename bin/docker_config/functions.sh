#!/usr/bin/env sh

BLUE='\033[1;34m'
GREEN='\033[1;32m'
YELLOW='\033[1;99m'
RED='\033[1;91m'
RESET='\033[0m'

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
