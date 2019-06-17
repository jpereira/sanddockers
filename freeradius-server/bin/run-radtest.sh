#!/bin/bash

cat <<EOF | radclient -x 127.0.0.1:1812 auth testing123
User-Name = "bob"
User-Password = "hello"
Cleartext-Password = "hello"
NAS-IP-Address = 127.0.1.1
NAS-Port = 1
Message-Authenticator = 0x00
ASA-IE-Proxy-PAC-URL = "${1:-caipirinha padrao}"
EOF
