#!/bin/bash
HOST=m-net.arbornet.org
USER=yuvalif
PASSWD=yuval01

ftp -n -v $HOST << EOT
ascii
user $USER $PASSWD
prompt
cd public_html
put $1
bye
EOT
sleep 12
