#!/usr/bin/env bash
#
#   VERSION = 0.1
#
# This file is under GPLv3.
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND
#
# You are:
#   - freedom to use the software for any purpose,
#   - freedom to change the software to suit your needs,
#   - freedom to share the software with your friends and neighbors, and
#   - freedom to share the changes you make
#
# Dependencies:
# 

companyNetwork=$1
amIInCompanyNetwork=
proxyConfFile="/etc/apt/apt.conf" #Tested on Ubuntu18.10
proxyUrl=$2
# Change values below based on your proxy setup
networkProtocols=( http https ftp )
proxyPorts=( 8080 )


function activeOrDeactiveProxy () {

    if [ $amIInCompanyNetwork == 0 ] ; then
        
        sed -i 's .  ' $proxyConfFile
        echo "Proxy for APT is activated" # Remove "#" to the beginning of each line 
    elif [ $amIInCompanyNetwork == 1 ]; then

        sed -i 's/^/#/' $proxyConfFile # Add "#" to the beginning of each line
        echo "Proxy for APT is disactivated"
    else
        echo "Error. Set proxy manually"
    fi
}

function isCompanyNetwork () {
    myNetwork=`hostname -I | awk -F '.' '{print $1"."$2}'`

    echo "My network $myNetwork.X.X and the network $companyNetwork.X.X are "
    [ $myNetwork == $companyNetwork ] && echo "In the same network"; echo "Not in the same network"

    if [[ $myNetwork == $companyNetwork ]]; then
        echo "I am in my company's network, active proxy"
        amIInCompanyNetwork=0
    else
        echo "I'm in a Private network, deactive proxy"
        amIInCompanyNetwork=1
    fi
}

#-------- MAIN -------#

# Check if I am root
if [ `whoami` != 'root' ]; then
    echo "Must be root to run $0"
    exit 1;
fi
# Shorted version of root check
#[ "$(whoami)" != 'root' ] && ( echo Must be root to run $0; exit 1 )

# Check if APT configuration file already exist
if [ ! -s $proxyConfFile ]; then
    touch $proxyConfFile
    # Populate apt.conf created
    sh -c `echo "\#Acquire::http::Proxy \"http://$proxyUrl:${proxyPorts[0]}\";" > $proxyConfFile` #TODO: Create a loop for each protocol and each port
    echo "The APT proxy configuration file does not exist. It has been created to you"
fi

if isCompanyNetwork ; then
    activeOrDeactiveProxy
fi

exit 0
