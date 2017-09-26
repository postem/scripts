#!/bin/bash
ODOO_HOME=$(dirname $(dirname $(find / -name "odoo-bin" 2>/dev/null)))
echo $ODOO_HOME
mkdir -p $ODOO_HOME/custom/localizacao
git clone https://github.com/bradootech/trustcode-addons $ODOO_HOME/localizacao/trustcode-addons
git clone https://github.com/BradooTech/odoo-brasil $ODOO_HOME/localizacao/odoo-brasil
sudo chown -R odoo:odoo /odoo/custom/localizacao
