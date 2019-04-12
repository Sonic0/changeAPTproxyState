#!/usr/bin/env bash
#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    ${SCRIPT_NAME} [-iphv] companyNetwork proxyUrl
#%
#%    You Must execute ${SCRIPT_NAME} with root privileges
#%
#% DESCRIPTION
#%    Change proxy when you swith between work and private network
#%
#% OPTIONS
#%    -i, --interface               Check if the specified interfaced is up, then the proxy will change or not
#%    -p, --port                    Set the port of the Proxy
#%    -h, --help                    Print this help
#%    -v, --version                 Print script information
#%
#% EXAMPLES
#%   sudo ${SCRIPT_NAME} -i enp2s0 10.01 proxy.domain.xx 
#%
#================================================================
#- IMPLEMENTATION
#-    version         ${SCRIPT_NAME} 0.1
#-    author          Andrea Sonic0 Salvatori <andrea.salvatori92@gmail.com>
#-    license         GPLv3
#-    script_id       0
#-	  script_template Michel VONGVILAY (https://www.uxora.com)
#- 
#- This file is under GPLv3. It is distributed "AS IS", WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND
#-
#- You are:
#-   - freedom to use the software for any purpose,
#-   - freedom to change the software to suit your needs,
#-   - freedom to share the software with your friends and neighbors, and
#-   - freedom to share the changes you make
#-
#================================================================
#  DEBUG OPTION
#    set -n  # Uncomment to check your syntax, without execution.
#    set -x  # Uncomment to debug this shell script
#
#================================================================
# END_OF_HEADER
#================================================================

