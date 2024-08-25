# THM-VMnet-Fix

## Overview

`thm-vmnet-fix.sh` is a script designed to automate the process of fixing split tunneling issues when using TryHackMe's OpenVPN configuration in VMware Workstation Pro. This script ensures that your VM can connect to both the TryHackMe VPN and the regular internet simultaneously by configuring routes, DNS, and network interfaces accordingly.

## Requirements

- **VMware Workstation Pro** with the following custom virtual network configuration:
  - Subnet IP: `10.10.0.0`
  - Gateway IP: `10.10.1.250`
  - DHCP Range: `10.10.128.0` - `10.10.255.254`
- **Kali Linux** (or any other Linux distribution within the VM)
- A valid TryHackMe OpenVPN configuration file

## How to Use

1. **Place your OpenVPN configuration file** in `~/Documents/thm/` and name it `havok.ovpn`.
2. **Ensure that your VM is configured** with the provided virtual network settings in VMware Workstation Pro.
3. **Run the script** by executing:
   ```bash
   sudo ./thm-vmnet-fix.sh
