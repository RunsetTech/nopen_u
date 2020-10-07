#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

sudo apt-get update

sudo apt-get install -y nodejs
sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install npm

# we make the script and its service here and start and enable it



mkdir roller

cd roller

sudo npm -init -y

sudo npm i express

sudo npm i express-rate-limit

cat > index.js <<EOF
const express = require('express')
const rateLimit = require("express-rate-limit");
const app = express()
app.get('/', function (req, res) {
  res.send('Error: 404')
})
app.listen(4444)
const limiter = rateLimit({
    windowMs: 8, // 15 minutes
    max: 3 // limit each IP to 3 requests per 8Ms
  });
app.use(limiter);
EOF

cd ..

cat > ghost.sh <<EOF
sudo node /home/ubuntu/roller/index.js
EOF

sudo cp ghost.sh /usr/bin/ghost.sh
sudo chmod +x /usr/bin/ghost.sh

cat > ghost.service <<EOF
[Unit]
Description=Ghost Service
[Service]
Type=simple
ExecStart=/bin/bash /usr/bin/ghost.sh
[Install]
WantedBy=multi-user.target
EOF

sudo cp ghost.service /etc/systemd/system/ghost.service
sudo chmod 644 /etc/systemd/system/ghost.service

sudo systemctl start ghost
sudo systemctl enable ghost

export IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
export PUBLICIP=$(dig +short myip.opendns.com @resolver1.opendns.com)
export PROTOCOL=1
export PORT=5566
export DNS=1
export CLIENT=client
wget https://raw.githubusercontent.com/RunsetTech/openvpn-install-for-multiple-users/master/openvpn-install.sh
chmod +x openvpn-install.sh
AUTO_INSTALL=y ./openvpn-install.sh

cat client.ovpn
echo nimaaaa
sudo reboot
