#!/bin/bash

read -p "Atuliazar o SO? [Sim | Não] " ATUALIZA_SO
read -p "Instalar dependencias APT? [Sim | Não] " DEP_APT
read -p "Instalar dependencias PIP? [Sim | Não] " DEP_PIP
read -p "Criar usuario Odoo? [Sim | Não] " CR_USER
read -p "Criar diretorio de log? [Sim | Não] " DIR_LOG
read -p "Criar diretorio de Custom Addons? [Sim | Não] " DIR_ADDONS
read -p "Criar arquivo de configuracoes? [Sim | Não] " CONF_FILE
read -p "Criar arquivo Init? [Sim | Não] " INIT_FILE
read -p "Mudar porta padrao do Odoo? [Sim | Não] " PORT_
read -p "Subir Odoo na inicializacao? [Sim | Não] " INI_ODOO
read -p "Deseja Instalar Wkhtmltopdf? [Sim | Não] " INSTALL_WKHTMLTOPDF
read -p "Deseja instalar odoo base? [Sim | Não] " ODOO_BASE
read -p "Deseja instalar odoo-brasil? [Sim | Não] " ODOO_BRASIL
read -p "Deseja instalar localizacao? [Sim | Não] " LOCALIZACAO
read -p "Deseja instalar enterprise?  [Sim | Não] " ENTERPRISE

OE_PORT="8069"
OE_SUPERADMIN="admin"
OE_USER="odoo"
OE_CONFIG="${OE_USER}-server"
read -p "Pasta de instalacao do Odoo" OE_HOME
read -p "Pasta de instalacao do Odoo 10" OE_HOME_EXT


#Parametros para o APT
sudo sh -c 'echo "Acquire::http::No-Cache true;" >> /etc/apt/apt.conf'
sudo sh -c 'echo "Acquire::http::Pipeline-Depth 0;" >> /etc/apt/apt.conf'


#Parametros WKHTMLTOPDF
WKHTMLTOX_X64=https://downloads.wkhtmltopdf.org/0.12/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
WKHTMLTOX_X32=https://downloads.wkhtmltopdf.org/0.12/0.12.4/wkhtmltox-0.12.4_linux-generic-i386.tar.xz

#--------------------------------------------------
# Update Server
#--------------------------------------------------
if [ $ATUALIZA_SO == 'Sim' ]; then
  clear
  echo -e "Atualizando o Server"
  sudo apt-get update
  clear
  sudo apt-get upgrade -y
else
  echo "Sistema nao atualizado"
fi

#--------------------------------------------------
# Install Dependencies
#--------------------------------------------------
if [ $DEP_APT == 'Sim' ]; then
  clear
  echo -e "Instalando pacotes utilitarios"
  cat requeridos.apt | xargs sudo apt-get install -y
else
  echo "Pacotes recomendados nao foram instalados"
fi

if [ $DEP_PIP == 'Sim' ]; then
  clear
  echo -e "Instalando dependencias pip"
  sudo -H pip install --upgrade pip
  sudo -H pip install --upgrade setuptools
  cat requeridos.pip | xargs sudo -H pip install
else
  echo "Pacotes pip recomendados nao foram instalados"
fi

#--------------------------------------------------
# Install Wkhtmltopdf if needed
#--------------------------------------------------
clear
if [ $INSTALL_WKHTMLTOPDF == "Sim" ]; then
  echo -e " Instalando o Wkhtmltopdf "
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
if [ $CR_USER == "Sim" ]; then
  clear
  echo -e " Criacao de usuario Odoo "
  sudo adduser --system --quiet --shell=/bin/bash --home=$OE_HOME --gecos 'ODOO' --group $OE_USER
  #The user should also be added to the sudo'ers group.
  sudo adduser $OE_USER sudo
else
  echo "Usuario Odoo nao criado"
fi

# --------------------------------------------------
# Criando diretorio para arquivos de log
# --------------------------------------------------
if [ $DIR_LOG == "Sim" ]; then
  clear
  echo -e " Criando diretorio para arquivos de log "
  sudo mkdir /var/log/$OE_USER
  sudo chown $OE_USER:$OE_USER /var/log/$OE_USER