activeOrDeactiveProxy () {
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

isCompanyNetwork () {
    myNetwork=`hostname -I | awk -F '.' '{print $1"."$2}'`
    
    echo "My network $myNetwork.X.X and the network $companyNetwork.X.X are "
    [ $myNetwork == $companyNetwork ] && echo "In the same network" || echo "Not in the same network"
    
    if [[ $myNetwork == $companyNetwork ]]; then
        echo "I am in my company's network, active proxy"
        amIInCompanyNetwork=0
    else
        echo "I'm in a Private network, deactive proxy"
        amIInCompanyNetwork=1
    fi
}

createDefaultAptConfFile () {
    touch $proxyConfFile
    sh -c `echo "\#Acquire::http::Proxy \"http://$proxyUrl:$proxyPort\";" > $proxyConfFile` #TODO: Create a loop for each protocol and each port
    info "The APT proxy configuration file does not exist. It has been created to you"
}

isInterfaceUP () ( cat /sys/class/net/$netInterfaceForProxy/operstate )
interfaceExists () ( [[ -d /sys/class/net/$netInterfaceForProxy ]] && return 0 || return 1 )

    #== fecho function ==#
fecho() {
	_Type=${1} ; shift ;
	[[ ${SCRIPT_TIMELOG_FLAG:-0} -ne 0 ]] && printf "$( date ${SCRIPT_TIMELOG_FORMAT} ) "
	printf "[${_Type%[A-Z][A-Z]}] ${*}\n"
}

    #== error management functions ==#
info() ( fecho INF "${*}" )
warning() ( fecho WRN "WARNING: ${*}" 1>&2 )
error() ( fecho ERR "ERROR: ${*}" 1>&2 )
debug() { [[ ${flagDbg} -ne 0 ]] && fecho DBG "DEBUG: ${*}" 1>&2; }

infotitle() { _txt="-==# ${*} #==-"; _txt2="-==#$( echo " ${*} " | tr '[:print:]' '#' )#==-" ;
	info "$_txt2"; info "$_txt"; info "$_txt2"; 
}

    #== usage functions ==#
scriptinfo() { headFilter="^#-"
	[[ "$1" = "usg" ]] && headFilter="^#+"
	[[ "$1" = "ful" ]] && headFilter="^#[%+]"
	[[ "$1" = "ver" ]] && headFilter="^#-"
	head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "${headFilter}" | sed -e "s/${headFilter}//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g"; }
usage() ( printf "Usage: "; scriptinfo usg )
usagefull() ( scriptinfo ful )

#============================
#  FILES AND VARIABLES
#============================

  #== general variables ==#
SCRIPT_NAME=`basename ${0}` # scriptname without path
SCRIPT_DIR=`cd $(dirname "$0") && pwd` # script directory
SCRIPT_FULLPATH="${SCRIPT_DIR}/${SCRIPT_NAME}"

SCRIPT_HEADSIZE=$(grep -sn "^# END_OF_HEADER" ${0} | head -1 | cut -f1 -d:)

HOSTNAME="$(hostname)"
FULL_COMMAND="${0} $*"
EXEC_DATE=$(date "+%y%m%d%H%M%S")
EXEC_ID=${$}

SCRIPT_TIMELOG_FLAG=0
SCRIPT_TIMELOG_FORMAT="+%y/%m/%d@%H:%M:%S"

    #== function variables ==#
netInterfaceForProxy=""
companyNetwork=""
proxyConfFile="/etc/apt/apt.conf" #Tested on Ubuntu18.10
proxyUrl=""
# Change values below based on your proxy setup
networkProtocols=( http https ftp ) # Default protocols
proxyPort=""

    #== option variables ==#
amIInCompanyNetwork=0
flagOptErr=0
flagMainScriptStart=0
flagDbg=0

#============================
#  PARSE OPTIONS WITH GETOPTS
#============================

  #== set short options ==#
SCRIPT_OPTS=':i:phv-:'

  #== set long options associated with short one ==#
typeset -A ARRAY_OPTS
ARRAY_OPTS=(
    [interface]=i
	[ports]=p
	[help]=h
	[man]=h
)

  #== parse options ==#
while getopts ${SCRIPT_OPTS} OPTION ; do
	#== translate long options to short ==#
	if [[ "x$OPTION" == "x-" ]]; then
		LONG_OPTION=$OPTARG
		LONG_OPTARG=$(echo $LONG_OPTION | grep "=" | cut -d'=' -f2)
		LONG_OPTIND=-1
		[[ "x$LONG_OPTARG" = "x" ]] && LONG_OPTIND=$OPTIND || LONG_OPTION=$(echo $OPTARG | cut -d'=' -f1)
		[[ $LONG_OPTIND -ne -1 ]] && eval LONG_OPTARG="\$$LONG_OPTIND"
		OPTION=${ARRAY_OPTS[$LONG_OPTION]}
		[[ "x$OPTION" = "x" ]] &&  OPTION="?" OPTARG="-$LONG_OPTION"
		
		if [[ $( echo "${SCRIPT_OPTS}" | grep -c "${OPTION}:" ) -eq 1 ]]; then
			if [[ "x${LONG_OPTARG}" = "x" ]] || [[ "${LONG_OPTARG}" = -* ]]; then 
				OPTION=":" OPTARG="-$LONG_OPTION"
			else
				OPTARG="$LONG_OPTARG";
				if [[ $LONG_OPTIND -ne -1 ]]; then
					[[ $OPTIND -le $Optnum ]] && OPTIND=$(( $OPTIND+1 ))
					shift $OPTIND
					OPTIND=1
				fi
			fi
		fi
	fi

	#== options follow by another option instead of argument ==#
	if [[ "x${OPTION}" != "x:" ]] && [[ "x${OPTION}" != "x?" ]] && [[ "${OPTARG}" = -* ]]; then 
		OPTARG="$OPTION" OPTION=":"
	fi

	#== manage options ==#
	case "$OPTION" in
	    i ) netInterfaceForProxy=$OPTARG
            info "Interface in wich the proxy must be activated is: $interfaceToCheck"
        ;;

        p )	proxyPort=$OPTARG
            info "Proxy port is $proxyPort"
		;;

		h ) usagefull
			exit 0
		;;
		
		v ) scriptinfo
			exit 0
		;;
		
		: ) error "${SCRIPT_NAME}: -$OPTARG: option requires an argument"
			flagOptErr=1
		;;
		
		? ) error "${SCRIPT_NAME}: -$OPTARG: unknown option"
			flagOptErr=1
		;;
		* ) error "Unknown error while processing options"
        	flagOptErr=1
        ;;
	esac
done
shift $((${OPTIND} - 1)) ## shift options

#============================
#  MAIN SCRIPT
#============================
	
	#== Check if I am root ==#
[ `whoami` != "root" ] && error "Must be root to run ${SCRIPT_NAME}" && flagOptErr=1

    #== Check if interface is passed as option and then if it is UP ==#
if [ $netInterfaceForProxy != "" ]; then

    if interfaceExists "$netInterfaceForProxy" ; then 
        isInterfaceUP "$netInterfaceForProxy"
    fi
        if [ $? != "UP" ] ; then 
            info "Interface $netInterfaceForProxy is DOWN or do not exists, please check your connectivity" && flagOptErr=1
        fi

else
    info "You don't have specified a preferred network interface, $SCRIPT_NAME do not check this option" 
fi

    #== print usage if option error and exit ==#
[ $flagOptErr -eq 1 ] && usage 1>&2 && exit 1

flagMainScriptStart=1

	#== Check if APT configuration file already exist ==#
[ ! -s $proxyConfFile ] && createDefaultAptConfFile

companyNetwork=${1}
proxyUrl=${2}
info "Your company network is $companyNetwork"
info "Proxy to configure is $proxyUrl"

if isCompanyNetwork "$companyNetwork" ; then
    activeOrDeactiveProxy
fi

flagMainScriptStart=0
exit 0
