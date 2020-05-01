#!/bin/bash
#sudo su -
sudo apt-get update
sudo apt-get upgrade

sudo apt-get install vim
sudo apt install curl
sudo apt-get install net-tools
sudo apt-get install git
sudo apt-get install ssh
sudo apt-get install openssh-server
apt install dbus
#1.關閉防火墙
 sudo ufw disable

sudo sed -i 's/^#Port 22$/Port 22/' /etc/ssh/sshd_config
sudo sed -i 's/^#PermitRootLogin prohibit-password$/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#PubkeyAuthentication yes$/PubkeyAuthentication yes/' /etc/ssh/sshd_config

sudo systemctl restart ssh
sudo systemctl enable ssh

sudo mkdir -p ~/.ssh
sudo chmod 700 ~/.ssh
#scp -r root@172.28.10.241:/root/.ssh /root/.ssh #copy ssl cer

#sudo sed -i 's/^IP$/替代IP/' /etc/netplan/50-cloud-init.yaml
#sudo netplan try
#sudo netplan apply

#install Docker
sudo apt-get remove docker docker-engine docker.io containerd runc

 sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  apt-key add -

 sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
   
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

sudo  cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo  mkdir -p /etc/systemd/system/docker.service.d



sudo systemctl enable docker
sudo systemctl restart docker

#install docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version