#!/bin/bash
clear
Menu(){
clear
   echo "------------------------------------------"
   echo "    LinuxAdmin  - Zabbix 3.4        "
   echo "------------------------------------------"
   echo
   echo "[ 1 ] Instalar Zabbix"
   echo "[ 2 ] Zabbix Proxy"
   echo "[ 3 ] Zabbix Agent"
   echo "[ 4 ] Desinstalar"
   echo "[ 5 ] Grafana"
   echo "[ 6 ] Sair"
   echo
   echo -n "Qual a opcao desejada ? "
   read opcao
   case $opcao in
      1) InstalarZabbix;;
      2) ZabbixProxy;;
      3) ZabbixAgent;;
      4) Desinstalar;;
      5) InstalarGrafana;;
      6) exit ;;
      *) "Opcao desconhecida." ; echo ; Principal ;;
   esac
}
Desinstalar(){

sudo dpkg -P zabbix
echo "desinstaldo o Zabbix"
}

Backup() {
echo "Especifique o local a ser backupeado"
read local
 
 
echo "+++++++++++++++++++++++++++++++++++++++"
echo
 
echo "Especifique nome do backup =)"
read nome
 
echo
 
echo
echo "+++++++++++++++++++++++++++++++++++++++"
 
echo "Especifique o destino do backup =)"
read destino
 
sudo tar cvf $destino/$nome.tar $local
cd $destino
ls $nome
Menu
}

Principal(){

sleep 2
clear
Menu

}

ZabbixProxy() {
echo "Instalando o Zabbix Proxy"
sleep 1
cd /tmp

# Creating system user
groupadd zabbix
useradd -g zabbix -s /bin/false zabbix

wget http://repo.zabbix.com/zabbix/3.4/debian/pool/main/z/zabbix-release/zabbix-release_3.4-1%2Bstretch_all.deb
dpkg -i zabbix-release_3.4-1%2Bstretch_all.deb

#apt-get update
echo "deb http://security.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list
echo "deb-src http://security.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list
echo "deb http://ftp.de.debian.org/debian stretch main" >> /etc/apt/sources.list
echo "deb http://httpredir.debian.org/debian/ stretch main contrib non-free" >> /etc/apt/sources.list

apt-get update
apt-get upgrade -y
clear

apt-get install zabbix-proxy-sqlite3 zabbix-agent
mkdir /var/lib/zabbix
chown zabbix. –R /var/lib/zabbix

# Habilitando execução de comandos via Zabbix
	sed -i 's/# EnableRemoteCommands=0*/EnableRemoteCommands=1/' /etc/zabbix/zabbix_agentd.conf
	sed -i 's/# ProxyOfflineBuffer=1*/ProxyOfflineBuffer=24/' /etc/zabbix/zabbix_agentd.conf
	sed -i 's/# DataSenderFrequency=1*/DataSenderFrequency=1/' /etc/zabbix/zabbix_agentd.conf
	sed -i 's/# DBName=Zabbix Server*/DBName=\/var\/lib\/sqlite3\/zabbix.db/' /etc/zabbix/zabbix_agentd.conf
	
	sed -i 's/# FpingLocation=\/usr\/sbin\/fping/FpingLocation=\/usr\/bin\/fping/' /etc/zabbix/zabbix_proxy.conf

	
	
#populando sqlite3
sqlite3 /var/lib/sqlite3/zabbix.db < schema.sql

# service zabbix-proxy start
# service zabbix-agent start
# --------------------------------------
#***********Transformar no SED Config Proxy**********
# ProxyMode=0
# Server=<IP_ZABBIX_SERVER>
# Hostname=<NOME_PROXY_QUE_SERA_CADASTRADO_NO_ZABBIX_SERVER>
# DBName=/var/lib/zabbix/zabbix.db
# DBUser=zabbix
# ConfigFrequency=120 (apenas a primeira vez. Depois que se comunicar, pode
# Deixar o valor padrão)
# DataSenderFrequency=10 (para proxy enviar os dados)
# ProxyOfflineBuffer=24

#**********config Agent******************************
# • zabbix_agentd.conf
# Server=<IP_ZABBIX_PROXY>
# Hostname=<NOME_HOST_QUE_SERA_CADASTRADO_NO_ZABBIX_SERVER>

#Iniciando Zabbix Proxy e Zabbix Agent
/etc/init.d/zabbix-proxy restart
/etc/init.d/zabbix-agent restart

#Inicializando junto com o sistema operacional
systemctl enable zabbix-proxy
systemctl enable zabbix-agent


sleep 2
Menu
}

