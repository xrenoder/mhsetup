#!/bin/bash

nodenum=
ip=
srvnum=

sleepNoHeat=250
mymail=xrenoder@gmail.com
bromail=max.vattern@gmail.com
from=xrenoder@gmail.com
nodename=XreNode_$srvnum.$nodenum

user=$(whoami)
node=node$nodenum
common=peers
path=~/$common/$node
ipfile=$path/ip

mkdir $common
chmod 0755 $common

if [ -f $ipfile ]
then
	if [ $ip ] 
	then
		echo "****** !!!! IP already defined in file !!!! ********************"
		exit
	else
		ip=$(cat $ipfile)
	fi
else
	if [ ! $ip ] 
	then
		echo "****** !!!! IP need to be defined !!!! ********************"
		exit
	fi
fi


echo ""
echo "*************************************************** INSTALL NODE PROXY ***************************************************"
echo ""
cd ~/

rm -rf node_proxy
git clone https://github.com/metahashorg/node_proxy

touch node_proxy/src/xrenoIP.h
chmod  0644 node_proxy/src/xrenoIP.h

echo "static const char XRENO_IP[] = \""$ip"\";" | tee -a node_proxy/src/xrenoIP.h
echo "" | tee -a node_proxy/src/xrenoIP.h

rm -rf node_proxy/src/proxyserver.cpp
wget https://raw.githubusercontent.com/xrenoder/mhpeer/master/proxyserver.cpp -O node_proxy/src/proxyserver.cpp --no-check-certificate

rm -rf node_proxy/src/proxyserver.h
wget https://raw.githubusercontent.com/xrenoder/mhpeer/master/proxyserver.h -O node_proxy/src/proxyserver.h --no-check-certificate

rm -rf node_proxy/src/main.cpp
wget https://raw.githubusercontent.com/xrenoder/mhpeer/master/main.cpp -O node_proxy/src/main.cpp --no-check-certificate

cd node_proxy/build
./build.sh

echo ""
echo "*************************************************** SETUP NODE PROXY ***************************************************"
echo ""

if [ -f $ipfile ]
then
	rm -rf ~/$common/ip
	cp $ipfile ~/$common/ip
fi

if [ -f $path/main_key ]
then
	rm -rf ~/$common/main_key
	cp $path/main_key ~/$common/main_key
fi

rm -rf $path
mkdir $path
chmod 0755 $path
cp ~/node_proxy/build/proxy $path/$node
chmod 0755 $path/$node

rm -rf ~/node_proxy

cd $path

wget https://raw.githubusercontent.com/xrenoder/mhpeer/master/main.sh -O main.sh --no-check-certificate
chmod 0755 main.sh

nano main.sh

touch main_conf
chmod  0644 main_conf

echo "net-main" | tee -a $path/main_conf
echo "206.189.11.155 9999 1" | tee -a $path/main_conf
#echo "206.189.11.153 9999 1" | tee -a $path/main_conf
#echo "206.189.11.126 9999 1" | tee -a $path/main_conf
#echo "206.189.11.128 9999 1" | tee -a $path/main_conf
#echo "206.189.11.121 9999 1" | tee -a $path/main_conf
#echo "206.189.11.148 9999 1" | tee -a $path/main_conf
#echo "206.189.11.133 9999 1" | tee -a $path/main_conf
#echo "206.189.11.147 9999 1" | tee -a $path/main_conf

sudo touch /var/spool/cron/crontabs/$user
sudo chmod 0600 /var/spool/cron/crontabs/$user
sudo chown $user:crontab /var/spool/cron/crontabs/$user
sudo echo "* * * * * "$path"/main.sh "$sleepNoHeat" start" | sudo tee -a /var/spool/cron/crontabs/$user
sudo echo "01 02 * * * "$(which php)" ~/"$common"/profit/partners.php > /dev/null &" | sudo tee -a /var/spool/cron/crontabs/$user

#sudo echo "01 00 * * * "$(which php)" "$affdir"/payouts.php > "$affdir"/stdout.log &" | sudo tee -a /var/spool/cron/crontabs/$user
#sudo echo "55 23 * * * "$(which php)" "$affdir"/lastreward.php > "$affdir"/stdout.log &" | sudo tee -a /var/spool/cron/crontabs/$user

sudo echo "" | sudo tee -a /var/spool/cron/crontabs/$user

crontab -e

if [ -f ~/$common/ip ]
then
	cp ~/$common/ip $ipfile
	rm -rf ~/$common/ip
else
	touch $ipfile
	echo $ip | tee -a $ipfile
fi

if [ -f ~/$common/main_key ]
then
	cp ~/$common/main_key $path/main_key
	rm -rf ~/$common/main_key
