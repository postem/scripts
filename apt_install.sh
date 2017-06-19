#!/bin/bash

read -p "Deseja Instalar Wkhtmltopdf? [Sim | Não] " INSTALL_WKHTMLTOPDF
read -p "Deseja instalar odoo-brasil? [Sim | Não] " ODOO_BRASIL
read -p "Deseja instalar localizacao? [Sim | Não] " LOCALIZACAO
read -p "Deseja instalar enterprise?  [Sim | Não] " ENTERPRISE
read -p "Escolha o ambiente que será instalado: [dev | prod] " AMBIENTE
OE_PORT="8069"
OE_SUPERADMIN="admin"
OE_USER="odoo"
OE_CONFIG="${OE_USER}-server"

if [ $AMBIENTE == 'dev' ]; then
	OE_HOME="/home/dev/$OE_USER"
elif [ $AMBIENTE == 'prod' ]; then
	OE_HOME="/$OE_USER"
fi

if [ $AMBIENTE == 'dev' ]; then
	OE_HOME_EXT="/home/dev/odoo/${OE_USER}-server"
elif [ $AMBIENTE == 'prod' ]; then
	OE_HOME_EXT="/$OE_USER/${OE_USER}-server"
fi

#Parametros para o APT
sudo sh -c 'echo "Acquire::http::No-Cache true;" >> /etc/apt/apt.conf'
sudo sh -c 'echo "Acquire::http::Pipeline-Depth 0;" >> /etc/apt/apt.conf'


#Parametros WKHTMLTOPDF
WKHTMLTOX_X64=https://downloads.wkhtmltopdf.org/0.12/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
WKHTMLTOX_X32=https://downloads.wkhtmltopdf.org/0.12/0.12.4/wkhtmltox-0.12.4_linux-generic-i386.tar.xz

#--------------------------------------------------
# Update Server
#--------------------------------------------------
clear
echo -e "\e[31;43m***** Atualizando o Server *****\e[0m"
sudo apt-get update
clear
sudo apt-get upgrade -y


#--------------------------------------------------
# Install Dependencies
#--------------------------------------------------
clear
echo -e "\e[31;43m***** Instalando pacotes utilitarios *****\e[0m"
cat dependencias/apt/invivdual/utilitarios | xargs sudo apt-get install -y

clear
echo -e "\e[31;43m***** Instalando pacotes Python *****\e[0m"
cat dependencias/apt/invivdual/pkg_python | xargs sudo apt-get install -y

clear
echo -e "\e[31;43m***** Instalando outros pacotes necessarios *****\e[0m"
cat dependencias/apt/invivdual/outros_pkg | xargs sudo apt-get install -y

clear
echo -e "\e[31;43m***** Instalando dependencias pip *****\e[0m"
sudo -H pip install --upgrade pip
sudo -H pip install --upgrade setuptools
cat dependencias/apt/dep_pip | xargs sudo -H pip install

#--------------------------------------------------
# Install PostgreSQL Server
#--------------------------------------------------
clear
echo -e "\e[31;43m***** Instalacao PostgreSQL *****\e[0m"
sudo apt-get install postgresql -y

if [ $AMBIENTE == 'dev' ]; then
	clear
	echo -e "\e[31;43m***** Instalacao PGAdminn3 *****\e[0m"
	sudo apt install pgadmin3 -y
fi

clear
echo -e "\e[31;43m***** Criacao de usuario Odoo no PostgreSQL *****\e[0m"
sudo su - postgres -c "createuser -s $OE_USER" 2> /dev/null || true
sudo -u postgres -- psql -c "ALTER USER postgres WITH PASSWORD '123';"
sudo -u postgres -- psql -c "DROP ROLE odoo;"
sudo -u postgres -- psql -c "CREATE ROLE odoo LOGIN ENCRYPTED PASSWORD 'md5f7b7bca97b76afe46de6631ff9f7175c' NOSUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION"
echo -e "\e[31;43m***** Usuario odoo criado. Senha = '123'\n Usuário postgres agora tem a senha= '123' *****\e[0m"

