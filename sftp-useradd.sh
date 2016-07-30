#! /bin/sh

USER=$1
PASSWD=$2

sudo useradd -g sftp -m -s /sbin/nologin "$USER" 

echo "$USER:$PASSWD" | chpasswd

sudo chown root:root /home/"$USER"

sudo chmod 755 /home/"$USER"

sudo service ssh restart







