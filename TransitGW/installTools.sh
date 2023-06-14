#!/bin/bash
sudo su
apt-get update
apt-get install firewalld -y
apt-get install tcpdump -y
apt-get install network-manager -y
sudo apt install telnet -y
sudo apt-get install nmap -y

firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=23/tcp
firewall-cmd --permanent --add-port=100/tcp
firewall-cmd --reload



