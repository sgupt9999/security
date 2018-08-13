#!/bin/bash
##############################################################################################################
# This script will create a new root CA, create a certificate signed by the CA and test it using apache server
# The client script will import the CA certificate and be able to call the web server w/o an error message
##############################################################################################################
# Start of user inputs

# End of user inputs
##############################################################################################################


source ./inputs
rm -rf $LOG_FILE
exec 5>$LOG_FILE
source ./common_fn

check_euid

MESSAGE="This script will install a new root CA and apache webserver for testing. The installtion log is at $LOG_FILE"
print_msg_start
echo "###################################################################################################################"
echo "###################################################################################################################" >&5

# Remove old certificates
rm -rf /etc/pki/tls/certs/myserver*
rm -rf /etc/pki/tls/certs/rootca*
rm -rf /tmp/rootca*

# generate key and certificate for root CA
MESSAGE="Generating root CA certficate"
print_msg_start

# create config file
cat > /etc/pki/tls/certs/openssl.cnf <<EOF
[ req ]
default_bits        = 4096
default_md          = sha384
prompt            = yes
x509_extensions     = v3_ca
distinguished_name  = req_distinguished_name

[ req_distinguished_name ]

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
EOF


openssl req -config /etc/pki/tls/certs/openssl.cnf -newkey rsa:4096 -nodes -x509 -days 3650 -sha384 -extensions v3_ca -subj "/C=$CA_C/ST=$CA_ST/L=$CA_L/O=$CA_O" -keyout /etc/pki/tls/certs/rootca.key -out /etc/pki/tls/certs/rootca.crt >&5 2>&5

if [[ $COPY_ROOT_CA_CERT_TO_TMP == "yes" ]]
then
	cp /etc/pki/tls/certs/rootca.crt /tmp
	chmod 777 /tmp/rootca.crt
fi

print_msg_done

# generate key and certficate for apache webserver
MESSAGE="Generating webserver certficate signed by the new root CA"
print_msg_start
openssl req -newkey rsa:2048 -nodes -keyout /etc/pki/tls/certs/myserver.key -out /etc/pki/tls/certs/myserver.csr -subj "/C=$WS_C/ST=$WS_ST/L=$WS_L/O=$WS_O/OU=$WS_OU/CN=$WS_CN" >&5 2>&5
openssl x509 -req -days 365 -signkey /etc/pki/tls/certs/myserver.key -in /etc/pki/tls/certs/myserver.csr -out /etc/pki/tls/certs/myserver.crt -CA /etc/pki/tls/certs/rootca.crt -CAkey /etc/pki/tls/certs/rootca.key -set_serial 100 >&5 2>&5
print_msg_done

chmod 0600 /etc/pki/tls/certs/myserver.*
chmod 0600 /etc/pki/tls/certs/rootca.*

install_httpd
echo "You can successfully view the site with a certfictae installed by a new root CA" > /var/www/html/index.html

