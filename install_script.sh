#!/bin/bash

sudo apt update 
sudo apt install apache2 -y
sudo apt install mysql-server -y
sudo apt  install awscli -y
sudo apt install unzip -y
sudo apt install php libapache2-mod-php php-mysql -y
cd /var/www/html/
sudo aws s3 cp s3://kemane-website/20230409_kemanedonfackcom09042023_064dadd32881b3743211_20230513153151_archive.zip ./
sudo aws s3 cp s3://kemane-website/installer.php ./
sudo rm index.html
cd ..
sudo chmod -R 777 html
