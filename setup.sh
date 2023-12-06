#!/bin/bash

# Usage: sudo ./setup.sh <DIR_PATH> <NODE_NAME>

# Variables
DIR_PATH=$1
NODE_NAME=$2

# General
apt update && apt upgrade -y
touch /root/dbotor.conf
chmod 600 /root/dbotor.conf
grep -qxF "DIR_PATH=$1" /root/dbotor.conf || echo "DIR_PATH=$1" >> /root/dbotor.conf
grep -qxF "NODE_NAME=$2" /root/dbotor.conf || echo "NODE_NAME=$2" >> /root/dbotor.conf

# Firewall
apt install -y ufw fail2ban
ufw allow ssh
ufw enable
systemctl enable --now ufw

# Create user
mkdir -p ${DIR_PATH}/${NODE_NAME}
useradd -m -d ${DIR_PATH}/${NODE_NAME} -s /bin/bash --disabled-password ${NODE_NAME}
cd ${DIR_PATH}/${NODE_NAME}

# Configure user ssh access
mkdir .ssh
touch .ssh/authorized_keys
echo "Please paste the ssh public key you want to use to access ${NODE_NAME} data, then press Enter:"
read
grep -qxF "${REPLY}" .ssh/authorized_keys || echo "${REPLY}" >> .ssh/authorized_keys
chmod 600 .ssh/authorized_keys
chown ${NODE_NAME}:${NODE_NAME} -R ${DIR_PATH}/${NODE_NAME}

# Configure Tor
apt install -y tor
cp /etc/tor/torrc /etc/tor/torrc.backup
cat <<EOF > /etc/tor/torrc
User tor
Log notice syslog
DataDirectory /var/lib/tor

HiddenServiceDir /var/lib/tor/${NODE_NAME}/
HiddenServicePort 22 127.0.0.1:22
EOF
systemctl restart tor

# Configure Rsync
apt install -y rsync
cd /root
cat <<EOF > sync.sh
#!/bin/bash
torify rsync -Pa -e "ssh -i $2" $1 $3
EOF
chmox 700 sync.sh

# Output
echo ""
echo "----------------------------------------------------------------"
echo ""
echo "Use this Tor Hidden Service to connect to this node:"
cat /var/lib/tor/${NODE_NAME}/hostname
echo ""
echo "Now you can add other nodes and configure access to other nodes."
echo ""