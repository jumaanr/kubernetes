#!/bin/bash

#? This has all the cheat codes that I must keep in mind to excercise CKA Exam
# date : 25/02/24
# exam coupon code : 20KODE

#! ---------------------- Hacks-----------------------------------------------------#
# Hacks : https://kubernetes.io/docs/reference/kubectl/quick-reference/   , Search for "kubectl Quick Reference"  | https://github.com/dennyzhang/cheatsheet-kubernetes-A4

alias k='kubectl'
alias ll='ls -al'

# set the current context
kubectl config set-context $(kubectl config current-context) --namespace=mynamespace

# vi config :  vi ~/.vimrc
set smarttab
set expandtab
set shiftwidth=2
set tabstop=2
set number # sometime annoying
set pastetoggle=<F2>

# short version of it
set nu
set ts=2
set sw=2
set et
set ai
set pastetoggle=<F2>

#bash auto completion
sudo apt update
apt info bash-completion
sudo apt install bash-completion

source <(kubectl completion bash) # set up autocomplete in bash into the current shell, bash-completion package should be installed first.
echo "source <(kubectl completion bash)" >> ~/.bashrc # add autocomplete permanently to your bash shell.

alias k=kubectl
complete -o default -F __start_kubectl k  #You can also use a shorthand alias for kubectl that also works with completion:

#TODO tmux hacks - write a few tmux hacks
ctrl + a + |   #split the terminal into two
ctrl + a + -  # split horizontally into two
apt install tmux
yum install tmux
ctrl b % # split vertically
ctrl b // # split horizontally

# kubectl cheat sheet : https://kubernetes.io/docs/reference/kubectl/quick-reference/

#TODO  copy pasting hacks :  SHIFT + V , then shift > (indent 1 tab), press 2 and then shift > for 2 tabspace

#!---------------------- Core Concepts----------------------------------------------#

#? --- Docker vs Containerd--- #
# CRI (Container Runtime Interface ) : Allowed any vendor to make their container runtime work with Kubernetes as long as they adhere to #* Open Container Initiative (OCI) Standards
# OCI consists of two componenets :  imagespec (specifications on how an image should be build) , runtimespec (how a container runtime should be developed)

#* crictl : A container runtime interface debugging tool , which is compatible with kubernetes
# keyword in documentation : 'Mapping from dockercli to cricli'

crictl
crictl pull busybox #pull a container image , here its a docker image
crictl images # list available images
crictl ps -a # show all running and non-running containers
crictl exec -i -t < containerID > ls # run commands in an interactive terminal with pod
crictl logs # check logs of containers
crictl pods # crictl is aware of pods as well 

#? --- ETCD Cluster --- #


#? --- API Server --- #

# the main management component in Kubernetes : Its the only componenent that interacts with etcd datastore

#* ( Installing from Scratch )
# Installation instructions : https://github.com/shawnsong/kubernetes-handbook/blob/master/kube-apiserver/setup-kube-apiserver.md
# Binaries : https://www.downloadkubernetes.com/
# Git repo : https://github.com/kubernetes/apiserver
# official site : https://kubernetes.io/releases/  # can download the binaries at the download section at right side

wget https://storage.googleapis.com/kubernetes-release/release/v1.13.0/bin/linux/amd64/kube-apiserver


cat /etc/systemd/system/kube-apiserver.service # Api Server options can be seen here
ps -aux | grep kube-apiserver #check the running process in master node

#* Installed using kubeadm tool
cat /etc/kubernetes/manifests/kube-apiserver.yaml # configure kube apiserver options from here

# view kubeapi server in a form of pod
kubectl get pods -n kube-system


#? --- Kube Controller Manager --- #

# manages various controllers in kubernetes : process that continously monitor the state of the various components of kubernetes, ensure the system is in desired state
# node-controller : responsible of monitoring the status of nodes via kube-apiserver every 5 seconds. pod eviction timeout = 5m
# replication controller : monitor replica sets and ensure desired number of pods are running within the set
# all controllers are packaged into a single process called #? kube-controller-manager
# config reference : https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/
# download : https://kubernetes.io/releases/download/

#* Installing the hardway

wget https://dl.k8s.io/v1.29.2/bin/linux/amd64/kube-controller-manager
cat /etc/systemd/system/kube-controller-manager.service  # configure options

