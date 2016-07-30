#bin/sh
#docker registry server

sudo service docker start
# sftp conf 

groupadd sftp
sed -i 's/Subsystem/#Subsystem/' /etc/ssh/sshd_config
echo Subsystem     sftp    internal-sftp >> /etc/ssh/sshd_config
echo Match Group sftp >> /etc/ssh/sshd_config
echo       ChrootDirectory /home/%u >> /etc/ssh/sshd_config
echo       X11Forwarding no        >> /etc/ssh/sshd_config
echo       AllowTcpForwarding no   >> /etc/ssh/sshd_config
echo       ForceCommand internal-sftp >> /etc/ssh/sshd_config
sudo service ssh restart


# nfs conf
echo "/nfsdir *(rw,insecure,fsid=0,no_subtree_check)" >> /etc/exports
rm /etc/services
rm /etc/default/nfs-kernel-server
mv /shellscript/services /etc/
mv /shellscript/nfs-kernel-server /etc/default/

chmod 777 /nfsdir

service rpcbind start
service nfs-kernel-server start



cd /web/bin/

./dev




