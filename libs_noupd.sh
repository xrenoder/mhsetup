#!/bin/bash

phpver=7.3.2
inipath=/etc/php
fdsize=65536

ver=$phpver

echo "";
echo "*********************************** REQUIRED PACKETS INSTALL ********************************************";
echo "";
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
sudo apt-get install gcc-snapshot -y
sudo apt-get install bzip2 -y
sudo apt-get install zip unzip -y
sudo apt-get install libxml2-dev -y
sudo apt-get install curl -y
sudo apt-get install php7.0-curl -y
sudo apt-get install libgmp-dev -y
sudo apt-get install php-gmp -y
sudo apt-get install php7.0-gmp
sudo apt-get install libcurl4-gnutls-dev -y
sudo apt-get install libcurl4-nss-dev -y
sudo apt-get install libcurl7-openssl-dev -y
sudo apt-get install composer -y
sudo apt-get install sendmail -y
sudo apt-get update && sudo apt-get dist-upgrade -y

echo "";
echo "*********************************** GCC INSTALL ********************************************";
echo "";

sudo apt install gcc-8 g++-8 liburiparser-dev libssl-dev libevent-dev git automake libtool texinfo make -y
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 60 --slave /usr/bin/g++ g++ /usr/bin/g++-8 
sudo update-alternatives --config gcc 

echo ""
echo "*************************************************** INSTALL CMAKE ***************************************************"
echo ""
cd /tmp
wget https://github.com/Kitware/CMake/releases/download/v3.13.0/cmake-3.13.0.tar.gz --no-check-certificate
tar zxfv cmake-3.13.0.tar.gz
cd cmake-3.13.0
./bootstrap
./configure
make
sudo make install 

echo ""
echo "*************************************************** INSTALL LIBEVENT ***************************************************"
echo ""
cd /tmp
wget https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz --no-check-certificate
tar zxfv libevent-2.1.8-stable.tar.gz
cd libevent-2.1.8-stable
./configure
make
sudo make install

echo ""
echo "*************************************************** INSTALL LIBMICROHTTPD2 ***************************************************"
echo ""
cd /tmp
sudo rm -rf libmicrohttpd2
git clone https://github.com/metahashorg/libmicrohttpd2
cd libmicrohttpd2
./bootstrap
./configure
make
sudo make install

echo ""
echo "*************************************************** INSTALL LIBMHSUPPORT ***************************************************"
echo ""
cd /tmp
sudo rm -rf libmhsupport
git clone https://github.com/metahashorg/libmhsupport
cd libmhsupport/build
./build.sh
sudo make install

mkdir ~/peers
chmod 0755 ~/peers

cd ~/

echo "";
echo "*********************************** PHP.INI INSTALL ********************************************";
echo "";

sudo mkdir $inipath
sudo chmod 0755 $inipath

cd ~/
sudo wget https://raw.githubusercontent.com/xrenoder/mhsetup/master/php.ini -O $inipath/php.ini
sudo chmod 0644 $inipath/php.ini
sudo echo "sendmail_path="$(which sendmail)" -t" | sudo tee -a $inipath/php.ini

echo "";
echo "*********************************** PHP INSTALL ********************************************";
echo "";

cd /tmp
rm -rf /tmp/php-$ver/
wget -O php-$ver.tar.bz2 http://nl1.php.net/get/php-$ver.tar.bz2/from/this/mirror
tar -xvf php-$ver.tar.bz2
cd /tmp/php-$ver/

echo "# undef __FD_SETSIZE" | tee -a ./main/php.h
echo "# define __FD_SETSIZE "$fdsize | tee -a ./main/php.h
echo "# undef FD_SETSIZE" | tee -a ./main/php.h
echo "# define FD_SETSIZE "$fdsize | tee -a ./main/php.h

./configure --with-config-file-path=$inipath --enable-fd-setsize=$fdsize --enable-sockets --enable-pcntl --with-curl --with-gmp

make
sudo make install

echo "";
echo "*********************************** MH CRYPTO INSTALL ********************************************";
echo "";

cd /tmp
rm -rf /tmp/php-mhcrypto
git clone https://github.com/metahashorg/php-mhcrypto
cd php-mhcrypto
phpize
./configure --enable-mhcrypto
make
sudo make install

sudo echo "extension=mhcrypto.so" | sudo tee -a $inipath/php.ini

echo "";
echo "*********************************** MH CRYPTO TEST ********************************************";
echo "";

php -f /tmp/php-mhcrypto/mhcrypto.php

echo "";
echo "*********************************** VERSION ********************************************";
echo "";

php -v

echo "";
echo "*********************************** INI ********************************************";
echo "";

php -i|grep php.ini

echo "";
echo "*********************************** CONFIGURE ********************************************";
echo "";

php -i|grep ./configure

echo "";
echo "*********************************** LOCATION ********************************************";
echo "";

which php

echo "";
echo "*********************************** FD_SETSIZE ********************************************";
echo "";

php -r "print_r (get_defined_constants (true));" | grep FD_SETSIZE

cd ~/

rm ~/libs.sh