--node-monitor-period=5s
--node-monitor-grace-period=40s
--pod-eviction-timeout=5m0s #depricated

--controllers stringSlice Default: [*] # specify which controllers to enable , * denotes all. #TODO In case if you have any issue with availability of a certain controller, this is a good place to look at

ps -aux | grep kube-controller-manager #check the running process in master node

#* Installed using kubeadm tool
cat /etc/kubernetes/manifests/kube-controller-manager.yaml # configure kube-controller-manager in kubernetes manifests folder

#? --- Kube Scheduler --- #

# responsible for deciding which pod goes on which node, kubelet does the pod placement
# steps : filter nodes -> rank nodes
# metric based decisions : Resource requirements and limits , Taints and Tolerations , Node Selectors/Affinity

#* Installed from binaries : download binaries , install and confiure, run as a service
wget https://dl.k8s.io/v1.29.2/bin/linux/amd64/kube-scheduler
cat /etc/systemd/system/kube-scheduler.service  # can edit this

ps -aux | grep kube-scheduler # check the running process

#* Installed using kubeadm tool

cat /etc/kubernetes/manifests/kube-scheduler.yaml


#? --- kubelet --- #

# registers the node with kubernetes cluster, communicate with kube-api server and execute instructions and provide status updates of nodes

#* Installed from binaries : download binaries , install and confiure, run as a service

wget https://dl.k8s.io/v1.29.2/bin/linux/amd64/kubelet #download binaries
cat /etc/systemd/system/kubelet.service  # can edit this

ps -aux | grep kubelet # check the running process and effective options

#* Installed using kubeadm tool
#! kubeadm does not install kubelet automatically, we must install manually


#? --- kube-proxy --- #

#kube-proxy is a process runs on each node in the K8s cluster. Its job is to look for new services and every time a new service created, it creates appropriate rules on each node to forward traffic to those services to the back end pods. One way it achieves this using iptables rules. 
# kube-proxy is actually not a thing , it only lives in memory

#* Install using binaries
wget https://dl.k8s.io/v1.29.2/bin/linux/amd64/kube-proxy #download binaries and extract then and run it as a service
cat cat /etc/systemd/system/kubelet-proxy.service # configure options

#* Installing using kubeadm tool
# this deploys kube-proxy as a dameonset in each node
kubectl get pods -n kube-system
kubectl get daemonset -n kube-system

#?--- PODS ---#
#kubernetes any resource should have following basic template : https://kubernetes.io/docs/concepts/workloads/pods/
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    ports:
    - containerPort: 80

#?--- Replica Set--#

# https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/
# replicaset can have pods which have been created before replicaset created by using selectors (matching metadata , labels)
kubectl get replicaset # get list of replica set
kubectl delete replicaset myapp-replicaset # delte replicaset 

kubectl explain replicaset #TODO  Tip : This would give the syntex required in definition file , displayed in terminal 

# scale a replicaset : How do we change the number of replicas in a replicaset ?
#1) update the replicaset definition file and run following
kubectl replace -f replicaset-definition.yml
#2) specify number of replicas : note using the file name as input will not result in updating number of replicase in the file : https://kubernetes.io/docs/reference/kubectl/generated/kubectl_scale/#examples
kubectl scale --replicas=6 -f replicaset-definition.yml
#3) specify number of replicas and corresponding replicaset
kubectl scale --replicas=6 replicaset myapp-replicaset


#?--- Deployments ---#
# ref : https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

kubectl get deployments
kubectl get all # get all objects created
# ref : https://kubernetes.io/docs/reference/kubectl/conventions/
#TODO !!! Certification Tip !!!
kubectl create deployment --image=nginx nginx --dry-run=client -o yaml # create a deployment and get the output in yaml
kubectl create deployment --image=nginx nginx --dry-run=client -o yaml > nginx-deployment.yaml
kubectl create deployment --image=nginx nginx --replicas=4 --dry-run=client -o yaml > nginx-deployment.yaml #TODO in kubernetes 1.9+ can specify replicase

#?--- Services ---#
# kubernetes services enables communication between components and withing and outside of the application
# services creates loose coupling beween micro services in application
# https://kubernetes.io/docs/concepts/services-networking/service/


