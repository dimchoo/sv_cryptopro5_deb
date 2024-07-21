#!/bin/sh

yes Y | /crypto_distr/install.sh kc1
ln -s /opt/cprocsp/sbin/amd64/cpconfig /usr/bin/cpconfig
ln -s /opt/cprocsp/bin/amd64/certmgr /usr/bin/certmgr
ln -s /opt/cprocsp/bin/amd64/cryptcp /usr/bin/cryptcp
yes o | certmgr -install -store root -file /crypto_cer/rootca.cer
certmgr -install -file /crypto_cer/subca.cer
cp /crypto_src/certs_info /usr/bin/certs_info
chmod +x /usr/bin/certs_info
certs_info
Y yes | apt-get update && apt-get install expect

exec "$@"