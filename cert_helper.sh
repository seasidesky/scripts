#!/bin/sh

function create_keystore
{
  KEY_FILE=$1
  ALIAS=$2
  DN=$3
  PASS=$4
  keytool -genkey -alias $ALIAS -keyalg RSA -keystore $KEY_FILE -storepass $PASS -keypass $PASS -dname $DN
}

function export_cert
{
  KEY_FILE=$1
  ALIAS=$2
  EXPORT_FILE=$3
  PASS=$4
  keytool -export -alias $ALIAS -keystore $KEY_FILE -storepass $PASS -file $EXPORT_FILE -rfc
}

function import_cert
{
  KEY_FILE=$1
  ALIAS=$2
  IMPORT_FILE=$3
  PASS=$4
  keytool -import -alias $ALIAS -keystore $KEY_FILE -storepass $PASS -file $IMPORT_FILE -noprompt
}

PASSWORD="123456"

create_keystore "server.jks" "serverkeys" "CN=lab-1.jboss" $PASSWORD

export_cert "server.jks" "serverkeys" "jboss_cert.pem" $PASSWORD

openssl genrsa -out apache_key.pem 1024
openssl req -new -key apache_key.pem -x509 -out apache_cert.pem -days 999 -subj "/CN=lab-1.apache"
cat apache_cert.pem apache_key.pem > apache_cert_key.pem

import_cert "server_truststore.jks" "lab-1.apache" "apache_cert.pem" $PASSWORD
