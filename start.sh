#!/bin/sh

cfg=$1

./generate-mirrorlist-cache -c $cfg -o ./config/mirrorlist_cache.proto

./mirrorlist-server -c ./config/mirrorlist_cache.proto -g ./config/global_netblocks.txt --log ./mirrorlist-server.log --cccsv ./config/country_continent.csv --geoip ./config/GeoLite2-Country.mmdb
