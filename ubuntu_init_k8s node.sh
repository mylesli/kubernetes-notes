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

#2.k8s 前置作業關閉swap分區
sudo  swapoff -a
#要永久禁掉swap分区，打开如下文件注释掉swap那一行 （需要注释）

sed -i '/\/swap.img/s/\/swap.img/#\/swap.img/g' /etc/fstab
#sed -i '/匹配字串/s/替換源字串/替換目標字串/g' filename ，\ 來跳脫字元 / 的干擾


#3.同步時區
sudo apt-get install ntp
#sudo timedatectl list-timezones | grep Asia
sudo timedatectl set-timezone Asia/Taipei
sudo timedatectl set-ntp yes
date
#4.關閉SELinux
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
#4.改host(可不改) & hostname
sudo sed -i 's/^preserve_hostname: false$/preserve_hostname: true/' /etc/cloud/cloud.cfg #這段一定要執行 不然rebook後hostname又恢復了
#vi /etc/hosts
#vi /etc/hostname

#K8S安裝
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl #安裝完才設定cgroup



#sudo sed -i '9 a/Environment="cgroup-driver=systemd/cgroup-driver=cgroupfs"'/etc/systemd/system/kubelet.service.d/10-kubeadm.conf #插入第九行
sudo sed -i '$a\Environment="cgroup-driver=systemd/cgroup-driver=cgroupfs"' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf #插入最後一行
systemctl daemon-reload
systemctl restart kubelet

