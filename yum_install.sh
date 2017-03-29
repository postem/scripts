#!/bin/bash

yum install -y epel-release

cat dependencias/yum/dep_yum | xargs sudo yum install -y

sudo wget ftp://195.220.108.108/linux/centos/7.3.1611/os/x86_64/Packages/xmlsec1-1.2.20-5.el7.i686.rpm
yum install -y xmlsec*.rpm

rpm -Uvh http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-centos7-amd64.rpm

sudo -H pip install --upgrade pip
sudo -H pip install --upgrade setuptools
cat dependencias/yum/dep_pip | xargs sudo pip install

yum install -y postgresql-server
postgresql-setup initdb
systemctl start postgresql
systemctl enable postgresql

sudo -u postgres createuser odoo
sudo su - postgres -c "createuser -s odoo" 2> /dev/null || true
sudo -u postgres -- psql -c "ALTER USER postgres WITH PASSWORD '123';"
sudo -u postgres -- psql -c "DROP ROLE odoo;"
sudo -u postgres -- psql -c "CREATE ROLE odoo LOGIN ENCRYPTED PASSWORD 'md5f7b7bca97b76afe46de6631ff9f7175c' NOSUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION"

groupadd odoo
adduser --home /odoo --shell /bin/bash -g odoo odoo
gpasswd -a username wheel

sudo mkdir /var/log/odoo
sudo chown odoo:odoo /var/log/odoo

git clone -b 10.0 --single-branch https://github.com/BradooTech/odoo /odoo/odoo-server/
git clone https://www.github.com/bradootech/odoo-brasil /odoo/odoo-brasil
git clone https://github.com/Trust-Code/trustcode-addons /odoo/trustcode-addons
git clone https://github.com/BradooDev/Enterprise /odoo/Enterprise

sudo su odoo -c "mkdir odoo/custom"
sudo su odoo -c "mkdir odoo/custom/addons"

sudo chown -R odoo:odoo /odoo/*


# yum deplist odoo | awk '/provider:/ {print $2}' | sort -u | xargs yum -y install


firewall-cmd --zone=public --add-port=8069/tcp --permanent
firewall-cmd --reload