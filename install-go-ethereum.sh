#!/usr/bin/env bash
## Quick & simple install using ethereum ppa.

set -exo pipefail

USERNAME="go-ethereum"

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y build-essential git golang
git clone https://github.com/ethereum/go-ethereum
cd go-ethereum
make geth
cp build/bin/geth /usr/bin/

cat > /etc/systemd/system/${USERNAME}.service <<EOF
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
groupadd ${USERNAME} 
useradd --gid ${USERNAME} --home /var/lib/${USERNAME} ${USERNAME} 
cp -rp /root/${USERNAME} /var/lib/${USERNAME}
chown -R ${USERNAME}:${USERNAME} /var/lib/${USERNAME}
systemctl enable ${USERNAME}.service
