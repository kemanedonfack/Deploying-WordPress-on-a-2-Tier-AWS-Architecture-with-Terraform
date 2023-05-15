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
sudo apt  install awscli -y
sudo apt install unzip -y
sudo mkdir kemane
cd kemane/
sudo aws s3 cp s3://kemane-website/20230409_kemanedonfackcom09042023_064dadd32881b3743211_20230513153151_archive.zip ./
sudo aws s3 cp s3://kemane-website/installer.php ./

# create Dockerfile
sudo cat <<EOF > Dockerfile
# Use the official WordPress image as the base
FROM wordpress:latest

# Set the working directory in the container
WORKDIR /var/www/html

# Copy the application files to the container
COPY 20230409_kemanedonfackcom09042023_064dadd32881b3743211_20230513153151_archive.zip /var/www/html/
COPY installer.php /var/www/html/

# Install additional PHP extensions if needed
RUN docker-php-ext-install mysqli

# Set the ownership of the WordPress files
RUN chown -R www-data:www-data /var/www/html

# Expose port 80
EXPOSE 80

# Start the Apache web server
CMD ["apache2-foreground"]
EOF
sudo docker build -t wordpress .
sudo docker run -d -p 8080:80 wordpress


# install terraform

# wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
# echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
# sudo apt update && sudo apt install terraform