# https://kubernetes.io/docs/reference/kubectl/generated/kubectl_create/kubectl_create_service/
kubectl create service <service-type> <service-name> [--tcp=<port>] [--dry-run=server|client|none] [flags]
kubectl create service clusterip my-service --tcp=80:8080
# <service-type> : clusterip , nodeport , loadbalancer

#* Nodeport : 
# the service acts like a virtual server inside the node, inside the cluster it has its own ip address . That IP is called as the cluster ip of the service. 
# all port naming has taken in place with respective to the view of pod
# TargetPort : port on the pod , Port : port on the service , NodePort : port on the node (30,000-32,767 range of node ports)
# Port is mandatory , if no targetPort prpvider, it will be considered same as the port . If no nodePort provided , it will be assigned a port automatically within the range.

#* ClusterIP
# group the pods together and provides a single interface / service point to access the pods in the group 
# loosely coupled, scalable , 

kubectl get services # list the services
# the services can be reached by other pods using the clusterip or servicename.

#* Loadbalancer
# URL you give your users to access the applications ?
#only works with supported cloud platforms

#TODO Service Endpoints : Pods that service has identified that is going to direct its traffic to , based on selectors. If you see no endpoints better to check labels and selectors to identify the root cause.

#?--- Namespaces ---#


#initially following namespaces created :  default (for control plane components) , kube-system , kube-public (resources available for public)
# usecase : dev, production , test : you dont delete them by accident
# quota of resources can be allocated
# addressing db in local name spaces : mysql.connect("db-service") , addressing db in devnamespace : mysql.connect("db-service.dev.svc.cluster.local")

kubectl get pods --namespace=kube-system # get pods in kube-system namespace
kubectl get pods --all-namespaces # getting pods of all namespaces
kubectl create -f pod-definition.yaml --namespace=kube-system # create a pod in different namespace
kubectl run redis --image=redis -n=finance

# creating namespace using yaml file # ref : https://kubernetes.io/docs/tasks/administer-cluster/namespaces-walkthrough/
metadata:
  name: my-appod
  namespace: dev #! move namespace to pod definition file , so the resource will automatically create in that namepsace regardless you provide
  labels:
    app: myapp

# creating using kubectl command
kubectl create namespace <namespaceName>

# switching namespaces
kubectl config set-context $(kubectl config current-context) --namespace=mynamespace #TODO switch namespace and work on it 
$(kubectl config current-context) # identifies the current context ,then sets the namespace for the desired one for that current context
# contexts will be discussed later

# Resource Quota : Limit resourcs allocated to a certain namespace : https://kubernetes.io/docs/concepts/policy/resource-quotas/#viewing-and-setting-quotas

#? Imparative vs Declarative approaches
#TODO -------------------------------------------- Important Section ---------------------------------------------#
# Imparative commands
kubectl run --image=nginx nginx
kubectl run custom-nginx --image=nginx --port=8080 #just openining port, not exposing to a service

kubectl create deployment --image=nginx nginx
kubectl expose deployment nginx --port 80
kubectl edit deployment nginx
kubectl scale deployment nginx --replicas=5
kubectl set image deployment nginx nginx=nginx:1.18
kubectl create -f nginx.yaml
kubectl replace -f nginx.yaml
kubectl replace --force -f nginx.yamal # force delete and recreate the object
kubectl delete -f nginx.yaml

# declarative commands
kubectl apply -f deployment-definition.yaml # intelligent to create, update objects (even if doesnt exist)
kubectl apply -f /path/to/config-files #specify a directory so all the objects will create at once

#TODO#  Certification Tip
#deployments
kubectl create deployment --image=nginx nginx --dry-run=client -o yaml
kubectl create deployment nginx --image=nginx --replicas=4
kubectl scale deployment nginx --replicas=4
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > nginx-deployment.yaml

# Services
kubectl expose pod redis --port=6379 --name redis-service --dry-run=client -o yaml #* Create a Service named redis-service of type ClusterIP to expose pod redis on port 6379, (This will automatically use the pod’s labels as selectors)
kubectl create service clusterip redis --tcp=6379:6379 --dry-run=client -o yaml #This will not use the pods labels as selectors, instead it will assume selectors as app=redis

