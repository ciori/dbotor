#!/bin/bash

# Usage: sudo ./add_node.sh <DIR_PATH> <NODE_NAME>

# Variables
DIR_PATH=$1
NODE_NAME=$2

# Create user
mkdir -p ${DIR_PATH}/${NODE_NAME}
useradd -m -d ${DIR_PATH}/${NODE_NAME} -s /bin/bash --disabled-password ${NODE_NAME}
cd ${DIR_PATH}/${NODE_NAME}

# Configure ssh access for the other node and owner
mkdir .ssh
touch .ssh/authorized_keys

echo "Please paste the ssh public key the \"${NODE_NAME}\" node ITSELF will use to rsync data, then press Enter:"
read
grep -qxF "${REPLY}" .ssh/authorized_keys || echo "${REPLY}" >> .ssh/authorized_keys

echo "Please paste the ssh public key the \"${NODE_NAME}\" node OWNER will use to retrieve data, then press Enter:"
read
grep -qxF "${REPLY}" .ssh/authorized_keys || echo "${REPLY}" >> .ssh/authorized_keys

chmod 600 .ssh/authorized_keys
chown ${NODE_NAME}:${NODE_NAME} -R ${DIR_PATH}/${NODE_NAME}

# Output
echo ""
echo "----------------------------------------------------------------"
echo ""
echo "Use this Tor Hidden Service to connect to this node:"
cat /var/lib/tor/${NODE_NAME}/hostname
echo ""