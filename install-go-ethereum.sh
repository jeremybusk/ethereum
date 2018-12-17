#!/bin/sh
## Quick & simple install ethereum as service using ethereum ppa for Ubuntu.
# bash <(curl -s https://raw.githubusercontent.com/jeremybusk/ethereum/master/install-go-ethereum.sh)
# systemctl start go-ethereum
# /var/lib/go-ethereum/.ethereum

set -e

USERNAME="go-ethereum"

ID=$(cat /etc/*release | grep '^DISTRIB_CODENAME=' | awk -F= '{print $2}')
if [ "${ID}" = "bionic" ] || [ "${ID}" "buster" ] ; then
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

cat > /etc/systemd/system/${USERNAME}.service <<EOF
[Unit]
Description=Ethereum Go Client
After=network.target

[Service]
User=${USERNAME}
WorkingDirectory=/var/lib/${USERNAME}
ExecStart=/usr/bin/go-ethereum --ws --rpc --rpcaddr 0.0.0.0 --rpcport 8545 
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

mkdir -p /var/lib/${USERNAME}
useradd --home /var/lib/${USERNAME} ${USERNAME}
chown ${USERNAME}:${USERNAME} /var/lib/${USERNAME}

systemctl enable ${USERNAME}.service

exit 0