kubectl expose pod nginx --type=NodePort --port=80 --name=nginx-service --dry-run=client -o yaml #* This create a NodePort Service and  will automatically use the pod’s labels as selectors
kubectl run httpd --image=httpd:alpine --port=80 --expose --dry-run=client -o yaml #* create a pod while create a service under same label and name

kubectl create service nodeport nginx --tcp=80:80 --node-port=30080 --dry-run=client -o yaml #(This will not use the pods labels as selectors)



#TODO  https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands  "Search as 'Kubectl Reference Docs' "

# kubectl apply --> YAML format converted to json format --> 


#!---------------------- Scheduling ------------------------------------------------#
 #?-- Manual Scheduling --#
# manual scheduling allows you to place pods on desired nodes
#* this can be done before creation of pods by adding nodeName: key under specs of the pod definition : https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodename
#-----in a pod definition file---#
spec:
  containers:
  - name: nginx
    image: nginx
  nodeName: kube-01
#--------

# if scheduler is not there , the pods will be in pending state. As a workaraound you may manually assign pods . However, the nodeNode cannot be changed once a POD created. Because its a binding object to the pod
#* solution : create a podbinding object and parse it via a POST request

apiVersion: v1
kind: Binding
metadata:
  name: nginx
target:
  apiVersion: v1
  kind: Node
  name: node02

# after convert above to a json format and send a POST request

 #?--- Labels and Selectors ---#

#In POD Definition file
#------------
metadata:
  name: pod_name
  labels:
    app: front-end
  annotations:
    buildversion: 1.134
#------------
# once specified you can perform search
kubectl get pods --selector app=App1
kubectl get pod --selector env=prod,bu=finance,tier=frontend --no-headers | wc -l # gets the count without headers

#In Deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app:App1 # we are concerned about the lables of pods

# Annotations : keep record of other details in object

#?--- Taints and Tolerations --#

# ref : https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/
#applying a taint means applying a pod repellent spray on node :) | So no unwated pod going to be placed on this node #* Taints are applied on Nodes
#toleration : make a pod tolerant to a particular taints | #* Tolerations are applied on pods

kubectl taint nodes node-name key=value:taint-effect # taint effect means what happens to pods if they do not tolerate this taint
# Noschedule - pods wont be scheduled to be placed , PreferNoSchedule : may be pods will be scheduled, but less likely , Noexecute: Pods will not be scheduled and current pods will evicted with matching criteria
# example : 
kubectl taint nodes node1 key1=value1:NoSchedule #no pod will be able to schedule into node1
kubectl taint nodes node1 key1=value1:NoSchedule- # untainted using - symbox
# all of toleration should be quoted in "" 
# FACT : a taint has been set on master node when kubernetes setup to ensure no other pod deployed on master node
kubectl describe node kubemaster | grep Taint # will show the taint

#?--- Node Selectors ---#
# label the node prior to pod creation : https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes/ " Assign pods nodes"
kubectl label nodes <your-node-name> <label-key>=<label-value>
kubectl get nodes --show-labels
# then specify the nodeSelector in pod definition matching the same label specified in the node

#?--- Node Affinity ---#
# ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
# ref : https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/

# First add a lable to node
kubectl label nodes <your-node-name> <label-key>=<label-value>
# then configure node affinity in pods and create pods
# Operator : In -matches the values , NotIn pods that are not matching values, Exists : whether such a label exists , 
# what if node was not lableled , what happens to pod : Thats why we have following Node Affinity types.
# available:
requiredDuringSchedulingIgnoredDuringExecution
preferredDuringSchedulingIgnoredDuringExecution 
# advanced planned:
requiredDuringSchedulingRequiedDuringExecution #* will evict any pods running on nodes since requiredDuringExecution
preferredDuringSchedulingRequiedDuringExecution

# Conclustion : Taints and Tolerations ensure node would accept only the specified pods (but does not guarentee the tolrate pods will be always placed on tainted nodes). Node affinity ensure the pods would be placed on desired nodes (But does not guarentee other pods will place on the specified nodes). So the right solution is a combination of both.

