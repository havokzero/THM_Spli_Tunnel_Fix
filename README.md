THM-VMnet-Fix
Overview

stfix.sh is a script designed to automate the process of fixing split tunneling issues when using TryHackMe's OpenVPN configuration in VMware Workstation Pro. This script ensures that your VM can connect to both the TryHackMe VPN and the regular internet simultaneously by configuring routes, DNS, and network interfaces accordingly.
Requirements

    VMware Workstation Pro with the following custom virtual network configuration:
        Subnet IP: 10.10.0.0
        Gateway IP: 10.10.1.250
        DHCP Range: 10.10.128.0 - 10.10.255.254
    Kali Linux (or any other Linux distribution within the VM)
    A valid TryHackMe OpenVPN configuration file

How to Use
Clone the Repository

    Clone the repository to your local machine:

    bash

git clone https://github.com/havokzero/THM_Spli_Tunnel_Fix.git
cd THM_Spli_Tunnel_Fix

Place your OpenVPN configuration file in ~/Documents/thm/ and name it havok.ovpn.

Ensure that your VM is configured with the provided virtual network settings in VMware Workstation Pro.

Run the script by executing:

bash

    sudo ./stfix.sh

    Enter the target machine's IP address or URL when prompted.

    The script will:
        Stop any running OpenVPN services.
        Flush existing network routes and reconfigure DHCP.
        Set the appropriate default route for internet access.
        Update DNS settings.
        Start the OpenVPN connection.
        Test both internet and TryHackMe VPN connectivity using curl 10.10.10.10/whoami.

    Check the output to ensure that all connections are working properly.

Troubleshooting

    If the script reports that the gateway is not reachable, ensure your VM's network adapter is correctly configured.
    The script will attempt to resolve any issues automatically, but if problems persist, you may need to manually adjust the network settings.

License

This project is licensed under the MIT License.
