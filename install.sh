#!/bin/bash

# Installs Plone on Kubernetes using the helm chart developed during the
# Alpine City Strategic Sprint 2024. Tested on Ubuntu 24.04.1 LTS version,
# running Kubernetes on K3d (https://k3d.io/v5.7.4/)

# expected stdout of commands listed as 'comments' for reference

set -e

# if [ "$EUID" -ne 0 ]
#   then echo "Please run as root"
#   exit
# fi

sudo apt install curl docker.io
sudo snap install kubectl --classic
sudo snap install helm --classic

# if this check fails, logout and login again
sudo usermod -a -G docker `whoami`
docker info >/dev/null 2>&1

curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
: '
Preparing to install k3d into /usr/local/bin
k3d installed into /usr/local/bin/k3d
Run 'k3d --help' to see what you can do with it.
'

k3d --help
: '
https://k3d.io/
k3d is a wrapper CLI that helps you to easily create k3s clusters inside docker.
Nodes of a k3d cluster are docker containers running a k3s image.
All Nodes of a k3d cluster are part of the same docker network.

Usage:
  k3d [flags]
  k3d [command]

Available Commands:
  cluster      Manage cluster(s)
  completion   Generate completion scripts for [bash, zsh, fish, powershell | psh]
  config       Work with config file(s)
  help         Help about any command
  image        Handle container images.
  kubeconfig   Manage kubeconfig(s)
  node         Manage node(s)
  registry     Manage registry/registries
  version      Show k3d and default k3s version

Flags:
  -h, --help         help for k3d
      --timestamps   Enable Log timestamps
      --trace        Enable super verbose output (trace logging)
      --verbose      Enable verbose output (debug logging)
      --version      Show k3d and default k3s version

Use "k3d [command] --help" for more information about a command.
'

k3d cluster create mycluster
: '
INFO[0000] Prep: Network                                
INFO[0000] Created network 'k3d-mycluster'              
INFO[0000] Created image volume k3d-mycluster-images    
INFO[0000] Starting new tools node...                   
INFO[0001] Creating node 'k3d-mycluster-server-0'       
INFO[0001] Pulling image 'ghcr.io/k3d-io/k3d-tools:5.7.4' 
INFO[0003] Pulling image 'docker.io/rancher/k3s:v1.30.4-k3s1' 
INFO[0003] Starting node 'k3d-mycluster-tools'          
INFO[0009] Creating LoadBalancer 'k3d-mycluster-serverlb' 
INFO[0010] Pulling image 'ghcr.io/k3d-io/k3d-proxy:5.7.4' 
INFO[0013] Using the k3d-tools node to gather environment information 
INFO[0013] HostIP: using network gateway 172.18.0.1 address 
INFO[0013] Starting cluster 'mycluster'                 
INFO[0013] Starting servers...                          
INFO[0013] Starting node 'k3d-mycluster-server-0'       
INFO[0015] All agents already running.                  
INFO[0015] Starting helpers...                          
INFO[0015] Starting node 'k3d-mycluster-serverlb'       
INFO[0022] Injecting records for hostAliases (incl. host.k3d.internal) and for 2 network members into CoreDNS configmap... 
INFO[0024] Cluster 'mycluster' created successfully!    
INFO[0024] You can now use it like this:                
kubectl cluster-info
'

kubectl get nodes

: '
NAME                     STATUS   ROLES                  AGE    VERSION
k3d-mycluster-server-0   Ready    control-plane,master   104s   v1.30.4+k3s1
'

kubectl get pods -A

: '
NAMESPACE     NAME                                      READY   STATUS      RESTARTS   AGE
kube-system   coredns-576bfc4dc7-6fd7f                  1/1     Running     0          2m23s
kube-system   helm-install-traefik-crd-rb7n9            0/1     Completed   0          2m23s
kube-system   helm-install-traefik-j2mzb                0/1     Completed   1          2m23s
kube-system   local-path-provisioner-6795b5f9d8-x4w9p   1/1     Running     0          2m23s
kube-system   metrics-server-557ff575fb-6s9pb           1/1     Running     0          2m23s
kube-system   svclb-traefik-b2b009d4-gvcdh              2/2     Running     0          2m8s
kube-system   traefik-5fb479b77-vht77                   1/1     Running     0          2m8s
'