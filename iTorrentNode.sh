#!/bin/bash

srvnum=
nodenum=
node=it_node_$nodenum
nodeaddr=

mymail=xrenoder@gmail.com
bromail=max.vattern@gmail.com
from=xrenoder@gmail.com
nodename=XreNode_$srvnum.$nodenum

user=$(whoami)
common=~/nodes
path=$common/$node

mkdir $common
chmod 0755 $common

echo ""
echo "*************************************************** INSTALL NODE *************************************************"
echo ""

cd ~/

rm -rf torrent_node
git clone https://github.com/metahashorg/Node-InfrastructureTorrent torrent_node

cd ~/torrent_node/src/Workers
wget https://raw.githubusercontent.com/xrenoder/mhitorrent/master/WorkerMain.cpp -O WorkerMain.cpp --no-check-certificate
wget https://raw.githubusercontent.com/xrenoder/mhitorrent/master/WorkerCache.cpp -O WorkerCache.cpp --no-check-certificate
wget https://raw.githubusercontent.com/xrenoder/mhitorrent/master/WorkerNodeTest.cpp -O WorkerNodeTest.cpp --no-check-certificate

cd ~/torrent_node/src
wget https://raw.githubusercontent.com/xrenoder/mhitorrent/master/SyncImpl.cpp -O SyncImpl.cpp --no-check-certificate

cd ~/torrent_node/build
git submodule update --init
cmake ..
make

echo ""
echo "*************************************************** SETUP NODE ***************************************************"
echo ""


mkdir $path
chmod 0755 $path
cp ~/torrent_node/build/src/torrent_node $path/$node
chmod 0755 $path/$node

rm -rf ~/torrent_node

cd $path

if [ ! -f $path/config.conf ]
then
	wget https://raw.githubusercontent.com/xrenoder/mhitorrent/master/config.conf -O config.conf --no-check-certificate
	echo "sign_key = '"$nodeaddr"';" | tee -a $path/config.conf
	echo "}" | tee -a $path/config.conf
fi

if [ ! -f $path/$nodeaddr.raw.prv ]
then
	touch $path/$nodeaddr.raw.prv
	chmod 0600 $path/$nodeaddr.raw.prv

	nano $path/$nodeaddr.raw.prv
fi


wget https://raw.githubusercontent.com/xrenoder/mhitorrent/master/run.sh -O run.sh --no-check-certificate
chmod 0755 run.sh

nano run.sh

sudo touch /var/spool/cron/crontabs/$user
sudo chmod 0600 /var/spool/cron/crontabs/$user
sudo chown $user:crontab /var/spool/cron/crontabs/$user
sudo echo "* * * * * "$path"/run.sh start" | sudo tee -a /var/spool/cron/crontabs/$user
sudo echo "01 02 * * * "$(which php)" "$path"/profit/partners.php > /dev/null &" | sudo tee -a /var/spool/cron/crontabs/$user

sudo echo "" | sudo tee -a /var/spool/cron/crontabs/$user

crontab -e

$path/run.sh restart

sleep 5

netstat -tupln | grep LISTEN

mkdir $common/mail
chmod 0755 $common/mail
	
if [ ! -f $common/mail/NodeOwner ]
then
	touch $common/mail/NodeOwner
	echo $mymail | tee -a $common/mail/NodeOwner
	echo $bromail | tee -a $common/mail/NodeOwner
fi

chmod 0755 $common/mail/NodeOwner
	
if [ ! -f $common/owner_pool ]
then
	touch $common/owner_pool
	echo "0x00770118d39f9a508877436540cf5a9b9d47d9b9b864a95b01" | tee -a $common/owner_pool
	echo "0x0037514ebf7fe64db8875a7a15755dc3e7ac1603ce126d78fa" | tee -a $common/owner_pool
	echo "0x00499def722899e12039f5998301312da84a94aad43c5a2720" | tee -a $common/owner_pool
	echo "0x0090801e2bf2e2fb39e69fa2677cf3068ae727d3ee468ab7b1" | tee -a $common/owner_pool
fi

chmod 0755 $common/owner_pool

mkdir $path/profit
chmod 0755 $path/profit

if [ ! -f $path/profit/Xrenoder ]
then
	touch $path/profit/Xrenoder
# Collection	
#	echo "0x0090801e2bf2e2fb39e69fa2677cf3068ae727d3ee468ab7b1" | tee -a $path/profit/Xrenoder
# Deleg Oth 1	
	echo "0x0037514ebf7fe64db8875a7a15755dc3e7ac1603ce126d78fa" | tee -a $path/profit/Xrenoder	
	echo $mymail | tee -a $path/profit/Xrenoder
fi

if [ ! -f $path/profit/Vattern ]
then
	touch $path/profit/Vattern
	echo "0x00395c259540b66341560d5f4550318235d2f79e234546f60c" | tee -a $path/profit/Vattern
	echo $bromail | tee -a $path/profit/Vattern
fi


if [ ! -d ~/mhphplib ]
then
	mkdir ~/mhphplib
	chmod 0755 ~/mhphplib

	mkdir ~/mhphplib/classes
	chmod 0755 ~/mhphplib/classes

	wget https://raw.githubusercontent.com/xrenoder/mhphplibs/master/config.inc -O ~/mhphplib/config.inc --no-check-certificate


	wget https://raw.githubusercontent.com/xrenoder/mhphplibs/master/checker.inc -O ~/mhphplib/checker.inc --no-check-certificate
	wget https://raw.githubusercontent.com/xrenoder/mhphplibs/master/loader.inc -O ~/mhphplib/loader.inc --no-check-certificate

	wget https://raw.githubusercontent.com/xrenoder/mhphplibs/master/Base.inc -O ~/mhphplib/classes/Base.inc --no-check-certificate
	wget https://raw.githubusercontent.com/xrenoder/mhphplibs/master/MetaHash.inc -O ~/mhphplib/classes/MetaHash.inc --no-check-certificate
	wget https://raw.githubusercontent.com/xrenoder/mhphplibs/master/Mail.inc -O ~/mhphplib/classes/Mail.inc --no-check-certificate

	wget https://raw.githubusercontent.com/xrenoder/mhphplibs/master/partners.inc -O ~/mhphplib/partners.inc --no-check-certificate
fi

rm -rf $path/profit/partners.php
touch $path/profit/partners.php

echo "<?" | tee -a $path/profit/partners.php
echo "define('NODENAME', '"$nodename"');" | tee -a $path/profit/partners.php
echo "define('FROM_MAIL', '"$from"');" | tee -a $path/profit/partners.php

echo "define('ROOT_DIR', __DIR__);" | tee -a $path/profit/partners.php
echo "define('SCRIPT_DIR', ROOT_DIR . '/../../../mhphplib');" | tee -a $path/profit/partners.php
echo "define('KEY_FILE', ROOT_DIR . '/../"$nodeaddr".raw.prv');" | tee -a $path/profit/partners.php

echo "require_once(SCRIPT_DIR . '/config.inc');" | tee -a $path/profit/partners.php
echo "require_once(SCRIPT_DIR . '/partners.inc');" | tee -a $path/profit/partners.php

echo "" | tee -a $path/profit/partners.php

$path/run.sh stop

echo "ps aux | grep "$node
