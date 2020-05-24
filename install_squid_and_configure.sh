#!/bin/bash
if [ $EUID != 0 ]
then
	echo "Please run as root. Use sudo."
	exit 1
fi

listen='0.0.0.0'
port='3128'
http_allowed=$false
localnet=''

if [[ $# -eq 0 ]]; then
    echo -e "No parameters found. "
    exit 1
fi

while [ -n "$1" ]
do
	case "$1" in
		--help) echo "There will be help" ;;
		--listen) listen="$2"
			shift ;;
		--port) port="$2"
			shift ;;
		--allow-http) http_allowed=$true ;;
		--localnet) localnet="$2"
			shift ;;
		*) echo "$1 is invalod option" 
			exit 1 
		esac
		shift
done


if   [ -z $localnet ]
then
	echo "You shoud set --localnet parameter"
	exit 1
fi

apt update
apt install squid -y
echo "Creating squid.conf backup"
cp /etc/squid/squid.conf /etc/squid/squid.conf.backup
sed -i "s!#acl localnet src 192.168.0.0/16!acl localnet src $localnet!" /etc/squid/squid.conf
sed -i "s/http_port 3128/http_port $listen:$port/" /etc/squid/squid.conf
sed -i "s/#http_access allow localnet/http_access allow localnet/" /etc/squid/squid.conf

if [ http_allowed ]
then
	sed -i "s/http_access deny !Safe_ports/# http_access deny !Safe_ports/" /etc/squid/squid.conf
fi

service squid restart

exit 0
