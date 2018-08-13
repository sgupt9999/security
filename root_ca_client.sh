#!/bin/bash
######################################################################################################
# This script will update the root CA certificates on this machine and will try to connect a webserver
# running with a certificate signed by this new CA
######################################################################################################
# Start of user inputs

# End of user inputs
######################################################################################################


source ./inputs
rm -rf $LOG_FILE
exec 5>$LOG_FILE
source ./common_fn

check_euid

MESSAGE="This script will update the root CA certificates on this machine. The installtion log is at $LOG_FILE"
print_msg_start
echo "############################################################################################################"
echo "############################################################################################################" >&5
sleep 3

MESSAGE="Send a curl to https://$HOSTSERVER. This will give an error"
print_msg_start
sleep 3
curl https://$HOSTSERVER 
curl https://$HOSTSERVER >&5 2>&5
print_msg_done

# Update the root CA certificates
MESSAGE="Install new root CA cerritifcate on this machine.Need to ssh to the server to copy the new root CA cert"
print_msg_start
echo
update-ca-trust enable
scp user@$IPSERVER:/tmp/rootca.crt /etc/pki/ca-trust/source/anchors/
chmod 0600 /etc/pki/ca-trust/source/anchors/rootca.crt
update-ca-trust extract
print_msg_done

MESSAGE="Send a curl again to https://$HOSTSERVER"
print_msg_start
sleep 3
curl $HOSTSERVER 
curl $HOSTSERVER >&5 2>&5
print_msg_done
