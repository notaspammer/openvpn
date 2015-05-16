#!/bin/bash

# Default Variables 
KEYENC=".3des.key"
OPENVPN_DIR=/etc/openvpn/easy-rsa
OPENVPN_KEY_DIR=$OPENVPN_DIR/keys
EXPORT=/home/theHTTPdoNOTtouch/openvpnOVPN
CN=$1
DEFAULT="/etc/openvpn/easy-rsa/default.txt" # the files default.txt should contain the client config.
FILEEXT=".ovpn" 
CA="ca.crt" 
TA="ta.key" 
OU="Redstonevapour.co.uk VPN"


# New Client
if [ -z "$1" ]
	then echo -n "[OK] Enter new Client name: "
	read -e CN
else
	CN=$1
fi
 
# Ensure CN isn't blank
if [ -z "$CN" ]
	then echo "[ERROR] You must provide a name."
	exit
fi

if [ -f $OPENVPN_KEY_DIR/$CN.crt ]
  then echo "[ERROR] cerificate already exsists with the name $CN already exsists! Exiting now."
    echo " $OPENVPN_KEY_DIR/$CN.crt"
  exit
fi



cd $OPENVPN_DIR


if [ x$CN = x ]; then
    echo "[ERROR] Usage: $0 clientname"
    exit 1 
fi

if [ ! -e keys/$CN.key ]; then
    echo "[OK] Generating keys... "
    . vars
    KEY_CN=$CN KEY_OU=$OU ./pkitool $CN
    echo "[OK] ...keys generated. " 
fi


# Encrypting keys as per variables variables.

cd $OPENVPN_KEY_DIR

if [ -f $OPENVPN_KEY_DIR/$CN$KEYENC ]
  then echo "[ERROR] Key keys/$CN$KEYENC already exsist! Exiting now. "
fi

echo "[OK] Changing encryption now... "

# EDIT ME IF YOU CHANGE ENCRYTION! 
openssl rsa -in $CN.key -des3 -out $CN$KEYENC

if [ ! -f $OPENVPN_KEY_DIR/$CN$KEYENC ]
  then echo "[ERROR] keys/$CN$KEYENC file not found. Exiting now. "
fi

echo "[OK] Key sucessfully encrytped. "


# Generate the OVPN file

if [ ! -f $OPENVPN_KEY_DIR/$CA ] 
 then echo "[ERROR] CA Public Key not found: $CA" 
 exit 
fi 
 
if [ ! -f $OPENVPN_KEY_DIR/$TA ]
 then echo "[ERROR] tls-auth Key not found: $TA" 
 exit 
fi 


echo "[OK] Generating OVPN file now. "

cd $OPENVPN_KEY_DIR

cat $DEFAULT > $CN$FILEEXT 
 
echo "<ca>" >> $CN$FILEEXT 
cat $CA >> $CN$FILEEXT 
echo "</ca>" >> $CN$FILEEXT
 
echo "<cert>" >> $CN$FILEEXT 
cat $CN.crt | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' >> $CN$FILEEXT 
echo "</cert>" >> $CN$FILEEXT 
 
echo "<key>" >> $CN$FILEEXT 
cat $CN$KEYENC >> $CN$FILEEXT 
echo "</key>" >> $CN$FILEEXT 

echo "<tls-auth>" >> $CN$FILEEXT 
cat $TA >> $CN$FILEEXT 
echo "</tls-auth>" >> $CN$FILEEXT 

echo "[OK] Done creating $CN$FILEEXT! "
