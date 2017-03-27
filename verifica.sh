#!/bin/bash
. /lib/lsb/init-functions

lista_apt=(dependencias/utilitarios dependencias/outros_pkg dependencias/pkg_python dependencias/dep_loc 
	dependencias/dep_wkhtopdf dependencias/lib_python)
lista_pip=(dependencias/dep_pip )
apt=$(dpkg --get-selections)
pip=$(pip freeze)
user=$(cut -d: -f1 /etc/passwd)
echo $(date)  > requirements.log

echo "
----------------------------- Conf SO ----------------------------
$(lsb_release -a)
" >> requirements.log

echo "
---------------------------- Conf Rede ---------------------------
$(ip addr show)
" >> requirements.log

echo "
--------------------------- Dependecias APT ----------------------
" >> requirements.log
for file in ${lista_apt[@]}
do
echo -e "<------------- $file ------------->" >> requirements.log
	for linha in $(cat $file);
	do
		if [[ $(echo "$apt" | grep $linha) ]]; then
			printf "%-50s %s\n" $linha "[  INSTALADO  ]" >> requirements.log
			echo "$linha;Instalado" >> requirements.csv
		else
			printf "%-50s %s\n" $linha "[NÃO INSTALADO]" >> requirements.log
			echo "$linha;Não Instalado" >> requirements.csv
			echo "$linha" >> requeridos.apt
		fi
	done
echo >> requirements.log
done

echo "
--------------------------- Dependecias PIP ----------------------
" >> requirements.log
for file in ${lista_pip[@]}
do
echo -e "<------------- $file ------------->" >> requirements.log
	for linha in $(cat $file);
	do
		if [[ $(echo "$pip" | grep $linha) ]]; then
			printf "%-50s %s\n" $linha "[  INSTALADO  ]" >> requirements.log
			echo "$linha;Instalado" >> requirements.csv
		else
			printf "%-50s %s\n" $linha "[NÃO INSTALADO]" >> requirements.log
			echo "$linha;Não Instalado" >> requirements.csv
			echo "$linha" >> requeridos.pip
		fi
	done
echo >> requirements.log
done

echo "
----------------------------- Usuario ----------------------------
" >> requirements.log
if [ -d /var/log/odoo ]; then
	echo '> Diretorio de log odoo existente' >> requirements.log
else
	echo '> Diretorio de log odoo nao ecnontrado' >> requirements.log
fi

if [[ $(echo "$user" | grep odoo) ]]; then
	echo '> Usuario odoo ecnontrado' >> requirements.log
else
	echo '> Usuario odoo nao ecnontrado' >> requirements.log
fi

if [ -d /odoo ]; then
	echo '> Diretorio do Odoo ecnontrado na raiz' >> requirements.log
elif [ -d /home/odoo/odoo ]; then
	echo '> Diretorio do Odoo ecnontrado na pasta home do usuario odoo' >> requirements.log
else
	echo '> Diretorio do Odoo desconhecido' >> requirements.log
fi

echo "
----------------------------- Servico ----------------------------
" >> requirements.log
if [ -a /etc/init.d/odoo* ]; then
	echo '> Servico Odoo ecnontrado' >> requirements.log
else
	echo '> Servico Odoo nao encontrado' >> requirements.log
fi

if [ -a /etc/odoo*.conf ]; then
	echo '> Arquivo de configuracao Odoo padrao encontrado' >> requirements.log
else
	echo '> Arquivo de configuracao Odoo padrao nao encontrado' >> requirements.log
fi

echo "
---------------------------- Hardware ----------------------------

$(uname -a)

---------------------------- CPU
$(sudo lscpu)

---------------------------- Disco
$(sudo df -h)

---------------------------- Memoria
$(free -m)
" >> requirements.log


echo "$(sudo lshw)" > harware.log