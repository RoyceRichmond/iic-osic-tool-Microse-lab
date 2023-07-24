#!/bin/sh
sudo apt update
sudo apt upgrade
sudo apt install openssh-server
sudo systemctl status ssh
sudo systemctl enable ssh
sudo systemctl start ssh
sudo systemctl status ssh
sudo ufw allow ssh
sudo ufw enable
sudo ufw status