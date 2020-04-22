#!/bin/bash

sudo mkdir /var/lib/docker

sudo mkdir /docker

sudo mount --rbind /docker /var/lib/docker

#install docker

sudo apt update

sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \

   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \

   $(lsb_release -cs) \

   stable"

sudo apt update

sudo apt install -y docker-ce

sudo systemctl start docker

sudo systemctl enable docker

#install k8s

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add

sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

sudo apt install kubeadm -y

sudo swapoff -a

#permanent ::not working in ubuntu, comment /swap line

sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

#config k8s master

sudo kubeadm init --pod-network-cidr=10.244.0.0/16 #do not change to /24

mkdir -p $HOME/.kube

cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

chown $(id -u):$(id -g) $HOME/.kube/config

#singlenode cluster

kubectl taint nodes --all node-role.kubernetes.io/master-

#use flannel

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml

#install helm3

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3

chmod 700 get_helm.sh

./get_helm.sh

sleep 3m 30s

#install smartcheck with helm3 minus tiller

helm install deepsecurity-smartcheck \

--set auth.masterPassword=P@ssw0rd \

--set service.type=NodePort \

--set persistence.enabled=false \

https://github.com/deep-security/smartcheck-helm/archive/master.tar.gz

sleep 5m 30s

#get smartcheck access

$ export NODE_PORT=$(kubectl get -o jsonpath="{.spec.ports[0].nodePort}" services proxy)

$ export NODE_IP=$(kubectl get nodes -o jsonpath="{.items[0].status.addresses[0].address}")

$ echo Web URL: https://$NODE_IP:$NODE_PORT/

$ echo Username: $(kubectl get secrets -o jsonpath='{ .data.userName }' deepsecurity-smartcheck-auth | base64 --decode)

$ echo Password: $(kubectl get secrets -o jsonpath='{ .data.password }' deepsecurity-smartcheck-auth | base64 --decode)