#--------------------------------------------------
# Install Wkhtmltopdf if needed
#--------------------------------------------------
clear
if [ $INSTALL_WKHTMLTOPDF == "Sim" ]; then
  echo -e "\e[31;43m***** Instalando o Wkhtmltopdf *****\e[0m"
    #pick up correct one from x64 & x32 versions:
  if [[ "`getconf LONG_BIT`" == "64" ]];then
      _url=$WKHTMLTOX_X64
  else
      _url=$WKHTMLTOX_X32
  fi
  sudo wget $_url
  tar -xvf wkhtmltox*.tar.xz
  cd wkhtmltox/bin
  sudo cp wkhtmltopdf /usr/local/bin/wkhtmltopdf
  sudo cp wkhtmltoimage /usr/local/bin/wkhtmltoimage
  sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin
  sudo ln -s /usr/local/bin/wkhtmltoimage /usr/bin
  sudo chmod ugo+x /usr/bin/wkhtmltopdf
  sudo chmod ugo+x /usr/bin/wkhtmltoimage
else
  echo "Wkhtmltopdf nao foi instalado por escolhado do usuario"
fi

#--------------------------------------------------
# Criando usuario odoo no SO
#--------------------------------------------------
clear
echo -e "\e[31;43m***** Criacao de usuario Odoo *****\e[0m"
sudo adduser --system --quiet --shell=/bin/bash --home=$OE_HOME --gecos 'ODOO' --group $OE_USER
#The user should also be added to the sudo'ers group.
sudo adduser $OE_USER sudo

# --------------------------------------------------
# Criando diretorio para arquivos de log
# --------------------------------------------------
clear
echo -e "\e[31;43m***** Criando diretorio para arquivos de log *****\e[0m"
sudo mkdir /var/log/$OE_USER
sudo chown $OE_USER:$OE_USER /var/log/$OE_USER

#--------------------------------------------------
# Install ODOO
#--------------------------------------------------

clear

echo -e "\e[31;43m***** Instalando Odoo-Server *****\e[0m"
sudo git clone -b 10.0 --single-branch --depth 1 https://github.com/BradooTech/odoo $OE_HOME_EXT/

clear
if [ $ODOO_BRASIL = "Sim" ]; then
	echo -e "\e[31;43m***** Instalando Odoo-Brasil *****\e[0m"
		sudo git clone https://www.github.com/bradootech/odoo-brasil $OE_HOME/odoo-brasil
else
  echo "Odoo-Brasil nao foi instalado por escolhado do usuario"
fi

clear
if [ $LOCALIZACAO = "Sim" ]; then
	echo -e "\e[31;43m***** Instalando Localizacao TrustCode *****\e[0m"
		sudo git clone https://github.com/Trust-Code/trustcode-addons $OE_HOME/trust-addons
else
  echo "Localizacao nao foi instalado por escolhado do usuario"
fi

clear
if [ $ENTERPRISE = "Sim" ]; then
	echo -e "\e[31;43m***** Instalando Enterprise *****\e[0m"
		sudo git clone https://github.com/BradooDev/Enterprise $OE_HOME/enterprise
else
  echo "Enterprise nao foi instalado por escolhado do usuario"
fi

clear
echo -e "\e[31;43m***** Criando um diretorio para Custom Addons *****\e[0m"
sudo su $OE_USER -c "mkdir $OE_HOME/custom"
sudo su $OE_USER -c "mkdir $OE_HOME/custom/addons"

