#!/bin/bash

set -eo pipefail
declare -r DIR=$(dirname ${BASH_SOURCE[0]})

function usage() {
    cat <<END >&2
USAGE: $0 [-a access_token] [-d domain] [-c client_id] [-x client_secret] [-e auth0-enabled-client] [-f connection-def-file] [-s fetchProfile-file] [-v|-h]
        -a token    # access_token. default from environment variable
        -d domain   # authz server deplyment domain
        -c id       # client_id
        -x secret   # client_secret
        -f file     # connection definition JSON file. default is 'ext-authz-ip.json'
        -s file     # fetchUserProfile.js JS file. default is 'fetchUserProfile.js'
        -D          # dry-run, interpolate only
        -h|?        # usage
        -v          # verbose

eg,
     $0 -d https://ext-authz-ip.herokuapp.com -c Phiboov8eighenai -x ba2zoh0Uk6mahv6au3ahNg5xa7eiNge0 -e 1C39ZFp1MrRkRtTY7vlxFjvJLCheoMZm
END
    exit $1
}

declare domain=''
declare client_id=''
declare client_secret=''
declare enabled_client=''

declare fetch_file="${DIR}/../connection/fetchUserProfile.js"
declare dry_run=0

while getopts "a:d:c:x:e:f:s:Dhv?" opt
do
    case ${opt} in
        a) access_token=${OPTARG};;
        d) domain=${OPTARG};;
        c) client_id=${OPTARG};;
        x) client_secret=${OPTARG};;
        e) enabled_client=${OPTARG};;
        s) fetch_file=${OPTARG};;
        v) opt_verbose=1;; #set -x;;
        D) dry_run=1;;
        h|?) usage 0;;
        *) usage 1;;
    esac
done

[[ -z "${access_token}" ]] && { echo >&2 "ERROR: access_token undefined. export access_token='PASTE' "; usage 1; }
[[ -z "${fetch_file}" ]] && { echo >&2 "ERROR: fetch_file undefined."; usage 1; }
[[ -z "${client_id}" ]] && { echo >&2 "ERROR: client_id undefined."; usage 1; }
[[ -z "${client_secret}" ]] && { echo >&2 "ERROR: client_secret undefined."; usage 1; }
[[ -z "${domain}" ]] && { echo >&2 "ERROR: domain undefined."; usage 1; }
[[ -z "${enabled_client}" ]] && { echo >&2 "ERROR: enabled_client undefined."; usage 1; }

[[ -f "${fetch_file}" ]] || { echo >&2 "ERROR: fetch_file missing: ${fetch_file}"; usage 1; }

declare -r script_single_line=$(sed 's|\\|\\\\|g;s/$/\\n/g' "${fetch_file}" | tr -d '\n' | sed "s,@@DOMAIN@@,${domain},g")

declare -r AUTH0_DOMAIN_URL=$(echo "${access_token}" | awk -F. '{print $2}' | base64 -di 2>/dev/null | jq -r '.iss')

declare -r http_basic=$(echo -n "${client_id}:${client_secret}" | openssl base64 -e -A)

declare BODY=$(cat << EOL
{
  "name": "ext-token",
  "strategy": "oauth2",
  "is_domain_connection": true,
  "options": {
    "client_id": "${client_id}",
    "client_secret": "${client_secret}",
    "scripts": {
        "fetchUserProfile": "${script_single_line}"
    },
    "authorizationURL": "${domain}/auth/oauth/authorize",
    "tokenURL": "${domain}/auth/oauth/token",
    "scope": "profile",
    "customHeaders": {
      "authorization": "basic ${http_basic}"
    },
    "upstream_params": {
      "token": {
        "alias": "login_hint"
      }
    }
  },
  "enabled_clients": [
     "${enabled_client}"
  ]
}
EOL
)

[[ ${dry_run} -ne 0  ]] && { echo "${BODY}"; exit 0; }

curl --request POST \
    -H "Authorization: Bearer ${access_token}" \
    --url "${AUTH0_DOMAIN_URL}api/v2/connections" \
    --header 'content-type: application/json' \
    -d "${BODY}"

