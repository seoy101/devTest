#! /bin/sh

USER=$1
PASSWD=$2

sudo useradd -g sftp -m "$USER" 

echo "$USER:$PASSWD" | chpasswd

sudo chown root:sftp /home/"$USER"

sudo chmod 750 /home/"$USER"

sudo service ssh restart







