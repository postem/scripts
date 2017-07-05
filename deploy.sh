#!/bin/bash

read -p "Digite o IP da maquina de possui o Odoo: " IP_ODOO
read -p "Digite o PATH onde se encontra a raiz do Odoo: " PATH_ODOO

ssh root@$IP_ODOO zip -r /root/odoo.zip $PATH_ODOO/* -x *.pack* *.idx*
scp root@$IP_ODOO:/root/odoo.zip .

alias odoo_camserv='/home/dev/odoo_camserv/odoo-server/odoo-bin --addons-path=/home/dev/odoo_camserv/enterprise/addons,/home/dev/odoo_camserv/odoo-server/addons,/home/dev/odoo_camserv/custom/odoo-brasil,/home/dev/odoo_camserv/custom/server-tools,/home/dev/odoo_camserv/custom/trustcode-addons,/home/dev/odoo_camserv/custom'