#!/bin/bash

read -p "Deseja Instalar o Banco de Dados? [Sim | Não] " INSTALL_DB

#Configurando repositorio EPEL 7
wget https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
sudo mv RPM-GPG-KEY-EPEL-7 /etc/pki/rpm-gpg/
sudo sed -i s/"6"/"7"/g /etc/yum.repos.d/epel.repo

#Atualizando os pacotes
sudo yum update -y

#Instalando pip e atualizando o pip
sudo yum install python-pip
sudo -H pip install --upgrade pip

#Removendo o pip dentro da pasta de programa e criando um link com o pip local
sudo rm -rf /usr/bin/pip
sudo ln -s /usr/local/bin/pip /usr/bin/

#Atualizando o setuptools do pip
sudo -H pip install --upgrade setuptools

#Instalando os pacotes do sistema
cat dependencias/amazon/yum | xargs sudo yum install -y --enablerepo=epel

#Removendo o pip dentro da pasta de programa e criando um link com o pip local
#Necessario porque o pip recria a imagem antiga
sudo rm -rf /usr/bin/pip
sudo ln -s /usr/local/bin/pip /usr/bin/

#Instalando as bibliotecas python
cat dependencias/amazon/pip | xargs sudo pip install

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

#Voltando as configurações do repositório EPEL
sudo sed -i s/"7"/"6"/g /etc/yum.repos.d/epel.repo

if [ $INSTALL_DB == "Sim" ]; then
	#Instalando o postgres
	sudo yum install -y postgresql postgresql-server postgresql-devel postgresql-contrib postgresql-docs
	#Ininciando o serviço de configuraçao inicial do postgres
	sudo service postgresql initdb
	#Alterando os arquivos de configuraçao do postgres
	sudo sed -i s/"listen_addresses = 'localhost'"/"listen_addresses = ''"/g /var/lib/pgsql9/data/postgresql.conf
	sudo sed -i s/"local   all             all                                     ident"/"local   all             all                                     trust"/g /var/lib/pgsql9/data/pg_hba.conf
	sudo sed -i s/"32            ident"/"32            md5"/g /var/lib/pgsql9/data/pg_hba.conf

	cd /home
	#Iniciando servico do postgres
	sudo service postgresql start
	#Criando o usuario odoo no banco, alterando a senha do usuario do postgres, e criando uma role para o usuario do odoo com permisao de cricao de db
	sudo -u postgres createuser odoo
	sudo su - postgres -c "createuser -s odoo" 2> /dev/null || true
	sudo -u postgres -- psql -c "ALTER USER postgres WITH PASSWORD '123';"
	sudo -u postgres -- psql -c "DROP ROLE odoo;"
	sudo -u postgres -- psql -c "CREATE ROLE odoo LOGIN ENCRYPTED PASSWORD 'md5f7b7bca97b76afe46de6631ff9f7175c' NOSUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION"
fi