ZabbixAgent(){

#outro teste não homologado
echo "Instlando o Agent Zabbix"
#Instalando o Zabbix Proxy x Zabbix Agent:
# apt install zabbix-proxy-mysql zabbix-agent
# apt-get install zabbix-agent
# service zabbix-agent start
#systemctl start zabbix-proxy
#systemctl start zabbix-agent
# apt-get update
#   apt-get -y install zabbix-agent sysv-rc-conf
#   sysv-rc-conf zabbix-agent on
#   sed -i 's/Server=127.0.0.1/Server=52.90.49.206/' /etc/zabbix/zabbix_agentd.conf
#   sed -i 's/ServerActive=127.0.0.1/ServerActive=52.90.49.206/' /etc/zabbix/zabbix_agentd.conf
#   HOSTNAME=`hostname` && sed -i "s/Hostname=Zabbix\ server/Hostname=$HOSTNAME/" /etc/zabbix/zabbix_agentd.conf
#   service zabbix-agent restart
#---------------------------------------------------------------------------------------------------

sleep 2
Menu
}

InstalarZabbix() {

apt update && apt upgrade
cd /tmp
wget http://repo.zabbix.com/zabbix/3.4/debian/pool/main/z/zabbix-release/zabbix-release_3.4-1+stretch_all.deb
dpkg -i zabbix-release_3.4-1+stretch_all.deb
apt update -y
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-agent

#Vamos criar uma base de dados chamada zabbix e um usuário também chamado de zabbix no MariaDB.

# Criando a base de dados zabbix
echo "digete a senha do banco"
read  DBsenha
                echo "Creating zabbix database..."
                mysql -u root -p -e "create database zabbix character set utf8 collate utf8_bin";
                sleep 1
                echo "Creating zabbix user at MariaDB SGBD..."
                mysql -u root -p -e "create user 'zabbix'@'localhost' identified by '$DBsenha'";
                sleep 1
                echo "Making zabbix user the owner to zabbix database..."
                mysql -u root -p -e "grant all privileges on zabbix.* to 'zabbix'@'localhost' with grant option";

echo  "banco criado verifique /etc/zabbix"
sed -i 's/# DBPassword=/DBPassword='$DBsenha'/' /etc/zabbix/zabbix_server.conf

#mysql -uroot $(if test $rootPWD_SQL ; then -p$rootPWD_SQL; fi) zabbix < zcat /usr/share/zabbix-proxy-mysql/schema.sql.gz


#mariadb
#create database zabbix character set utf8 collate utf8_bin;
#grant all privileges on zabbix.* to zabbix@localhost identified by 'SENHA-USUARIO-ZABBIX';
#quit;

zcat /usr/share/doc/zabbix-server-mysql/create.sql.gz | mysql -uzabbix -p zabbix

#Agora vamos editar o arquivo zabbix_server.conf para informar os dados para conexão com o MySQL.

# vim /etc/zabbix/zabbix_server.conf
#...
#DBHost=localhost
#...
#DBName=zabbix
#...
#DBUser=zabbix
#...
#DBPassword=SENHA-USUARIO-ZABBIX
#...
#mudando o timezone

sed -i 's/# php_value date.timezone Europe\/Riga/php_value date.timezone America\/Sao_Paulo/' /etc/apache2/conf-enabled/zabbix.conf

sed -i 's/# php_value date.timezone Europe\/Riga/php_value date.timezone America\/Sao_Paulo/' /etc/zabbix/apache.conf

apt install php7.0-bcmath php7.0-mbstring php-sabre-xml -y

/etc/init.d/apache2 restart

#iniciando o Zabbix Server e o Agente.

systemctl enable zabbix-server
systemctl enable zabbix-agent
/etc/init.d/zabbix-server restart
/etc/init.d/zabbix-agent restart

clear
echo "Instalação Zabbix Concluida!.."
sleep 4

Menu

}


Downloads() {

cd /tmp/
wget  wget http://repo.zabbix.com/zabbix/3.4/debian/pool/main/z/zabbix-release/zabbix-release_3.4-1+stretch_all.deb
dpkg -i zabbix-release_3.4-1+stretch_all.deb

ls
echo "Download Realizado com Sucesso!"
sleep 3

Menu
}