else
	touch main_key
	chmod 0600 main_key

	nano main_key
fi

$path/main.sh $sleepNoHeat restart

sleep 5

netstat -tupln | grep LISTEN

mkdir ~/$common/mail
chmod 0755 ~/$common/mail
	
if [ ! -f ~/$common/mail/NodeOwner ]
then
	touch ~/$common/mail/NodeOwner
	echo $mymail | tee -a ~/$common/mail/NodeOwner
	echo $bromail | tee -a ~/$common/mail/NodeOwner
fi

chmod 0755 ~/$common/mail/NodeOwner
	
if [ ! -f ~/$common/owner_pool ]
then
	touch ~/$common/owner_pool
	echo "0x00770118d39f9a508877436540cf5a9b9d47d9b9b864a95b01" | tee -a ~/$common/owner_pool
	echo "0x0037514ebf7fe64db8875a7a15755dc3e7ac1603ce126d78fa" | tee -a ~/$common/owner_pool
	echo "0x00499def722899e12039f5998301312da84a94aad43c5a2720" | tee -a ~/$common/owner_pool
	echo "0x0090801e2bf2e2fb39e69fa2677cf3068ae727d3ee468ab7b1" | tee -a ~/$common/owner_pool
fi

chmod 0755 ~/$common/owner_pool

if [ ! -f ~/$common/prev_reward ]
then
	touch ~/$common/prev_reward
fi

chmod 0755 ~/$common/prev_reward

mkdir ~/$common/profit
chmod 0755 ~/$common/profit

if [ ! -f ~/$common/profit/Xrenoder ]
then
	touch ~/$common/profit/Xrenoder
# Collection	
#	echo "0x0090801e2bf2e2fb39e69fa2677cf3068ae727d3ee468ab7b1" | tee -a ~/$common/profit/Xrenoder
# Deleg Oth 1	
	echo "0x0037514ebf7fe64db8875a7a15755dc3e7ac1603ce126d78fa" | tee -a ~/$common/profit/Xrenoder	
	echo $mymail | tee -a ~/$common/profit/Xrenoder
fi

if [ ! -f ~/$common/profit/Vattern ]
then
	touch ~/$common/profit/Vattern
	echo "0x00395c259540b66341560d5f4550318235d2f79e234546f60c" | tee -a ~/$common/profit/Vattern
	echo $bromail | tee -a ~/$common/profit/Vattern
fi


mkdir ~/$common/affiliate
chmod 0755 ~/$common/affiliate

mkdir ~/$common/affiliate/classes
chmod 0755 ~/$common/affiliate/classes


wget https://raw.githubusercontent.com/xrenoder/mhphplibs/master/config.inc -O ~/$common/affiliate/config.inc --no-check-certificate
wget https://raw.githubusercontent.com/xrenoder/mhphplibs/master/checker.inc -O ~/$common/affiliate/checker.inc --no-check-certificate
wget https://raw.githubusercontent.com/xrenoder/mhphplibs/master/loader.inc -O ~/$common/affiliate/loader.inc --no-check-certificate

wget https://raw.githubusercontent.com/xrenoder/mhphplibs/master/Base.inc -O ~/$common/affiliate/classes/Base.inc --no-check-certificate
wget https://raw.githubusercontent.com/xrenoder/mhphplibs/master/MetaHash.inc -O ~/$common/affiliate/classes/MetaHash.inc --no-check-certificate
wget https://raw.githubusercontent.com/xrenoder/mhphplibs/master/Mail.inc -O ~/$common/affiliate/classes/Mail.inc --no-check-certificate

wget https://raw.githubusercontent.com/xrenoder/mhphplibs/master/partners.inc -O ~/$common/profit/partners.inc --no-check-certificate


rm -rf ~/$common/profit/partners.php
touch ~/$common/profit/partners.php

echo "<?" | tee -a ~/$common/profit/partners.php
echo "define('NODENAME', 'SERVER "$srvnum"');" | tee -a ~/$common/profit/partners.php
echo "define('FROM_MAIL', '"$from"');" | tee -a ~/$common/profit/partners.php

echo "define('ROOT_DIR', __DIR__);" | tee -a ~/$common/profit/partners.php
echo "define('SCRIPT_DIR', ROOT_DIR . '/../affiliate');" | tee -a ~/$common/profit/partners.php

echo "require_once(SCRIPT_DIR . '/config.inc');" | tee -a ~/$common/profit/partners.php
echo "require_once(ROOT_DIR . '/partners.inc');" | tee -a ~/$common/profit/partners.php

echo "" | tee -a ~/$common/profit/partners.php


$path/main.sh $sleepNoHeat stop

echo "ps aux | grep "$node

