#!/bin/bash

#install docker 
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo apt  install docker-compose -y
sudo systemctl enable docker
sudo systemctl start docker
echo ${aws_db_instance.rds_master.password} > readme1.txt
echo ${aws_db_instance.rds_master.username} > readme2.txt
echo ${aws_db_instance.rds_master.endpoint} > readme3.txt
# create Dockerfile
sudo cat <<EOF | sudo tee docker-compose.yml > /dev/null
version: '3'

services:
  wordpress:
   image: wordpress:4.8-apache
   ports:
    - 80:80
   environment:
     WORDPRESS_DB_USER: ${aws_db_instance.rds_master.username}
     WORDPRESS_DB_HOST: ${aws_db_instance.rds_master.endpoint}
     WORDPRESS_DB_PASSWORD: ${aws_db_instance.rds_master.password}
   volumes:
     - wordpress-data:/var/wwww/html

volumes:
  wordpress-data:
EOF

sudo docker-compose up

# install terraform

# wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
# echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
# sudo apt update && sudo apt install terraform

