 #!/bin/bash
 if [ "$(whoami)" != "root" ]
then
    sudo su -s "$0"
    exit
fi
sleep 5
sudo amazon-linux-extras install epel -y
sudo yum install epel-release -y
sudo yum install git -y
sudo yum update -y
sudo yum install ufw -y
sudo yum -y install mariadb-server -y
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo mysql -e "CREATE DATABASE zippyops"
sudo mysql -e "CREATE USER zippyops@10.0.0.11 IDENTIFIED BY 'zippyops';"
sudo mysql -e "GRANT ALL PRIVILEGES ON zippyops.* TO 'zippyops'@'10.0.0.11';"
sudo mysql -e "FLUSH PRIVILEGES;"

sudo yum groupinstall 'Development Tools' -y
sudo wget http://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm
sudo yum install mysql57-community-release-el7-9.noarch.rpm -y
sudo yum install mysql-community-server mysql-community-devel -y 
sudo yum install python-pip -y
pip install mysqlclient
echo yes | ufw enable
ufw allow 3306
ufw allow 22
sudo systemctl start mysqld
sudo systemctl enable mysqld
