#!/bin/bash

# Step 04 ) Cluster Creation : https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/

# Initialize control-plane node : https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#initializing-your-control-plane-node

# we dont have multiple control plane nodes
# Choose POD Network Addon 
# --pod-network-cidr , --apiserver-advertise-address
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.56.11

