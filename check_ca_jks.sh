#!/bin/bash
LANG=en

if [ $# -lt 3 ]; then
    echo "$0 <server address>:<port> <java keystore path> <java keystore password> [-v]"
    echo "-v verbose - print the complete certificate information of remote host"
    exit 0
fi

server=$1
keytool=$JAVA_HOME/bin/keytool
keystore=$2
storepass=$3
verbose=false

shift 3
if [ "$1" == "-v" -o "$2" == "-v" ]; then
  verbose=true
fi

keytool_error=`$keytool -list -keystore $keystore -storepass $storepass |grep Exception`
if [[ "$keytool_error" ]] ; then
    echo "$keytool_error"
    exit 1
fi
options="-subject -issuer -nameopt multiline,sname,dn_rev"
{ echo | openssl s_client -showcerts -connect $server 2>&1| sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | while read line ; do
    cert=$(printf "$cert\n$line") ;
    if [ "$line" ==  "-----END CERTIFICATE-----" ] ; then
        if [[ "$verbose" == true ]] ; then
            options="-text" 
        fi
        
        fingerprint=`echo "$cert" | openssl x509  -fingerprint -noout | awk -F '=' '{print $2}'`
        ca_exists=`$keytool -list -keystore $keystore -storepass $storepass |grep -B 1 "$fingerprint"`
        if [[ "$ca_exists" ]] ; then
            if [[ "$verbose" == true ]] ; then 
                echo "$cert" | openssl x509  -noout $options -fingerprint 
                echo "Certificate exists in $2"
            fi
        else 
            echo "$cert" | openssl x509  -subject -noout $options -fingerprint 
            echo
            echo "#### Warning: Certificate IS NOT included in $keystore"
            echo
#            echo "Import the certificate into $2"
#            echo "$cert"
            
            # ask to include certificate in JKS
            alias=`echo "$cert" | openssl x509 -noout -subject -nameopt multiline,sname,dn_rev|grep CN|awk -F'=' '{print $2}'|sed 's/^\ //g;s/\ /_/g'`
            read -u 3 -r -p "Do you want to include the above certificate into $keystore under alias $alias ? [y/N] " response
            if [[ $response =~ ^(yes|y|Y)$ ]]; then
              file=/tmp/$RANDOM.cer
              echo "$cert" > $file
              $keytool -importcert -alias $alias -file $file -keystore $keystore -storepass $storepass -noprompt
              rm -f $file
              echo "Certificate added to $keystore"
            else
              echo "Certificate NOT added to $keystore"
            fi
        fi
        cert=""
        echo
    fi

done; } 3<&0


