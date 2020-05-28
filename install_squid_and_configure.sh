#!/bin/bash
help()
{
echo "This script install and configure squid"
echo "Example:"
echo "install_squid_and_configure.sh --localnet 192.168.0.0/24 --listen 192.168.0.10 --port 3128 --allow-http"
echo
echo "Options:"
echo "--listen	Listen on this IP address. By default is 0.0.0.0"
echo "--port		Listen on this port. By default is 3128"
echo "--localnet	Traffic is allowed for host tfom this network. REQUIRED!"
echo "--allow-http	If this option is set non SSL ports are allowed"
echo "--help		Show help"
echo
}

if [ $EUID != 0 ]
then
	echo "Please run as root. Use sudo."
	exit 1
fi

listen="0.0.0.0"
port="3128"
http_allowed=$false
localnet=""

if [[ $# -eq 0 ]]; then
    echo "No parameters were found. "
    exit 1
fi

while [ -n "$1" ]
do
	case "$1" in
		--help) help
			exit 0 ;;
		--listen) if [ $($(pwd)/IP_subnet_ckecker.py -a $2) =  "False" ]
			then
				echo "$2 is not IP Address"
				exit 1
			fi 
			listen="$2"
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

if [ $($(pwd)/IP_subnet_ckecker.py -n $localnet) =  "False" ]
then
        echo "$localnet is not network"
        exit 1
fi

if [ $($(pwd)/IP_subnet_ckecker.py -a $listen) =  "False" ]
then
        echo "$listen is not IP Address"
        exit 1
fi


if ! [[ $listen = "0.0.0.0" ]]
then
if ! [[ $( ip a ) =~ .*[^0-9]"$listen"[^0-9].* ]]
then
	echo "$listen is not your IP Address"
        exit 1
fi
fi

if ! [[ $port =~ ^[0-9]+$ ]]
then
        echo "$port is not number"
        exit
fi

if [ $port -gt 65535 ] || [ $port -lt 0 ]
then
        echo "$port is invalid port number"
        exit
fi

echo "Installing squid..."
apt update
apt install squid -y

if ! [ -e /etc/squid/squid.conf ]
then
	echo "Something went wrong. There is no file etc/squid/squid.conf"
	exit 1
fi

echo "Creating squid.conf backup..."
cp /etc/squid/squid.conf /etc/squid/squid.conf.backup

echo "Confuguring squid..."
sed -i "s!#acl localnet src 192.168.0.0/16!acl localnet src $localnet!" /etc/squid/squid.conf
sed -i "s/http_port 3128/http_port $listen:$port/" /etc/squid/squid.conf
sed -i "s/#http_access allow localnet/http_access allow localnet/" /etc/squid/squid.conf
if [ http_allowed ]
then
	sed -i "s/http_access deny !Safe_ports/# http_access deny !Safe_ports/" /etc/squid/squid.conf
fi

echo "Done. Restarting squid..."
service squid restart

exit 0
