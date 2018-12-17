#!/bin/sh
## Quick & simple install ethereum as service using ethereum ppa for Ubuntu.
# bash <(curl -s https://raw.githubusercontent.com/jeremybusk/ethereum/master/install-go-ethereum.sh)

set -e

USERNAME="my-go-ethereum"

echo "To start service: systemctl start ${USERNAME}"
echo "Ethereum data location: /var/lib/${USERNAME}/.ethereum"

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

DISTRIB_CODENAME=$(cat /etc/*release | grep '^DISTRIB_CODENAME=' | awk -F= '{print $2}')
if [ "${DISTRIB_CODENAME}" = "bionic" ] || [ "${DISTRIB_CODENAME}" = "xenial" ] ; then
    echo "Supported host operating system Ubuntu Bionic/Buster 16.04/18.04."
else
    echo "ERROR! Invalid host operating system."
    exit 1
fi

sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y ethereum

cat > /lib/systemd/system/${USERNAME}.service <<EOF
[Unit]
Description=Ethereum Go Client
After=network.target

[Service]
User=${USERNAME}
WorkingDirectory=/var/lib/${USERNAME}
ExecStart=/usr/bin/geth --ws --rpc --rpcaddr 0.0.0.0 --rpcport 8545 
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

mkdir -p /var/lib/${USERNAME}
useradd --home /var/lib/${USERNAME} ${USERNAME}
chown ${USERNAME}:${USERNAME} /var/lib/${USERNAME}

systemctl enable ${USERNAME}.service
# deb-systemd-helper enable ${USERNAME}.service

echo "======================================================"
echo "To start service: systemctl start ${USERNAME}"
echo "Ethereum data location: /var/lib/${USERNAME}/.ethereum"

exit 0