clear
echo -e "\e[31;43m***** Configurando permissoes na pasta home *****\e[0m"
sudo chown -R $OE_USER:$OE_USER $OE_HOME/*

clear
echo -e "\e[31;43m***** Create server config file *****\e[0m"
sudo cp $OE_HOME_EXT/debian/odoo.conf /etc/${OE_CONFIG}.conf
sudo chown $OE_USER:$OE_USER /etc/${OE_CONFIG}.conf
sudo chmod 640 /etc/${OE_CONFIG}.conf

clear
echo -e "\e[31;43m***** Alterando arquivo de configuracoes *****\e[0m"
sudo sed -i s/"db_user = .*"/"db_user = $OE_USER"/g /etc/${OE_CONFIG}.conf
sudo sed -i s/"; admin_passwd.*"/"admin_passwd = $OE_SUPERADMIN"/g /etc/${OE_CONFIG}.conf
sudo su root -c "echo 'logfile = /var/log/$OE_USER/$OE_CONFIG$1.log' >> /etc/${OE_CONFIG}.conf"
sudo su root -c "echo 'addons_path=$OE_HOME_EXT/addons,$OE_HOME/custom/addons,$OE_HOME/odoo-brasil,$OE_HOME/trust-addons,$OE_HOME/enterprise' >> /etc/${OE_CONFIG}.conf"

#--------------------------------------------------
# Adding ODOO as a deamon (initscript)
#--------------------------------------------------

clear
echo -e "* Create init file"
cat <<EOF > /home/dev/$OE_CONFIG
#!/bin/sh
### BEGIN INIT INFO
# Provides: $OE_CONFIG
# Required-Start: \$remote_fs \$syslog
# Required-Stop: \$remote_fs \$syslog
# Should-Start: \$network
# Should-Stop: \$network
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Enterprise Business Applications
# Description: ODOO Business Applications
### END INIT INFO
PATH=/bin:/sbin:/usr/bin
DAEMON=$OE_HOME_EXT/odoo-bin
NAME=$OE_CONFIG
DESC=$OE_CONFIG
# Specify the user name (Default: odoo).
USER=$OE_USER
# Specify an alternate config file (Default: /etc/openerp-server.conf).
CONFIGFILE="/etc/${OE_CONFIG}.conf"
# pidfile
PIDFILE=/var/run/\${NAME}.pid
# Additional options that are passed to the Daemon.
DAEMON_OPTS="-c \$CONFIGFILE"
[ -x \$DAEMON ] || exit 0
[ -f \$CONFIGFILE ] || exit 0
checkpid() {
[ -f \$PIDFILE ] || return 1
pid=\`cat \$PIDFILE\`
[ -d /proc/\$pid ] && return 0
return 1
}
case "\${1}" in
start)
echo -n "Starting \${DESC}: "
start-stop-daemon --start --quiet --pidfile \$PIDFILE \
--chuid \$USER --background --make-pidfile \
--exec \$DAEMON -- \$DAEMON_OPTS
echo "\${NAME}."
;;
stop)
echo -n "Stopping \${DESC}: "
start-stop-daemon --stop --quiet --pidfile \$PIDFILE \
--oknodo
echo "\${NAME}."
;;
restart|force-reload)
echo -n "Restarting \${DESC}: "
start-stop-daemon --stop --quiet --pidfile \$PIDFILE \
--oknodo
start-stop-daemon --start --quiet --pidfile \$PIDFILE \
--chuid \$USER --background --make-pidfile \
--exec \$DAEMON -- \$DAEMON_OPTS
echo "\${NAME}."
;;
*)
N=/etc/init.d/\$NAME
echo "Usage: \$NAME {start|stop|restart|force-reload}" >&2
exit 1
;;
esac
exit 0
EOF

clear
echo -e "* Security Init File"
sudo mv /home/dev/$OE_CONFIG /etc/init.d/$OE_CONFIG
sudo chmod 755 /etc/init.d/$OE_CONFIG
sudo chown root: /etc/init.d/$OE_CONFIG

clear
echo -e "* Change default xmlrpc port"
sudo su root -c "echo 'xmlrpc_port = $OE_PORT' >> /etc/${OE_CONFIG}.conf"

clear
if [ $AMBIENTE == 'prod' ]; then
	echo -e "* Start ODOO on Startup"
	sudo update-rc.d $OE_CONFIG defaults
fi

clear
echo -e "* Starting Odoo Service"
sudo su root -c "/etc/init.d/$OE_CONFIG start"
echo "-----------------------------------------------------------"
echo "Done! The Odoo server is up and running. Specifications:"
echo "Port: $OE_PORT"
echo "User service: $OE_USER"
echo "User PostgreSQL: $OE_USER"
echo "Code location: $OE_USER"
echo "Addons folder: $OE_USER/$OE_CONFIG/addons/"
echo "Start Odoo service: sudo service $OE_CONFIG start"
echo "Stop Odoo service: sudo service $OE_CONFIG stop"
echo "Restart Odoo service: sudo service $OE_CONFIG restart"
echo "-----------------------------------------------------------"
