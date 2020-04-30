 #!/bin/bash
 if [ "$(whoami)" != "root" ]
then
    sudo su -s "$0"
    exit
fi
sleep 5
sudo amazon-linux-extras install epel -y
sudo yum install git -y
sudo yum install ufw -y
sudo yum install python-django -y
sudo yum groupinstall 'Development Tools' -y
sudo wget http://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm
sudo yum install mysql57-community-release-el7-9.noarch.rpm -y
sudo yum install mysql-community-server mysql-community-devel -y
sudo yum install python-pip -y
pip install mysqlclient
echo y | ufw enable
ufw allow 3306
ufw allow 22
ufw allow 8000
sudo systemctl start mysqld
sudo systemctl enable mysqld
