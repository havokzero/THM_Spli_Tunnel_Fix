#!/bin/bash

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Prompt the user for the target machine IP or URL
read -p "Enter the target machine IP address or URL: " TARGET

# Strip the 'http://' or 'https://' prefix if present
TARGET=$(echo "$TARGET" | sed -e 's~http[s]*://~~g')

# Check if the input is a URL or IP address
if [[ $TARGET =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(:[0-9]+)?$ ]]; then
  TARGET_IP=$(echo "$TARGET" | cut -d':' -f1)
  echo -e "${GREEN}Detected IP address: $TARGET_IP${NC}"
else
  echo -e "${YELLOW}Checking /etc/hosts for the URL...${NC}"
  TARGET_IP=$(grep -w "$TARGET" /etc/hosts | awk '{ print $1 }')
  echo -e "${BLUE}Result from /etc/hosts check: $TARGET_IP${NC}"

  if [ -z "$TARGET_IP" ]; then
    echo -e "${YELLOW}Resolving URL to IP address via DNS...${NC}"
    TARGET_IP=$(getent hosts "$TARGET" | awk '{ print $1 }')
    if [ -z "$TARGET_IP" ]; then
      echo -e "${RED}Error: Could not resolve the URL to an IP address.${NC}"
      exit 1
    else
      echo -e "${GREEN}Resolved IP address via DNS: $TARGET_IP${NC}"
    fi
  else
    echo -e "${GREEN}Found IP address in /etc/hosts: $TARGET_IP${NC}"
  fi
fi

# Verify connectivity to the gateway before proceeding
echo -e "${YELLOW}Testing reachability of the default gateway: 10.10.1.250${NC}"
if ping -c 4 10.10.1.250 > /dev/null; then
  echo -e "${GREEN}Default gateway is reachable.${NC}"
else
  echo -e "${RED}Error: Default gateway is not reachable. Please check your network configuration.${NC}"
  exit 1
fi

# Stop OpenVPN service if running
echo -e "${YELLOW}Stopping any running OpenVPN service...${NC}"
sudo systemctl stop openvpn

# Flush existing routes
echo -e "${YELLOW}Flushing existing routes...${NC}"
sudo ip route flush table main

# Re-acquire DHCP settings
echo -e "${YELLOW}Re-acquiring DHCP settings...${NC}"
sudo dhclient -r eth0
sudo dhclient eth0

# Add the default route
echo -e "${YELLOW}Adding the default route...${NC}"
sudo ip route add default via 10.10.1.250 dev eth0

# Restart networking
echo -e "${YELLOW}Restarting networking service...${NC}"
sudo systemctl restart networking

# Update /etc/resolv.conf with Google's DNS
echo -e "${YELLOW}Updating DNS settings...${NC}"
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null

# Test regular internet connectivity
echo -e "${YELLOW}Testing internet connectivity...${NC}"
if ping -c 4 8.8.8.8 > /dev/null; then
  echo -e "${GREEN}Internet connectivity is working.${NC}"
else
  echo -e "${RED}Error: Internet connectivity is not working.${NC}"
  exit 1
fi

# Test TryHackMe VPN connectivity
echo -e "${YELLOW}Testing TryHackMe VPN connectivity...${NC}"
sleep 10  # Allow time for OpenVPN to establish the connection
THM_TEST=$(curl -s 10.10.10.10/whoami)

if [[ $THM_TEST == 10.* ]]; then
  echo -e "${GREEN}Successfully connected to TryHackMe VPN. Your IP: $THM_TEST${NC}"
else
  echo -e "${RED}Failed to connect to TryHackMe VPN. Please check your VPN connection and try again.${NC}"
  exit 1
fi

# Final test to ensure everything is working
echo -e "${YELLOW}Pinging $TARGET_IP...${NC}"
ping -c 4 $TARGET_IP

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Successfully connected to $TARGET_IP!${NC}"
else
    echo -e "${RED}Failed to connect to $TARGET_IP. Please check your VPN connection and try again.${NC}"
    exit 1
fi

echo -e "${GREEN}Script execution completed.${NC}"
