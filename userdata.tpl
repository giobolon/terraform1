#!/bin/bash
sudo apt-get update -y
sudo sed -i 's/#Port 22/Port 6522/' /etc/ssh/sshd_config
sudo service ssh restart
sudo apt-get install apache2 -y
sudo systemctl enable apache2
sudo chown -R ubuntu:ubuntu /var/www/html
sudo apt-get install python3-pip -y
sudo pip install --upgrade pip
sudo pip install awscli
aws s3 cp s3://skillup-j.bolon-s3/index.html /var/www/html/index.html
sudo service apache2 reload