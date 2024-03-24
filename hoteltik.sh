#!/usr/bin/env bash

set -o errexit
set -o pipefail

help() {
  echo "Usage: $0 [-h] -u <username> <router_addr>" 1>&2
}

usage() {
  help
  exit 1
}

USERNAME=""
ADDR=""

while getopts u:h opt; do
  case "$opt" in
    u) USERNAME="$OPTARG" ;;
    h) help; exit;;
    *) usage;;
    esac
  done

while [ "$1" ]; do
  ADDR="$1"
  shift
done

if [[ -z "${USERNAME}" ]]; then
  usage;
fi

if [[ -z "${ADDR}" ]]; then
  usage;
fi

URL="http://${ADDR}"
LOGIN_CONTENTS=$(curl -L "${URL}" 2>/dev/null)
HASH_CALL=$(echo "${LOGIN_CONTENTS}" | grep -e "hexMD5(.\+)" || true)
if [[ -z "${HASH_CALL}" ]]; then
  echo "Failed to find call to hexMD5 at ${URL}"
  echo "Either something went wrong or you're already logged in"
  exit 0
fi

SECRET=$(echo "${HASH_CALL}" | cut -d"(" -f2 | cut -d")" -f1 | sed "s/document.login.password.value/'${USERNAME}'/")
PASSWORD=$(node -e "console.log(require('$(dirname "$0")/md5.js')(${SECRET}));")

curl -X POST "${URL}/login" -d "username=${USERNAME}&password=${PASSWORD}&popup=true&dst=" -v 1>/dev/null 2>&1 || echo "Failed to log in"
