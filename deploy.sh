#!/bin/bash

read -p "Digite o IP da maquina de possui o Odoo: " IP_ODOO
read -p "Digite o PATH onde se encontra a raiz do Odoo: " PATH_ODOO

ssh root@$IP_ODOO tar cvzf /root/odoo.tar.gz $PATH_ODOO --exclude-vcs
scp root@$IP_ODOO:/root/odoo.tar.gz .

# Descompactar arquivo tar -xvzf odoo.tar.gz
