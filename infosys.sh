#!/usr/bin/env bash
# Needs CCZE utility installed
# Created: 20070109
# Updated: 20191126

export wan=$(curl -s http://api.ipify.org/)
export lan=$(ifconfig | grep -i inet | grep -v inet6 | grep -v "127.0.0.1" | cut -d: -f1 | cut -c14-27 | cut -d 'n' -f 1 | tr '\n' ' ')
export dns=$(cat /etc/resolv.conf | grep nameserver | cut -d' ' -f2 | tr '\n' ' ')
export hostname=$(curl -s http://169.254.169.254/metadata/v1/hostname)
export instanceId=$(curl -s http://169.254.169.254/metadata/v1/id)
export lanIp=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/anchor_ipv4/address)
export netmask=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/anchor_ipv4/netmask)
export gateway=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/anchor_ipv4/gateway)
export region=$(curl -s http://169.254.169.254/metadata/v1/region)
export activeFloating=$(curl -s http://169.254.169.254/metadata/v1/floating_ip/ipv4/active)
export activeFloatingIp=$(curl -s http://169.254.169.254/metadata/v1/floating_ip/ipv4/ip_address)

echo -e "Hostname $hostname has instance ID $instanceId in region $region" | ccze -A;
echo -e -----------------------------------------------------------------------------------------------------------
echo -e "Private IPv4 $lanIp has netmask $netmask and gateway $gateway" | ccze -A;
echo -e -----------------------------------------------------------------------------------------------------------
echo -e "Floating IP is active: $activeFloating and has address $activeFloatingIp" | ccze -A;
echo -e -----------------------------------------------------------------------------------------------------------
echo -e "WAN IP: $wan" | ccze -A;
echo -e -----------------------------------------------------------------------------------------------------------
echo -e "LAN IP: $lan" | ccze -A;
echo -e -----------------------------------------------------------------------------------------------------------
echo -e "DNS IP: $dns" | ccze -A;
echo -e -----------------------------------------------------------------------------------------------------------
echo "You are on:"
uname -a | ccze -A;
echo -e -----------------------------------------------------------------------------------------------------------
echo "Connected users are:"
who | ccze -A;
echo -e -----------------------------------------------------------------------------------------------------------
echo "Running tasks are:"
w;
echo -e -----------------------------------------------------------------------------------------------------------
echo "Disks usage is:"
df -h | ccze -A;
echo -e -----------------------------------------------------------------------------------------------------------
echo "Memory usage is:"
free -h | ccze -A
exit 0