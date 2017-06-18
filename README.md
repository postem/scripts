# Scripts de Instalação
Este repositório possui uma coleção de scripts para a instalação do Odoo e suas dependências. Os comandos abaixos foram testados em ambientes Ubuntu, RedHat 7 e Linux Amazon.

## Instalação

A seguir um guia com todas as dependências necessarias para o funcionamento do Odoo.

**Importante notar que a instalação dos pacotes devem ser feitas em um ambiente "limpo", isto é, recomenda-se a instalação em um sistema novo para não ocorrer erros de incompatibilidade de pacotes quando o Odoo for executado.**

### - Ubuntu

Em ambientes derivados de Debian (Ubuntu, Mint etc.) utilizamos o APT como gerenciador de pacotes. A execução do Script de Instalação é facil sendo somente necessária instalar o pacote do git anteriormente:

```sh
$ sudo apt update
$ sudo apt full-upgrade -y
$ sudo apt install git
```
E posteriormente clonar o repositório e executar o script de instalação:
```sh
$ git clone https://github.com/BradooTech/scripts
$ cd scripts
$ sudo ./apt_install.sh
```
Após isso é só esperar terminar a instalação e logar com usuario Odoo e executar o 'odoo-bin'

### - RedHat 7

No ambiente de RedHat utilizamos o YUM como gerenciador de pacotes. A execução do Script de Instalação é facil sendo somente necessária instalar o pacote do git anteriormente:

```sh
$ sudo yum update -y
$ sudo yum install git
```
E posteriormente clonar o repositório e executar o script de instalação:
```sh
$ git clone https://github.com/BradooTech/scripts
$ cd scripts
$ sudo ./redhat_install.sh
```
Após isso é só esperar terminar a instalação e logar com usuario Odoo e executar o 'odoo-bin'

### - Amazon Linux

No ambiente de Linux da Amazon utilizamos o YUM como gerenciador de pacotes. A execução do Script de Instalação é facil sendo somente necessária instalar o pacote do git anteriormente:

```sh
$ sudo yum update -y
$ sudo yum install git
```
E posteriormente clonar o repositório e executar o script de instalação:
```sh
$ git clone https://github.com/BradooTech/scripts
$ cd scripts
$ sudo ./redhat_install.sh
```
Após isso é só esperar terminar a instalação e logar com usuario Odoo e executar o 'odoo-bin'