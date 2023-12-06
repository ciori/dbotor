# DBoTor

**Distributed Backup over Tor**

This project helps a group of people/friends setup a number of little machines (Debian/Raspberry Pi OS) in order to have a distributed and replicated storage space where to store backups, through Tor.

## Architecture

The idea is that each person connects to its own node through a tor hidden service (using `scp`) and copy into its dedicated folder whathever they need to backup, then each node is configured to `rsync` its content to the other nodes.

If you want to retrieve the data, just `ssh` into one of the nodes through the proper tor hidden service.

Each person connects with a dedicated ssh key and is only able to view the content inside his/her own folder.

## Important

**You need to trust other nodes and owners !!!**

**You should previously encrypt the data you want to backup !!!**

## Requirements

Start from a Debian 12 or Raspberry Pi OS machine with a directory where you want to store the data to be backed up.

Steps:
- Initial install and update of the machine.
- Configure a non-root user for the normal management of the machine (with sudo permissions) where you will execute the scripts.
- Configure usual stuff like disks, partitions, network ip and ssh based on your liking.

## Setup

Follow these steps on each node.

Download and use the scripts:
1. `sudo ./setup.sh <DIR_PATH> <NODE_NAME>` to install the basic components
    - `<DIR_PATH>` is the directory in which you want to store all the nodes data
    - `<NODE_NAME>` is the name you want to give to your dbotor node and will also be used as the user name in the ssh/rsync connections between nodes. This does not represent the hostname.
    - you will be asked to enter the ssh public key you want to use to connect to this node (in order to ssh/scp into it) 
2. `sudo ./add_node.sh` to prepare your node to host another node's data
    - you will be asked to enter the ssh public key the other node will use to connect to this node (in order to rsync data into it) and another ssh public key that will be used by the other node's owner to retrieve data (by scp/ssh-ing into it)
3. `sudo ./connect_to_node.sh <OTHER_NODE_NAME>` to prepare your node to be able to sync data towards another node.
    - `<OTHER_NODE_NAME>` is the name the other node chose during setup.
    - follow what the script tells you. You will need to run this together with the `add_node.sh` script on the other node.

Now you can just copy the things you want to backup in your own node (with scp/ssh using the proper node user and key), or connect to one of the other node with the key you submitted during the configuration.

## Useful Stuff

Useful configurations:
- `swapoff -a`

### Raspberry Pi OS Preparation

Follow this if you want to start from a Raspberry Pi with an SD card and an SSD.

Steps:
- ...
- disk configuration with lvm volumes for data and var:
    - ...
