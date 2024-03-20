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

Useful configurations and secondary guides.

### Raspberry Pi OS Preparation

Follow this if you want to start from a Raspberry Pi with an SD card and an SSD.

1. Create SD card:
    - use rpi imager and press `crtl + shift + x` to customize install:
        - set hostname
        - set username and password for your normal management user (you will change the password later)
        - set locale
    - enable ssh with your public key
    - flash the os (Raspberry Pi OS 64bit Lite) into the sd card

2. Initial configuration:
    - start the pi with the sd card and the ssd inserted
    - login with the configured user and ssh key
    - change password: `passwd <USER>`
    - become root: `sudo -i`
    - execute:
        ```
        apt update -y
        apt upgrade -y
        apt autoremove -y
        apt install -y vim tree git lvm2
        ```
    - increase sd card lifespan:
        - `swapoff -a`
        - add/modify these in `vim /etc/fstab` (also remove swap mount point if present):
            ```
            tmpfs /tmp tmpfs defaults,noatime,nosuid,size=100m 0 0
            tmpfs /var/tmp tmpfs defaults,noatime,nosuid,size=30m 0 0
            tmpfs /var/log tmpfs defaults,noatime,nosuid,mode=0755,size=100m 0 0
            tmpfs /var/run tmpfs defaults,noatime,nosuid,mode=0755,size=2m 0 0
            tmpfs /var/spool/mqueue tmpfs defaults,noatime,nosuid,mode=0700,gid=12,size=30m 0 0
            ```
        - `systemctl daemon-reload`
    - reboot, login and switch to the root user again

3. Ssh configuration:
    ```
    sed -i "/PermitRootLogin/c\PermitRootLogin no" /etc/ssh/sshd_config
    sed -i "/PasswordAuthentication/c\PasswordAuthentication no" /etc/ssh/sshd_config
    systemctl restart ssh
    ```

4. Firewall configuration:
    ```
    apt install -y ufw fail2ban
    ufw allow ssh
    ufw enable
    systemctl enable --now ufw
    ```

5. Disks configuration:
    - clean the disk and create a partition with: `sudo cfdisk /dev/<...>`
    - check the uuid of your new partition with `lsblk -f`
    - set mount path for the data volume: `export DIR=...` (where you will then setup dbotor)
    - setup lvm volumes:
        ```
        pvcreate /dev/disk/by-uuid/<...>
        vgcreate datavg /dev/disk/by-uuid/<...>
        lvcreate -n datalv -L 850G datavg
        mkfs.ext4 /dev/datavg/datalv
        mkdir ${DIR}
        mount /dev/datavg/datalv ${DIR}
        echo "/dev/datavg/datalv ${DIR} ext4 defaults,noatime,discard 0 0" >> /etc/fstab
        systemctl daemon-reload
        mount -a
        ```

6. Remove sudo without password: `rm -rf /etc/sudoers.d/010_pi-nopasswd`

7. Set a static IP with:
    - `nmtui`
    - reboot the system
