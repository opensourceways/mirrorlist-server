#!/bin/sh

cd $(dirname $0)

cfg=$1

./generate-mirrorlist-cache -c $cfg -o ./config/mirrorlist_cache.proto

./mirrorlist-server --listen 0.0.0.0 -c ./config/mirrorlist_cache.proto -g ./config/global_netblocks.txt --log ./mirrorlist-server.log --cccsv ./config/country_continent.csv --geoip ./config/GeoLite2-Country.mmdb

# even the service above is killed manually, then we can start it again but will not kill the container
while true
do
    sleep 1
done
