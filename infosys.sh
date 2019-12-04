#!/usr/bin/env bash
# Needs CCZE utility installed
# Created: 20070109
# Updated: 20191126

export WAN=$(curl -s http://api.ipify.org/)
export LAN=$(ifconfig | grep -i inet | grep -v inet6 | grep -v "127.0.0.1" | cut -d: -f1 | cut -c14-27 | cut -d 'n' -f 1 | tr '\n' ' ')
export DNS=$(cat /etc/resolv.conf | grep nameserver | cut -d' ' -f2 | tr '\n' ' ')
export HOSTNAME=$(curl -s http://169.254.169.254/metadata/v1/HOSTNAME)
export INSTANCE_ID=$(curl -s http://169.254.169.254/metadata/v1/id)
export LAN_IP=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/anchor_ipv4/address)
export NETMASK=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/anchor_ipv4/NETMASK)
export GATEWAY=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/anchor_ipv4/GATEWAY)
export REGION=$(curl -s http://169.254.169.254/metadata/v1/region)
export ACTIVE_FLOATING=$(curl -s http://169.254.169.254/metadata/v1/floating_ip/ipv4/active)
export ACTIVE_FLOATING_IP=$(curl -s http://169.254.169.254/metadata/v1/floating_ip/ipv4/ip_address)

echo -e "HOSTNAME $HOSTNAME has instance ID $INSTANCE_ID in region $REGION" | ccze -A;
echo -e -----------------------------------------------------------------------------------------------------------
echo -e "Private IPv4 $LAN_IP has NETMASK $NETMASK and GATEWAY $GATEWAY" | ccze -A;
echo -e -----------------------------------------------------------------------------------------------------------
echo -e "Floating IP is active: $ACTIVE_FLOATING and has address $ACTIVE_FLOATING_IP" | ccze -A;
echo -e -----------------------------------------------------------------------------------------------------------
echo -e "WAN IP: $WAN" | ccze -A;
echo -e -----------------------------------------------------------------------------------------------------------
echo -e "LAN IP: $LAN" | ccze -A;
echo -e -----------------------------------------------------------------------------------------------------------
echo -e "DNS IP: $DNS" | ccze -A;
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