#?--- Resource Limits ---#
# Search "Resource Management for Pods and Containers" and "Assign CPU Resources to Containers and Pods" #* In POD Level
# https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/  , https://kubernetes.io/docs/tasks/configure-pod-container/assign-cpu-resource/
# 1cpu = 1 aws vCPU , 1 GCP core, 1 Azure Core , 1 Hyperthread in VMWare
# 1Gi = 1 GibiByte
# Resource Requests , Resource Limits
# CPU will not be exceeded , but Memory limits can be exceeeded and pod will be evicated if it keeps banging on the memory limit always #! "TERMINATE" due to "OOM (Out of Memory)"
# default Memory=512Mi
# ideal setting interms of CPU requests : Resource Requests are defined , Resource Limits are not defined (If there's no requests for resources , then you can consume it )
# for memory its the same , but you have to destriy the pod and recreate . Since you cannot throttle memory

#* Limit resouces in namespace level for PODs 
# https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/memory-default-namespace/
# https://kubernetes.io/docs/concepts/policy/limit-range/
# limit ranges does not effect on existing pods, but new pods will be impacted 

# usecase : limit total memory that should consumed by all the pods collectively #* This is achieved by Resource Quotas in Namespace levels
#* Important :  https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/
# https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/quota-memory-cpu-namespace/

#TODO : Special Note : You cannot edit all the properties on a pod using edit command ( look at the Forbidden parameters in the header ) , but you can edit deployments : https://kodekloud.com/topic/a-quick-note-on-editing-pods-and-deployments-2/

#?--- Daemon Sets ---#

# Daemonsets automatically spwan a copy of instance in every node, whenever a node is added to the cluster
# Daemonsets ensure a one copy of the pod always present in all nodes in the cluster
# Usecase : Monitoring Agent, Log collector , kube-proxy , weavenet 
# definition file is same as Replicaset or Deployment : https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/ 
kubectl create -f daemon-set-definition.yaml
kubectl get daemonsets
k get daemonset kube-proxy -n kube-system
kubectl describe daemonsets

# earlier kubernetes used nodeName to place pods on nodes, after kubernetes v1.12 it uses NodeAffinity rules
# if you use a deployment or deplicase template , make sure to remove replicas feild in the definition file

#?--- Static Pods ---#
# static pod: No need controlplane node, work on their own. Only can create pods in the node . No deployments etc. 
# kubelet reads the definition files in following directory and create pods
/etc/kubernetes/manifests
# kubelet take care of the pods in that directory
# can be any directory , configure as following

kubectl run --restart=Never --image=busybox static-busybox --dry-run=client -o yaml --command -- sleep 1000 > /etc/kubernetes/manifests/static-busybox.yaml
# kubelet config file location /var/lib/kubelet/ look for config.yaml there you have the options

# check this location and find the kubelet.service configuration /usr/lib/systemd/system/kubelet.service.d 
# then find the kubelet configuration file with service options


#?--- Multiple Schedulers ---#
# ref : https://kubernetes.io/docs/tasks/extend-kubernetes/configure-multiple-schedulers/

#?--- Scheduler Events ---#

kubectl get pods --namespace=kube-system #view scheduler
# configure a scheduler of choice for a pod
schedulerName: my-customer-scheduler # This comes under spec section of pod aligned with containers (on under) : https://kubernetes.io/docs/tasks/extend-kubernetes/configure-multiple-schedulers/
#! [ERROR] If scheduler is not configured correctly POD will remain in 'PENDING state'
# view events of kubernetes api
kubectl get events
# view logs of kubernetes scheduler
kubectl logs my-custom-scheduler --name-space=kube-system

#?--- Configure Kubernetes Scheduler Profiles ---#
# ref : https://kubernetes.io/docs/concepts/scheduling-eviction/scheduling-framework/

#!-----------------------Loggin and Monitoring -------------------------------------#

#?--- Monitoring ---#
# Metrics server in Memory monitoring solution
kubectl top node #provides CPU and memory consumption of each node
kubectl top pod #view performance metrices of k8 pods


#? --- Logging ---#
kubectl logs -f <name_ofPod> <container_name>
kubectl logs -f event-simulator-pod event-simulator # get logs of certain pod or container , -f gives live logs

#!----------------------- Application Lifecycle Management--------------------------#

#!----------------------- Cluster Maintenance --------------------------------------#

#!----------------------- Security -------------------------------------------------#

#!----------------------- Storage --------------------------------------------------#

#!----------------------- Networking -----------------------------------------------#

#!------------------------ Installation , Configuration and Validation -------------#

#!------------------------ Troubleshooting -----------------------------------------#