# K3SB
K3S HA cluster from binary


# Introduction
K3SB is inspired by K3S as light weight K8S. This repo consists of few scripts to 
install K3S HA cluster in few steps.

Why K3S? This is very light weight (50MB in size, runtime <300MB on average) and 
does not need docker to be installed on hosts. K3S is 5 S less from K8S to keep 
it very simple to deploy and understand. This tool exact fit to Edge environment 
for now and hybrid/pure cloud environment for future. 

K3S is very trimmed version of K8S as light weight as possible and keeping to 
open to add as much you need more k8s application later. K3S is certified 
Kubernetes distribution by cloud native foundation (CNCF).

Other important benefits:
1) Pods can be run on master node as well by default, can be disabled as well.
2) Very easy to bring cluster in Edge environment with internet connection restrictions

[ Note: I had evaluated Kind, Micro8S, Kubeadm, Kops & other CNCF certified Kubernetes 
distributions for Edge environment, k3s out stood for its simplified and how quick HA 
k8s cluster can brought up in few steps; k8s is heavy as including lots for cloud like 
cloud provider control manager etc. k3s is disassemble all parts for original full k8s 
and assemble only core required parts.]

## Building Cluster:
Any dev could be able to build or upgrade or add more master/worker nodes if need once 
machine is accessed from your local machine. If you shh key is password protected, make 
sure you refer to `Note` to make appropriate update to `bootstrap.sh` to enable ssh connection 
to remote machine to be added to cluster.

1) First master node\
`./bootstrap.sh first master <ip-address/192.168.64.5>`
2) Join the cluster as master\
`./bootstrap.sh join master <ip-address/192.168.64.6>`
3) Join the cluster as worker\
`./bootstrap.sh join worker <ip-address/192.168.64.7>`

# Note:
SSH-Key:\
`sshpass -p password ssh ubuntu@192.168.64.5 -i ssh-key location` for protected ssh-key\
OR\
`ssh server -l username -p 2222 ssh ubuntu@192.168.64.5` for username/password

## Locally building cluster (3 master nodes with 2 worker nodes):

### Prerequisites
1) `multipass` software is installed
2) ssh-key details to added to `cloud-init.yml` if any

### Steps:
1) Create vms on your local machine\
`multipass launch bionic \
  --name master-11 \ # master-12, master-13, worker-11, worker-12
  --cpus 1 \
  --mem 1G \
  --disk 4G \
  --cloud-init ./multipass/cloud-init.yml`
2) Follow steps [Building cluster](#building-cluster) section
 
# Next steps:

 ## Docker registry config setup
https://rancher.com/docs/k3s/latest/en/installation/private-registry/ 

 ## Upgrade steps: TCD
 
# References:

1) K3S: https://rancher.com/docs/k3s/
2) K3D: https://github.com/rancher/k3d
3) K3SUP: https://github.com/alexellis/k3sup