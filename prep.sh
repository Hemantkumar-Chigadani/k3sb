#!/bin/sh
set -e

copy_current_version(){

	if [ -d "/opt/k3s/current" ] 
	then
	    echo "/opt/k3s/current is already exists, so archieving it" 
		sudo mv /opt/k3s/current /opt/k3s/$(date +%Y%m%d_%H%M%S)
	fi
		
	echo "Creating dir /opt/k3s/current"
	sudo mkdir -p /opt/k3s/current
	sudo cp -r ${dir_path}/* /opt/k3s/current
}



setenv(){
	echo "Current user : $USER"
	echo "Settig up environment variables"
 
	full_path=$(realpath $0)
	echo "Full path: $full_path"
	
	dir_path=$(dirname $full_path)
	echo " Script path: $dir_path"
	
	cat $dir_path/setenv.sh
	. ${dir_path}/setenv.sh
}


install_and_start(){
	echo "Install k3s"
	/opt/k3s/current/${INSTALL_K3S_VERSION}/install.sh
}


{
setenv
copy_current_version
install_and_start
}