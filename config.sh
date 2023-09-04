#!/bin/bash

echo """
#################################################
#		SNMP				#
#					        #
################################################
"""
function get_ipaddress() {
	ipadd=$(ip a | grep 192.168.1 | tr -s " " | cut -d " " -f3 | cut -d "/" -f1)
	echo $ipadd > ip.txt
	export IPADD=$ipadd
}

function install_snmp_distro_debian() {
	echo "[+] UPDATE"
	apt update -y >/dev/null
	echo "[+] INSTALL SNMP"
	apt install snmp -y >/dev/null
	if [ $? == 0 ]; then
		echo "[+] Installation success"
	else
		echo "[-] Installation failed"
	fi
}
function configure_snmp() {
	echo "[+] CONFIGURE SNMP"
	mv /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.bak | true
	echo "rocommunity public" > /etc/snmp/snmpd.conf
	echo "master  agentx" >> /etc/snmp/snmpd.conf
	echo "agentaddress 127.0.0.1,$IPADD,[::1]" >> /etc/snmp/snmpd.conf
	echo "view   systemonly  included   .1.3.6.1.2.1.1" >> /etc/snmp/snmpd.conf
	echo "view   systemonly  included   .1.3.6.1.2.1.25.1" >> /etc/snmp/snmpd.conf
	echo "includeDir /etc/snmp/snmpd.conf.d" >> /etc/snmp/snmpd.conf
}
function restart_snmp() {
	echo "[+] START SNMP"
	systemctl enable snmpd --now > /dev/null
	systemctl restart snmpd > /dev/null
	systemctl status snmpd
}

get_ipaddress
install_snmp_distro_debian
configure_snmp
restart_snmp
