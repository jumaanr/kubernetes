#!/bin/bash

#-----------------Install Container Runtime--------------------

#1 Open following ports : https://kubernetes.io/docs/reference/networking/ports-and-protocols/
  2 sudo ufw status
  3 sudo ufw enable
  4 sudo ufw allow 80/tcp
  5 sudo ufw allow 443/tcp
  6 sudo ufw allow 22/tcp
  7 sudo ufw allow 6643/tcp
  8 sudo ufw allow 2379/tcp
  9 sudo ufw allow 2380/tcp
 10 sudo ufw allow 10250/tcp
 11 sudo ufw allow 10259/tcp
 12 sudo ufw allow 10257/tcp
 13 sudo ufw allow 30000:32767/tcp
 14 sudo ufw reload
 15 sudo ufw status

#I saved above file to a shell script
scp [local_file] [username]@[remote_host]:[remote_directory]
scp 


#2 Forwarding IPv4 and letting iptables see bridged traffic : https://medium.com/cloud-native-daily/kubernetes-cli-kubectl-tips-and-tricks-that-you-may-not-have-known-about-and-will-make-your-8a1c3bf2f27a#:~:text=Use%20aliases%20and%20tab%20completion,if%20you%20use%20kubectl%20frequently.
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

#3 Verify br_netfilter
lsmod | grep br_netfilter
lsmod | grep overlay

#What are system variables
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

#4 Install Contianer Runtime---------------------------------------------
#Check existing installation
echo "Checking Existing Installations\n"
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
#Setup Docker Repository
echo "Setup Docker\n"
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
# Repository updated and added
echo "Repository Updated and Added\n"
# Installing Docker
echo "Installing Docker\n"
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# Running Docker
echo "Running Hello worlds\n"
sudo docker run hello-world

#-------------------------------------------------------Configure cGroups----------------------
ps -p 1
# Should give the type of init system
#Now we have to configure cgroup drivers for systemd
sudo vi /etc/containerd/config.toml
#paste following
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
#Delete all of the config ,a copy paste it
sudo systemctl restart containerd
# Do this for all three nodes

#--------------------------------------------------------------------------------------------
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# If the folder `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

#
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

#Installing modules
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

#Initialize Kube , Make sure you have 2VCPU assigned
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.0.0.4 --ignore-preflight-errors=NumCPU
# After initialize

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#Deploy the POD network, by joining the worker node
kubectl get pod
kubeadm join 10.0.0.4:6443 --token dz0eoi.z3k8lycw56n0x0ce \
        --discovery-token-ca-cert-hash sha256:f0a3cb68480255d3fc1ad59e43d0f550e837ca6d7bf6975ba18c0f46fbd62531
#Install addons : https://kubernetes.io/docs/concepts/cluster-administration/addons/
# We are using Weavenet : https://www.weave.works/docs/net/latest/kubernetes/kube-addon/ , Just run this on Master node
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
kubectl get pods -A #check pods of all namespaces

kubectl get ds -A
kubectl edit ds weave-net -n kube-system
#Edit the Weavenet configuration

#Weavenet config
      containers:
        - name: weave
          env:
            - name: IPALLOC_RANGE
              value: 10.0.0.0/16