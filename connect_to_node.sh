#!/bin/bash

# Usage: sudo ./connect_to_node.sh <DIR_PATH> <MY_NODE_NAME> <OTHER_NODE_NAME>

# Variables
DIR_PATH=$1
MY_NODE_NAME=$2
OTHER_NODE_NAME=$2

# Configure ssh access to the other node
ssh-keygen -t rsa -b 4096 -N '' -C "${NODE_NAME}" -f ${DIR_PATH}/${MY_NODE_NAME}/.ssh/ssh_key_${OTHER_NODE_NAME}
chown ${MY_NODE_NAME}:${MY_NODE_NAME} ${DIR_PATH}/${MY_NODE_NAME}/.ssh/ssh_key_${OTHER_NODE_NAME}
chown ${MY_NODE_NAME}:${MY_NODE_NAME} ${DIR_PATH}/${MY_NODE_NAME}/.ssh/ssh_key_${OTHER_NODE_NAME}.pub

echo ""
echo "You need to add this node to the node you are trying to connect to."
echo "This is the public key you will need to insert using the \"add_node.sh\" script on the other node:"
cat ${DIR_PATH}/${MY_NODE_NAME}/.ssh/ssh_key_${OTHER_NODE_NAME}.pub
echo ""
echo "Also remember you will need to insert another ssh public key,
which YOU will use to connect directly to that node (scp/ssh)."

echo ""
echo "Please wait until your node user has been prepared on the other node."
echo "Then insert the onion address of the other node and press Enter:"
read

# Configure rsync crontab
SOURCE="${DIR_PATH}/${MY_NODE_NAME}"
KEY="${DIR_PATH}/${MY_NODE_NAME}/.ssh/ssh_key_${OTHER_NODE_NAME}"
TARGET="${OTHER_NODE_NAME}:${REPLY}"
crontab -l > temp_cron
grep -qxF "*/30 * * * * /root/sync.sh ${SOURCE} ${KEY} ${TARGET}" temp_cron || echo "*/30 * * * * /root/sync.sh ${SOURCE} ${KEY} ${TARGET}" >> temp_cron
crontab temp_cron
rm temp_cron

# Output
echo ""
echo "----------------------------------------------------------------"
echo ""
echo "The rsync crontab has been set up."
echo "You can now also connect directly with your public key to the other node:"
echo "ssh/scp -i <your private key> ${TARGET} ..."
echo ""