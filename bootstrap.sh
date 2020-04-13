#!/bin/sh
set -e

read -p "Do you wish to install k3s server? : y/n: " CONDITION;

if [ "$CONDITION" == "n" ]; then
   exit 0
fi



if [ -z "$1" ]; then
	echo "Cluser master node i.e. `first` or joinging cluster as master or worker i.e. `join`"
else 
	export ACTION_TYPE=$1
fi
echo "ACTION_TYPE: $ACTION_TYPE"

if [ -z "$2" ]; then
	echo "Node type i.e. master/worker"
else 
	if [ "${ACTION_TYPE}" == "first" ] && [ "$2" == "worker" ]; then
		echo "Worker can not be first, worker just can join the existing clusters"
		exit 0
	fi
	export NODE_TYPE=$2
fi

if [ -z "$3" ]; then
	echo "Node ip address"
else 
	export IP_ADDRESS=$3
fi

USER=ubuntu
green=`tput setaf 2`
reset=`tput sgr0`
bold=`tput bold`

if [ "${ACTION_TYPE}" == "first" ] && [ "${NODE_TYPE}" == "master" ]; then
	
	echo "export FIRST_MASTER=${IP_ADDRESS}" > ./${INSTALL_K3S_VERSION}/cluster.sh
	
	. ./setenv.sh;\
	tar cvf - --exclude=".*" prep.sh bootstrap.sh README.md setenv.sh ./${INSTALL_K3S_VERSION}\
	| ssh ${USER}@${IP_ADDRESS} 'D=`mktemp -d`; \
	tar xvf - -C $D; \
	cd `dirname $D`;\
	. $D/setenv.sh;\
	export INSTALL_K3S_EXEC="--cluster-init";\
	$D/prep.sh; \
	rm $D -r;\
	echo "Started first cluster master node";\
	k3s -v;'
	
	
	echo "${green}${bold}Secret token${reset}${green}, saved at ./${INSTALL_K3S_VERSION}/node-token.txt you will need it for ${bold}joining cluster${reset} ${green}with additional masters and worker nodes, please commit it to secure git other than source control git${reset}"
	ssh ${USER}@${IP_ADDRESS} sudo cat /var/lib/rancher/k3s/server/node-token > ./${INSTALL_K3S_VERSION}/node-token.txt;
	
	echo "${green}${bold}Cluster kube config${reset}${green}, saved at ./${INSTALL_K3S_VERSION}/kubeconfig, please commit it to secure git other than source control git${reset}";\
	ssh ${USER}@${IP_ADDRESS} sudo cat /etc/rancher/k3s/k3s.yaml > ./${INSTALL_K3S_VERSION}/kubeconfig.yaml;
	sed -i .back "s/127.0.0.1/${IP_ADDRESS}/g" $(pwd)/${INSTALL_K3S_VERSION}/kubeconfig.yaml;
	sed -i .back "s/default/${K8S_CONFIG}/g" $(pwd)/${INSTALL_K3S_VERSION}/kubeconfig.yaml;
	
fi

if [ ${ACTION_TYPE} == "join" ] && [ ${NODE_TYPE} == "master" ]; then
	
	. ./setenv.sh;\
	tar cvf - --exclude=".*" prep.sh bootstrap.sh README.md setenv.sh ./${INSTALL_K3S_VERSION}\
	| ssh ${USER}@${IP_ADDRESS} 'D=`mktemp -d`; \
	tar xvf - -C $D; \
	cd `dirname $D`;\
	. $D/setenv.sh;\
	. $D/${INSTALL_K3S_VERSION}/cluster.sh;\
	export K3S_TOKEN="$(cat $D/${INSTALL_K3S_VERSION}/node-token.txt)";\
	echo "K3S_TOKEN: ---> $K3S_TOKEN";\
	export INSTALL_K3S_EXEC="--server https://${FIRST_MASTER}:6443";\
	echo "INSTALL_K3S_EXEC :--> $INSTALL_K3S_EXEC";\
	$D/prep.sh; \
	rm $D -r;\
	echo "Joined the cluster as master";\
	k3s -v;'
fi

if [ ${ACTION_TYPE} == "join" ] && [ ${NODE_TYPE} == "worker" ]; then
	
	. ./setenv.sh;\
	tar cvf - --exclude=".*" prep.sh bootstrap.sh README.md setenv.sh ./${INSTALL_K3S_VERSION}\
	| ssh ${USER}@${IP_ADDRESS} 'D=`mktemp -d`; \
	tar xvf - -C $D; \
	cd `dirname $D`;\
	. $D/setenv.sh;\
	. $D/${INSTALL_K3S_VERSION}/cluster.sh;\
	export K3S_TOKEN=$(cat $D/${INSTALL_K3S_VERSION}/node-token.txt);\
	export K3S_URL="https://${FIRST_MASTER}:6443";\
	$D/prep.sh; \
	rm $D -r;\
	echo "Joined the cluster as worker";\
	k3s -v;'
fi