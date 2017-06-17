#!/bin/bash

read -p "Deseja Instalar o Banco de Dados? [Sim | Não] " INSTALL_DB

#Configurando repositorio EPEL 7
sudo yum update -y
sudo yum install wget
wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm
sudo rpm -ivh epel-release-7-9.noarch.rpm
wget https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
sudo mv RPM-GPG-KEY-EPEL-7 /etc/pki/rpm-gpg/

#Atualizando os pacotes
sudo yum update -y

#Instalando pip e atualizando o pip
sudo yum install python-pip -y
sudo -H pip install --upgrade pip

#Atualizando o setuptools do pip
sudo -H pip install --upgrade setuptools

#Instalando os pacotes do sistema
cat dependencias/redhat/yum | xargs sudo yum install -y --enablerepo=epel

sudo yum remove xmlsec1-1.2.20-5.el7.x86_64 -y
sudo yum install xmlsec1-1.2.18-4.el7.x86_64 -y
sudo yum install xmlsec1-devel.x86_64 -y

#Instalando as bibliotecas python
cat dependencias/redhat/pip | xargs sudo pip install

#Adicionando o grupo e usuario Odoo, e adicionando no grupo wheel
sudo groupadd odoo
sudo adduser --home /odoo --shell /bin/bash -g odoo odoo
sudo gpasswd -a odoo wheel

#Criando a pasta de log e dando permissão para o usuario do Odoo
sudo mkdir /var/log/odoo
sudo chown odoo:odoo /var/log/odoo

#Clonando o repositório do Odoo
sudo git clone -b 10.0 https://github.com/odoo/odoo /odoo/odoo-server --depth 1

#Alterando a permissão da pasta do Odoo
sudo chown -R odoo:odoo /odoo/

if [ $INSTALL_DB == "Sim" ]; then
	#Instalando o postgres
	sudo yum install -y postgresql postgresql-server postgresql-devel postgresql-contrib postgresql-docs -y
	#Ininciando o serviço de configuraçao inicial do postgres
	sudo postgresql-setup initdb
	#Alterando os arquivos de configuraçao do postgres
	sudo sed -i s/"listen_addresses = 'localhost'"/"listen_addresses = ''"/g /var/lib/pgsql/data/postgresql.conf
	sudo sed -i s/"local   all             all                                     ident"/"local   all             all                                     trust"/g /var/lib/pgsql/data/pg_hba.conf
	sudo sed -i s/"32            ident"/"32            md5"/g /var/lib/pgsql/data/pg_hba.conf

	#Iniciando servico do postgres
	sudo service postgresql start
	#Criando o usuario odoo no banco, alterando a senha do usuario do postgres, e criando uma role para o usuario do odoo com permisao de cricao de db
	sudo -u postgres createuser odoo
	sudo su - postgres -c "createuser -s odoo" 2> /dev/null || true
	sudo -u postgres -- psql -c "ALTER USER postgres WITH PASSWORD '123';"
	sudo -u postgres -- psql -c "DROP ROLE odoo;"
	sudo -u postgres -- psql -c "CREATE ROLE odoo LOGIN ENCRYPTED PASSWORD 'md5f7b7bca97b76afe46de6631ff9f7175c' NOSUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION"
fi