fi

#--------------------------------------------------
# Install ODOO
#--------------------------------------------------

clear
if [ $ODOO_BASE= "Sim" ]; then
  echo -e " Instalando Odoo-Server "
  sudo git clone -b 10.0 --single-branch https://github.com/BradooTech/odoo $OE_HOME_EXT/
else
  echo "Odoo Base nao foi instalado por escolhado do usuario"
fi

clear
if [ $ODOO_BRASIL = "Sim" ]; then
	echo -e " Instalando Odoo-Brasil "
	sudo git clone https://www.github.com/bradootech/odoo-brasil $OE_HOME/odoo-brasil
else
  echo "Odoo-Brasil nao foi instalado por escolhado do usuario"
fi

clear
if [ $LOCALIZACAO = "Sim" ]; then
	echo -e " Instalando Localizacao TrustCode "
	sudo git clone https://github.com/Trust-Code/trustcode-addons $OE_HOME/trust-addons
else
  echo "Localizacao nao foi instalado por escolhado do usuario"
fi

clear
if [ $ENTERPRISE = "Sim" ]; then
	echo -e " Instalando Enterprise "
	sudo git clone https://github.com/BradooDev/Enterprise $OE_HOME/enterprise
else
  echo "Enterprise nao foi instalado por escolhado do usuario"
fi


if [ $DIR_ADDONS = "Sim" ]; then
  clear
  echo -e " Criando um diretorio para Custom Addons "
  sudo su $OE_USER -c "mkdir $OE_HOME/custom"
  sudo su $OE_USER -c "mkdir $OE_HOME/custom"
else
  echo "Pasta addons nao selecionada"
fi

clear
echo -e " Configurando permissoes na pasta home "
sudo chown -R $OE_USER:$OE_USER $OE_HOME/*

if [ $CONF_FILE = "Sim" ]; then
  clear
  echo -e " Create server config file "
  sudo cp $OE_HOME_EXT/debian/odoo.conf /etc/${OE_CONFIG}.conf
  sudo chown $OE_USER:$OE_USER /etc/${OE_CONFIG}.conf
  sudo chmod 640 /etc/${OE_CONFIG}.conf
  echo -e " Alterando arquivo de configuracoes "
sudo sed -i s/"db_user = .*"/"db_user = $OE_USER"/g /etc/${OE_CONFIG}.conf
sudo sed -i s/"; admin_passwd.*"/"admin_passwd = $OE_SUPERADMIN"/g /etc/${OE_CONFIG}.conf
sudo su root -c "echo 'logfile = /var/log/$OE_USER/$OE_CONFIG$1.log' >> /etc/${OE_CONFIG}.conf"
sudo su root -c "echo 'addons_path=$OE_HOME_EXT/addons,$OE_HOME/custom/,$OE_HOME/odoo-brasil,$OE_HOME/trust-addons,$OE_HOME/enterprise' >> /etc/${OE_CONFIG}.conf"
else
  echo "Configuracao do Odoo Conf nao selecionada"
fi
clear

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

if [ $INIT_FILE = "Sim" ]; then
  clear
  echo -e "* Security Init File"
  sudo mv /home/dev/$OE_CONFIG /etc/init.d/$OE_CONFIG
  sudo chmod 755 /etc/init.d/$OE_CONFIG
  sudo chown root: /etc/init.d/$OE_CONFIG
else
  echo "Init file nao selecionado"
fi

if [ $PORT_ = "Sim" ]; then
  clear
  echo -e "* Change default xmlrpc port"
  sudo su root -c "echo 'xmlrpc_port = $OE_PORT' >> /etc/${OE_CONFIG}.conf"
else
  echo "Opcao de configuracao de porta nao selecioanda"
fi

if [ $INI_ODOO = "Sim" ]; then
  echo -e "* Start ODOO on Startup"
  sudo update-rc.d $OE_CONFIG defaults
else
  echo "Nao iniciar odoo na inicializacao"
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