InstalarProxys() {

# Creating system user
# 	groupadd zabbix
# 	useradd -g zabbix -s /bin/false zabbix
#Adionando User Zabbix
adduser zabbix --shell /bin/false

#Criando pasta install zabbix
mkdir /opt/zabbix && cd /opt/zabbix

#instalando pacotes necessarios
apt-get -y install build-essential snmp vim libssh2-1-dev libssh2-1 libopenipmi-dev libsnmp-dev wget libcurl4-gnutls-dev fping curl libcurl3-gnutls libcurl3-gnutls-dev libiksemel-dev libiksemel-utils libiksemel3 sudo sqlite3 libsqlite3-dev

# apt-get -y install sudo git vim snmp snmpd python-pip libxml2 libxml2-dev curl fping libcurl3 libevent-dev libpcre3-dev libcurl3-gnutls libcurl3-gnutls-dev libcurl4-gnutls-dev build-essential libssh2-1-dev libssh2-1 libiksemel-dev libiksemel-utils libiksemel3 fping libopenipmi-dev snmp snmp-mibs-downloader libsnmp-dev libmariadbd18 libmariadbd-dev snmpd ttf-dejavu-core libltdl7 libodbc1 libgnutls28-dev libldap2-dev openjdk-8-jdk unixodbc-dev mariadb-server pip install zabbix-api

#baixando o zabbix
wget http://repo.zabbix.com/zabbix/3.2/debian/pool/main/z/zabbix/zabbix_3.2.3.orig.tar.gz

#descompactando arquivos
tar -xzvf zabbix_3.2.3.orig.tar.gz

#mudando a permissao de execução
chmod -R +x zabbix-3.2.3

#entrando no diretorio sqlite3
cd zabbix-3.2.3/database/sqlite3/ && mkdir /var/lib/sqlite3/

#populando sqlite3
sqlite3 /var/lib/sqlite3/zabbix.db < schema.sql

#alterando usuario e grupo do diretorio
chown -R zabbix:zabbix /var/lib/sqlite3/

cd ../../

#Compilando o Zabbix Proxy
./configure --enable-proxy --enable-agent --with-sqlite3 --with-net-snmp --with-libcurl=/usr/bin/curlconfig --with-ssh2 --with-openipmi

#Instalando o Zabbix Proxy
make install


#Copiando o arquivo de inicialização do agente
cp misc/init.d/debian/zabbix-agent /etc/init.d/

#Dando permissão para os arquivos de inicialização do Zabbix
chmod +x /etc/init.d/zabbix-*


#Iniciando Zabbix Proxy e Zabbix Agent
/etc/init.d/zabbix-proxy start
/etc/init.d/zabbix-agent start

#Inicializando junto com o sistema operacional
systemctl enable zabbix-proxy
systemctl enable zabbix-agent
}

InstalarGrafana() {

cd /tmp/

#Fazendo o download do Grafana
#wget https://grafanarel.s3.amazonaws.com/builds/grafana_4.1.1-1484211277_amd64.deb

#Instalando dependências
#apt-get install -y adduser libfontconfig

#Instalando o pacote
#dpkg -i grafana_4.1.1-1484211277_amd64.deb

#Configurando a inicialização com o sistema operacional
#update-rc.d -f grafana-server defaults

#Iniciando o Grafana
#service grafana-server start

#Listando os plugins disponíveis para serem instalados
#grafana-cli plugins list-remote

#Instalando o plugin
#grafana-cli plugins install alexanderzobnin-zabbix-app

#Reiniciando o Grafana
#/etc/init.d/grafana-server restart

#Atualizado
wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_5.1.3_amd64.deb
apt-get install -y adduser libfontconfig apt-transport-https
dpkg -i grafana_5.1.3_amd64.deb

echo "deb https://packagecloud.io/grafana/stable/debian/ stretch main" >> /etc/apt/sources.list
echo "deb https://packagecloud.io/grafana/testing/debian/ stretch main" >> /etc/apt/sources.list

curl https://packagecloud.io/gpg.key | apt-key add -

apt-get update
apt-get install -y grafana

#Listando os plugins disponíveis para serem instalados
grafana-cli plugins list-remote

#Iniciando o Grafana
service grafana-server start

#Instalando o plugin zabbix
grafana-cli plugins install alexanderzobnin-zabbix-app

#Configurando a inicialização com o sistema operacional
update-rc.d grafana-server defaults
 
systemctl enable grafana-server.service

#Reiniciando o Grafana
/etc/init.d/grafana-server restart

}

Menu
