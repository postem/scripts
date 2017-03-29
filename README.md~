# SCRIPT
Este repositório possui uma coleção de scripts para a instalação do Odoo e suas dependências. Os comandos abaixos foram testados em ambientes Ubuntus, RedHat e CentOS.

Para fazer o download deste repositório poderá utilizar os seguintes comandos:
```sh
$ cd ~
$ git clone https://github.com/BradooTech/Scripts
$ cd Scripts
```
Após isso, você estará dentro da pasta principal do repositório.

### Instalação

A seguir um guia com todas as dependências necessarias para o funcionamento do Odoo.

**Importante notar que a instalação dos pacotes devem ser feitas em um ambiente "limpo", isto é, recomenda-se a instalação em um sistema novo para não ocorrer erros de incompatibilidade de pacotes quando o Odoo for executado.**


#### - Ubuntu

Em ambientes derivados de Debian (Ubuntu, Mint etc.) utilizamos o APT como gerenciador de pacotes, para isso podemos instalar os pacotes de duas formas.

A primeira consiste em abrir o arquivo dep_apt, dentro da pasta dependências/apt, copiar todo seu conteúdo e colar no terminal após o comando do APT:
```sh
$ sudo apt install python-libxml2 libxmlsec1-dev python-openssl ...
```
Ou podemos redirecionar este arquivo para o APT:
```sh
$ cat /dependencias/apt/dep_apt | xargs sudo apt install
```
**Vale salientar que voce deve estar dentro do diretório principal baixado deste repositório.**

#### - RedHat

O gerenciador de pacotes de distribuições RedHat e seus derivados é o YUM, sendo inteiramente diferente a disposição de instalação dos pacotes. Da mesma forma que o APT, podemos instalar esses dois pacotes de duas formas.
Antes, pórem, é necessário instalar outro pacote que possibilita a instalação dos pacotes necessários.
```sh
$ sudo yum install epel-release
```
Após feita sua instalação podemos instalar os pacotes de dependência do Odoo. Neste caso o arquivo será encontrado no diretório dependencias/yum.
```sh
$ sudo yum install pyOpenSSL python-cffi zlib-devel fontconfig ...
```
Ou podemos redirecionar este arquivo para o YUM:
```sh
$ cat /dependencias/apt/dep_apt | xargs sudo yum install
```
**Vale salientar que voce deve estar dentro do diretório principal baixado deste repositório.**

E por ultimo, devemos instalar um pacote com o seguinte comando:
```sh
$ sudo rpm -Uvh ftp://195.220.108.108/linux/centos/7.3.1611/os/x86_64/Packages/xmlsec1-1.2.20-5.el7.i686.rpm
```
## Bibiliotecas Python - PIP

O Odoo faz uso de bibliotecas python que não estão instaladas ainda para seu funcionamento. Para isso utilizaremos o utilitario pip para a instalação destas bibliotecas.
Antes, precisamos atualizar o pip:
```sh
$ sudo pip install --upgrade pip
$ sudo pip install --upgrade setuptools
```
### Ubuntu
As dependências de pip para o ubuntu se encontram no caminho dependecias/apt/dep_pip, levando em conta que você esteja na pasta raiz deste repositório.
```sh
$ sudo pip install Babel==1.3 Jinja2==2.7.3 Mako==1.0.1 MarkupSafe==0.23 ...
```
Ou
```sh
$ cat dependencias/apt/dep_pip | xargs sudo pip install 
```

### RedHat
As dependências de pip para o RedHat se encontram no caminho dependecias/yum/dep_pip, levando em conta que você esteja na pasta raiz deste repositório.
```sh
$ sudo pip install Babel==1.3 Jinja2==2.7.3 Mako==1.0.1 MarkupSafe==0.23 ...
```
Ou
```sh
$ cat dependencias/yum/dep_pip | xargs sudo pip install 
```
