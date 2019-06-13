
cat <<EOF | radclient -x 172.17.0.2:1812 auth testing123
User-Name = "jorge"
User-Password = "jorge"
NAS-IP-Address = 127.0.1.1
NAS-Port = 1
Message-Authenticator = 0x00
Cleartext-Password = "jorge"
ASA-IE-Proxy-PAC-URL = "${1:-caipirinha padrao}"
EOF


