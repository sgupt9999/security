#!/bin/bash
########################################################################################################
# This script will create a new root CA, create a certificate signed by the CA and test it using apache server
# The client script will import the CA certificate and be able to call the web server w/o an error message
########################################################################################################
# Start of user inputs

# End of user inputs
########################################################################################################

source ./inputs
source ./common_fn

check_euid

# Remove old certificates
rm -rf /etc/pki/tls/certs/myserver*
rm -rf /etc/pki/tls/certs/rootca*

# generate key and certificate for root CA
#openssl genrsa -out /etc/pki/tls/certs/rootca.key 4096
openssl req -config /etc/pki/tls/certs/openssl.cnf -newkey rsa:4096 -nodes -x509 -days 3650 -sha384 -extensions v3_ca -subj "/C=$CA_C/ST=$CA_ST/L=$CA_L/O=$CA_O" -keyout /etc/pki/tls/certs/rootca.key -out /etc/pki/tls/certs/rootca.crt

# generate key and certficate for apache webserver
#openssl req -newkey rsa:2048 -nodes -keyout /etc/pki/tls/certs/myserver.key -out /etc/pki/tls/certs/myserver.csr -subj "/CN=garfield99992.mylabserver.com"
#openssl x509 -req -days 365 -signkey /etc/pki/tls/certs/myserver.key -in /etc/pki/tls/certs/myserver.csr -out /etc/pki/tls/certs/myserver.crt -CA /etc/pki/tls/certs/rootca.crt -CAkey /etc/pki/tls/certs/rootca.key -set_serial 100
openssl req -x509 -days 365 -newkey rsa:2048 -nodes -CA /etc/pki/tls/certs/rootca.crt -CAkey /etc/pki/tls/certs/rootca.key -set_serial 100 -subj "/C=$WS_C/ST=$WS_ST/L=$WS_L/O=$WS_O/OU=$WS_OU/CN=$WS_CN" -newkey /etc/pki/tls/certs/myserver.key -out /etc/pki/tls/certs/myserver.crt

chmod 0600 /etc/pki/tls/certs/myserver.*
chmod 0600 /etc/pki/tls/certs/rootca.*

install_httpd
