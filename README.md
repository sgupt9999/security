Msc. security related scripts
=============================

Create a new root CA and used it to secure an apache webserver
================================================================
* Create a new root CA and install an apache webserver. Then create a client and test using curl
 * inputs
    * has common inputs for server and client
 * root_ca_server.sh
    * creates a new root CA, installs apache , creates a virtual host on port 443 and secures using a certificate signed by the new CA
 * root_ca_client.sh
    * tests the apache webserver configuration by installing the new CA certificate  
 * common_fn
    * copy this file from the common repo into this directory
