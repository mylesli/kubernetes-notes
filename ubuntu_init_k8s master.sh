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

#2.關閉swap分區
sudo  swapoff -a
#要永久禁掉swap分区，打开如下文件注释掉swap那一行 （需要注释）
sudo sed -i 's/^/#swap.img      none    swap    sw      0       0$/swap.img      none    swap    sw      0       0/' /etc/fstab

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

#kubeadm init --apiserver-advertise-address=172.28.10.45 --pod-network-cidr=10.3.0.0/16 #單一master是網路情況調整


#mkdir -p $HOME/.kube
#sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#sudo chown $(id -u):$(id -g) $HOME/.kube/config
#kubectl get pods -o wide --all-namespaces
#kubectl apply -f https://docs.projectcalico.org/v3.9/manifests/calico.yaml
#kubeadm join 172.28.10.45:6443 --token fqgol2.whgg9vm9bq4je1ei     --discovery-token-ca-cert-hash sha256:092c561069ba65ae9ca309ad562cbdad25704eaadd89a6e2e8a9ac5119de5f95 其他台節點加入
#kubeadm join 172.28.10.45:6443 --token v3hsmf.sg3mil0bjtl728rw     --discovery-token-ca-cert-hash sha256:061c31163afd1ecfb62f8c00ba03ef9d375bbf5f6202abf46513df6a0b51d35a 其他台節點加入


#sudo kubeadm init --control-plane-endpoint "LOAD_BALANCER_DNS:LOAD_BALANCER_PORT" --upload-certs #多個master 單一API 預設是port 6443
#Your Kubernetes control-plane has initialized successfully!
#
#To start using your cluster, you need to run the following as a regular user:
#
#  mkdir -p $HOME/.kube
#  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#  sudo chown $(id -u):$(id -g) $HOME/.kube/config
#
#You should now deploy a pod network to the cluster.
#Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
#  https://kubernetes.io/docs/concepts/cluster-administration/addons/
#  kubectl apply -f https://docs.projectcalico.org/v3.11/manifests/calico.yaml #用calico

#You can now join any number of the control-plane node running the following command on each as root:
#
#  kubeadm join 172.28.10.47:6443 --token vsgkiq.58cxymhln0wa554k \
#    --discovery-token-ca-cert-hash sha256:51e9eba16e6797e26c926628a58105a2e90fa6f809a27abff82ab4828e9d7abd \
#    --control-plane --certificate-key 493d654c438943f6ab7297ba562da15188c47ef4d7315caca9856b7abc8ae32e
#
#Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
#As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
#"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.
#
#Then you can join any number of worker nodes by running the following on each as root:
#
#kubeadm join 172.28.10.47:6443 --token vsgkiq.58cxymhln0wa554k \
#    --discovery-token-ca-cert-hash sha256:51e9eba16e6797e26c926628a58105a2e90fa6f809a27abff82ab4828e9d7abd
