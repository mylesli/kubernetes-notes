#kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
wget  https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta4/aio/deploy/recommended.yaml
#vim recommended.yaml
kubectl apply -f recommended.yaml
#vim dashboard-admin.yaml
kubectl apply -f  dashboard-admin.yaml 

#安裝helm 下載2.16版即可 3.0版還有點問題
wget https://get.helm.sh/helm-v2.16.1-linux-amd64.tar.gz
tar -zxvf helm-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm

#另一種安裝方式 helm
#curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
#chmod 700 get_helm.sh
#./get_helm.sh

kubectl apply -f rbac-config.yaml
helm init --service-account tiller

# helm search mysql
#helm install stable/mysql

#istio官網安裝
#curl -L https://istio.io/downloadIstio | sh -
#cd istio-1.4.3
#export PATH=$PWD/bin:$PATH 

#istio舊版安裝
curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.2.4 sh -
cd istio-1.2.4
sudo mv bin/istioctl /usr/local/bin
# 創建命名空间
kubectl create namespace istio-system

# 使用 kubectl apply 安装所有的 Istio CRD
helm template install/kubernetes/helm/istio-init --name istio-init --namespace istio-system | kubectl apply -f -

# 根据实际情况配置更新 values.yaml
vim install/kubernetes/helm/istio/values.yaml

# 部署 Istio 的核心组件
helm template install/kubernetes/helm/istio --name istio --namespace istio-system | kubectl apply -f -
