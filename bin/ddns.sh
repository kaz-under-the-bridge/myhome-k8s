#!/bin/bash

# this script is only for my home "ddns like" mechanism
# To update specified CloudDNS "A record" when global ip at myhome is changed

readonly tmp=`mktemp`
trap 'rm -f $tmp*' 0
readonly dir=$(cd $(dirname $0) && pwd)

name=$1
zone=$2

if [ -z "$name" -o -z "$zone" ]; then
  echo "usage: $0 dns-name zone-name"
  exit 1
fi

record=$(gcloud dns record-sets describe $name \
        --type "A" --zone $zone --format json | jq -r '.rrdatas | .[0]')

echo "DNS record: $record"

if [ "$record" == "" ]; then
  echo "$record is empty. skip, $name may not be found"
  exit 1
fi

ip=$(curl -s httpbin.org/ip | jq -r '.origin')

echo "Outbound IP: $ip"

if [ "$ip" == "" ]; then
  echo "outbound ip is empty, supposed commnad failure or httpbin.org not respond"
  exit 1
fi

if [ "$record" == "$ip" ]; then
  echo "both $record and $ip are same. skip"
  exit 0
fi

echo "$record, $ip are different, update cloud dns record"
gcloud dns record-sets update $name \
      --rrdatas=$ip --type "A" --ttl=60 --zone $zone
