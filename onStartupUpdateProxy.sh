#!/usr/bin/env bash
#
#   VERSION = 0.1
#
# This script is under GPLv3. It is released AS IS.
# You are:
#   - freedom to use the software for any purpose,
#   - freedom to change the software to suit your needs,
#   - freedom to share the software with your friends and neighbors, and
#   - freedom to share the changes you make
#

companyNetwork=$1
amIInCompanyNetwork=1
ProxyConfFile="/etc/apt/apt.conf" #Tested on Ubuntu18.10

# Change values below based on your proxy setup
#networkProtocols=( http https ftp )
#networkPorts=( 8080 )

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

function activeOrDeactiveProxy () {
    lineOfAptConf=`sed 's/^\(.\).*/\1/' $ProxyConfFile`
    
    # Proprio brutta sta cosa che segue, da cambiare!
    # DOvrebbe essere una funzione a parte che controlla bene tutte le righe se sono commentate
    # In base a questo poi si può migliorare il resto
    if [ "${#lineOfAptConf}" == "5" ] || [ "${#lineOfAptConf}" > "5" ]; then
        isJustDeactive=0
    fi

    if [ $amIInCompanyNetwork == 0 ] ; then
        
        sed -i 's .  ' $ProxyConfFile
        echo "Proxy for APT is activated" # Remove "#" to the beginning of each line 
    elif [ $isJustDeactive == 0 ]; then
            echo "Actually APT proxy is just deactivated"
            return
        sed -i 's/^/#/' $ProxyConfFile # Add "#" to the beginning of each line
        echo "Proxy for APT is disactivated"
    else
        echo "Error. Set proxy manually"
    fi
}   

#-------- MAIN -------#

# Check if I am root
if [ `whoami` != 'root' ]; then
    echo "Must be root to run $0"
    exit 1;
fi

echo "Good, you are root to execute $0"
# Shorted version of root check
#[ "$(whoami)" != 'root' ] && ( echo Must be root to run $0; exit 1 )

if [ -s $ProxyConfFile ]; then
    echo "Great, the APT proxy configuration file exist"
else
    echo "The APT proxy configuration file does not exist" #In questo caso bisogna crearlo
fi

if isCompanyNetwork ; then
    activeOrDeactiveProxy
fi

exit 0
