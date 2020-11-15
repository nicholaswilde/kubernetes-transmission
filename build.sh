#!/bin/bash

# https://www.linuxjournal.com/content/validating-ip-address-bash-script
# Test an IP address for validity:
# Usage:
#      valid_ip IP_ADDRESS
#      if [[ $? -eq 0 ]]; then echo good; else echo bad; fi
#   OR
#      if valid_ip IP_ADDRESS; then echo good; else echo bad; fi
#
function valid_ip() {
  local  ip=$1
  local  stat=1

  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    OIFS=$IFS
    IFS='.'
    ip=($ip)
    IFS=$OIFS
    [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
      && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
    stat=$?
  fi
  return $stat
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

FILE_PATH=${DIR}/manifests/ingress.yaml

# Get the ingress IP address from traefik
IP_ADDRESS=$(kubectl get all -n kube-system | grep '^service/traefik ' | awk '{print $4}')

# Validate the IP address
if ! valid_ip $IP_ADDRESS; then
  echo "Not a valid IP address: ${IP_ADDRESS}" 
  exit 1
fi

# https://stackoverflow.com/a/37290961/1061279
sed -ri 's/^(\s*)(- host\s*:\s*transmission(.*).nip.io\s*$)/\1- host: transmission.'${IP_ADDRESS}'.nip.io/' ${FILE_PATH}
cat ${FILE_PATH}
