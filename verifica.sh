#!/bin/bash
. /lib/lsb/init-functions

lista_apt=(dependencias/utilitarios dependencias/outros_pkg dependencias/pkg_python dependencias/dep_loc 
	dependencias/dep_wkhtopdf dependencias/lib_python)
lista_pip=(dependencias/dep_pip )
apt=$(dpkg --get-selections)
pip=$(pip freeze)
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