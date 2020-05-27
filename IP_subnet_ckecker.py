#!/usr/bin/python3
from ipaddress import ip_address,ip_network
import argparse

parser = argparse.ArgumentParser(description='Validate IP address and networks')
parser.add_argument("--ip_address", '-a', type=str, help='Validate IP address', dest="ip")
parser.add_argument("--network", '-n', type=str, help='Validate network', dest="net")
args = parser.parse_args()
if not args.ip and not args.net:
	print("You should set --ip_address or --network parameter")
	exit(1)
elif args.ip and args.net:
	print("You should set only one of these parameters: --ip_address or --network parameter")
	exit(1)
elif args.ip:
	try:
		ip_address(args.ip)
		print("True")
	except:
		print("False")
else:
	try:
		ip_network(args.net)
		print("True")
	except:
		print("False")
exit(0)
