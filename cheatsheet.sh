#!/bin/bash

#Core Conepts
<<'COMMENT'
Master Node : 
    ETCD Cluster: Stores information about the cluster in Key:Value pairs
    kube-scheduler: Responsible for Scheduling applications or containers on nodes
    Controllers:
        Node-Controller: The Node-Controller manages nodes, handling both onboarding new nodes to the cluster and addressing situations when nodes become unavailable.
        Replication-Controller: Ensures desired number of containers running at all the time in your replication group.
    kube-apiserver: 
            - Responsible for ochestrating all operations within the cluster

Worker Nodes : 
    kubelet:
            - an agent who listens for instructions from kube-api server and deploy or destroys containers on the node
    kube-proxy:
            - enabling communication between services/containers within cluster
    Container-Runtime Engine:
            - Docker, containerd, rocket

Docker vs Containerd

Reference : https://kubernetes.io/docs/reference/tools/map-crictl-dockercli/#retrieve-debugging-information
	• ctr: For debugging containerd, with a limited feature set.
	• nerdctl: A Docker-like CLI for containerd, suitable for general container management.
    • crictl: A Kubernetes-centric debugging tool that works across various CRI-compatible runtimes.
COMMENT

#?----[ Cluster Architecture ]------------------------

#! Docker vs Containerd
crictl pull <image>   #Pulling images
crictl images # listing images
crictl ps #listing containers
crictl exec -it <container_id> <command> #Executing commands within a container
crictl logs <container_id> #Viewing container logs
crictl pods #Listing pods



#?---Scheduling


#? Logging and Monitoring

#? Application Lifecycle Management

#Cluster Maintenance

#Security

#Storage

#Networking

#Design and Install Kubernetes(Hardway)

#Install Kuberetes using kubeadm

#Troubleshooting

#End of course
