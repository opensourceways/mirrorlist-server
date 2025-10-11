#!/usr/bin/bash

set -e
export RUST_LOG=info

cd $(dirname $0)

cfg=$1
proto=./config/mirrorlist_cache.proto

gen_proto() {
    ./generate-mirrorlist-cache -c $cfg -o $proto
}

proto_checksum() {
    md5sum -z $proto | awk '{print $1}'
}

process_num() {
    ps -ef | grep "mirrorlist-server --listen 0.0.0.0" | grep -v grep | awk '{print $2}'
}

log() {
    echo "$(date), $1"
}

gen_proto

checksum=$(proto_checksum)

log "checksum = $checksum"

set +e

while true
do
    log "start server!!!"

    ./mirrorlist-server --listen 0.0.0.0 -c ./config/mirrorlist_cache.proto -g ./config/global_netblocks.txt --log ./log/mirrorlist-server.log --cccsv ./config/country_continent.csv --geoip ./config/GeoLite2-Country.mmdb &

    sleep 5

    pn=$(process_num)
    test -z "$pn" && continue

    sleep 3600

    while true
    do
        gen_proto

        if [ $? -eq 0 ]; then
            v=$(proto_checksum)

            log "check checksum, old=$checksum, new=$v"

            if [ -n "$v" -a "$v" != "$checksum" ]; then
                log "save new checksum"

                checksum=$v
                break
            fi
        else
            log "gen proto failed"
        fi

        sleep 60
    done

    while true
    do
        pn=$(process_num)
        test -z "$pn" && break

        kill -9 $pn

        log "kill mirrorlist-server: $pn"

        sleep 1
    done
done
