#!/bin/sh
#This is meant to be ran in the VPN server machine
#certs and conf created are used by clients to establish connection

OPTS=`getopt -a -l encrypt -- "$0" "$@"`
PASSPHRASE=''

if [ $? != 0 ] # There was an error parsing the options
then
	  exit 1 
fi

eval set -- "$OPTS"

if [ "$1" = "--encrypt" ]; then
	device_name="$3"
else
	device_name="$2"
fi


SERVER_NAME=""
BACK_UP_DIR="s"

cd /etc/openvpn/easy-rsa/ 
. ./vars

device_name="$1"

#This also clean server key ca.key that is required!!!
#./clean-all

#modified original script so no interaction needed
./build-key $device_name

mkdir keys/$device_name
cp keys/template.ovpn keys/$device_name/$SERVER_NAME.ovpn

#keeping separate individual and unified certificates
cp keys/$device_name/$SERVER_NAME.ovpn keys/$device_name/unified_$SERVER_NAME.ovpn
CONF=keys/$device_name/unified_$SERVER_NAME.ovpn

echo "<ca>" >> $CONF
cat ../ca.crt >> $CONF
echo "</ca>\n<cert>" >> $CONF
cat keys/$device_name.crt >> $CONF
echo "</cert>\n<key>" >> $CONF
cat keys/$device_name.key >> $CONF
echo "</key>" >> $CONF

cp keys/$device_name.key keys/$device_name.crt ../ca.crt keys/$device_name/
tar -zcvf $BACK_UP_DIR/$device_name.tar.gz keys/$device_name 
chown uriel:uriel $BACK_UP_DIR/$device_name.tar.gz
