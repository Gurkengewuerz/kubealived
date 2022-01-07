#!/usr/bin/env sh

if [ -f "/app/.env" ]; then
    set -o allexport
    ENVFILE=$(cat /app/.env | tr -d '\r')
    echo $ENVFILE > /run/.env.tmp
    source /run/.env.tmp
    rm /run/.env.tmp
    set +o allexport
fi

CONFIG_PATH="/etc/keepalived/keepalived.conf"

sed -i \
    -e "s/_INSTANCE_NAME_/${KEEPALIVE_INSTANCE:-VI_1}/" \
    -e "s/_STATE_/${KEEPALIVE_STATE:-MASTER}/" \
    -e "s/_INTERFACE_/${KEEPALIVE_INTERFACE:-eth0}/" \
    -e "s/_VRID_/${KEEPALIVE_VIRTUAL_ROUTER:-1}/" \
    -e "s/_PRIORITY_/${KEEPALIVE_PRIORITY:-100}/" \
    -e "s/_ADVERT_INTERVAL_/${KEEPALIVE_ADVERT_INTERVAL:-1}/" \
    -e "s/_AUTH_PASS_/${KEEPALIVE_AUTH_PASS}/" \
    -e "s/_IPADDRESS_/${KEEPALIVE_IPADDRESS:-10.247.254.2}/" \
    $CONFIG_PATH

if [ -z "${KEEPALIVE_AUTH_PASS}" ]; then 
    sed -i -e "/--- AUTH-BEGIN/,/--- AUTH-END/d" $CONFIG_PATH
fi

chmod 0644 $CONFIG_PATH

/app/keepalived --dont-fork --log-console -f $CONFIG_PATH