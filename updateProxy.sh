#!/usr/bin/env bash
#================================================================
# HEADER
#================================================================
#% DESCRIPTION
#%    Change APT proxy when you swith between work and private network
#% 
#%    You Must execute ${SCRIPT_NAME} with root privileges
#%
#% SYNOPSIS
#+    ${SCRIPT_NAME} [-iphv] companyNetwork proxyUrl
#%
#% OPTIONS
#%    -i, --interface		Check if the specified interface is up, then the proxy will change or not
#%    -p, --port            Set the port of the Proxy. Default port: 8080.
#%    -h, --help            Print this help
#%    -v, --version         Print script information
#%
#% EXAMPLES
#%    sudo ${SCRIPT_NAME} 10.11.12.0 proxy.domain.xx
#%    sudo ${SCRIPT_NAME} -i enp2s0 10.11.12.0 proxy.domain.xx
#%
#================================================================
#- IMPLEMENTATION
#-    version         ${SCRIPT_NAME} 0.2.3
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




activeProxy () {
    sed -i 's .  ' ${dir_proxyConfFile} # Remove "#" to the beginning of each line
}

deactiveProxy () {
	sed -i 's/^/#/' ${dir_proxyConfFile} # Add "#" to the beginning of each line
}

RemoveUselessHastag () {
	local stat=1

	while grep -q ^\#\# ${dir_proxyConfFile} ; do
		sed -i 's/##/#/g' ${dir_proxyConfFile}
		stat=0
	done

	return ${stat}
}

isEachLineInCorrectForm () {
	local stat=1
	local proxyProtocolsString=${proxyProtocols[@]} # Protocol array in single string to perform sobstitution of " " with "|" for the regex 
	local beginWithHash=0
	local beginWithoutHash=0
	local lineNumber=$( wc -l $dir_proxyConfFile | awk '{print $1}' )

	# Check if each line begins with given pattern, then save it in the array
	while read -r line ; do

		if [[ ${line} =~ ^Acquire::(${proxyProtocolsString// /|})::Proxy\ \"(${proxyProtocolsString// /|})://${proxyUrl}:${proxyPort}\"\;$ ]] ; then

			((beginWithoutHash++))
			stat=0
		
		elif [[ ${line} =~ ^\#Acquire::(${proxyProtocolsString// /|})::Proxy\ \"(${proxyProtocolsString// /|})://${proxyUrl}:${proxyPort}\"\;$ ]] ; then
			
			((beginWithHash++))
			stat=0
		
		else
			stat=1
			break
		fi

	done < ${dir_proxyConfFile}

	# Check if each line is equal.
	if [ ${stat} -eq 0 ]  ; then # This is 0 in case of each lines, of the apt conf file, is in right form

			if [ ${beginWithHash} -eq ${lineNumber} ] || [ ${beginWithoutHash} -eq ${lineNumber} ] ; then
				stat=0
			else
				stat=2
			fi

	fi

	return ${stat}
}

isProxyActive () {
	while read -r line ; do

		# case in which it is activated
		if [[ ${line} =~ ^Acquire::* ]] ; then
			AptProxyActive=0
		fi 
		# case in which it is deactivated
		if [[ ${line} =~ ^\#Acquire::* ]] ; then
			AptProxyActive=1
		fi

	done < ${dir_proxyConfFile}
}

isCompanyNetwork () {
	amIInCompanyNetwork=1

    myIP=$( hostname -I | awk '{print $1}' )
	myNetwork=$( ip route | grep "src ${myIP}" | head -n 1 | awk -F '/' '{print $1}' )

	info "My network is ${myNetwork} and the company network is ${companyNetwork}"

    [[ ${myNetwork} == ${companyNetwork} ]] && amIInCompanyNetwork=0

	return ${amIInCompanyNetworki}
}

isInterfaceUP () { 
	local status=1
	local resultOfCat
	local operationFilePath="${dir_netStat}${netInterfaceForProxy}/operstate"

	resultOfCat=$( cat ${operationFilePath} )
	if [ -a ${operationFilePath} ] && [ -r ${operationFilePath} ] && [ "${resultOfCat}" == "up" ] || [ "${resultOfCat}" == "UP" ]  ; then
		status=0
	fi
	return ${status}
}

# Test an IP address for validity.
# Code by https://www.linuxjournal.com/content/validating-ip-address-bash-script
isValidIP () {
    local ip=${1}
    local stat=1
		
	# Regex to check if IP is a valid ipv4 address
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] ; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
        	&& ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$? # Capture the result of the prev condition
	fi
    
	return ${stat}
}

isPrivateIP () {
	local ip=${1}
    local stat=1
		# Regex to check if the IP is in the range of private ip classes
    if [[ $ip =~ ^(192\.168|10\.|172\.1[6-9]\.|172\.2[0-9]\.|172\.3[01]\.) ]] ; then
        stat=$?
    fi
    
	return ${stat}
}

isValidProxy () {
	local url=${1}
	local stat=1

	if [[ ${url} =~ ^[a-z0-9]*[a-z0-9]\.[a-z0-9]*[a-z0-9]\.(it|com|eu)$ ]] ; then
		stat=$?
	fi

	return ${stat}
}

createDefaultAptConfFile () {
	local stat=1
    
    # Creates empty apt.conf file in /etc/apt/
    touch ${dir_proxyConfFile}

	if [ -e $dir_proxyConfFile ] ; then

        for protocol in ${proxyProtocols[@]} ; do
			if [ ${protocol} == "https" ] ; then
				echo "#Acquire::${protocol}::Proxy "\"http://${proxyUrl}:${proxyPort}\"\;"" >> $dir_proxyConfFile
			else 
				echo "#Acquire::${protocol}::Proxy "\"${protocol}://${proxyUrl}:${proxyPort}\"\;"" >> $dir_proxyConfFile
			fi
		done

		stat=0
	
    fi

	AptProxyActive=1
    return ${stat}
}

interfaceExists () ( [ -d ${dir_netStat}${netInterfaceForProxy} ] && return 0 || return 1 )

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
	info "${_txt2}"; info "{$_txt}"; info "{$_txt2}"; 
}

#== usage functions ==#
scriptinfo() { headFilter="^#-"
	[[ "${1}" = "usg" ]] && headFilter="^#+"
	[[ "${1}" = "ful" ]] && headFilter="^#[%+]"
	[[ "${1}" = "ver" ]] && headFilter="^#-"
	head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "${headFilter}" | sed -e "s/${headFilter}//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g"; }
usage() ( printf "Usage: "; scriptinfo usg )
usagefull() ( scriptinfo ful )

#== exit from the script with a defferent level of log ==#
exitFromScript () {
	local alertType=${1}
	local message=${2}
	case ${alertType} in
	
        info )
			info ${message}
		;;
	
        warning )
			warning ${message}
		;;
		
        error )
			error ${message}
		;;

		* )
			printf '\e[1m Unicorns hate you!! \e[0m\n'
		;;
		
	esac

	usage 1>&2
	exit 1
}




#============================
#  FILES AND VARIABLES
#============================

#== general variables ==#
SCRIPT_NAME=$( basename ${0} ) # scriptname without path
SCRIPT_DIR=$( cd $( dirname "${0}" ) && pwd ) # script directory
SCRIPT_FULLPATH="${SCRIPT_DIR}/${SCRIPT_NAME}"

SCRIPT_HEADSIZE=$( grep -sn "^# END_OF_HEADER" ${0} | head -1 | cut -f1 -d: )

HOSTNAME="$( hostname )"
FULL_COMMAND="${0} $*"
EXEC_DATE=$( date "+%y%m%d%H%M%S" )
EXEC_ID=${$}

SCRIPT_TIMELOG_FLAG=0
SCRIPT_TIMELOG_FORMAT="+%y/%m/%d@%H:%M:%S"

#== function variables ==#
netInterfaceForProxy=""
myIP=""
myNetwork=""
companyNetwork=""
readonly dir_proxyConfFile="/etc/apt/apt.conf"
readonly aptConfFile=$( basename $dir_proxyConfFile )
readonly dir_netStat="/sys/class/net/"
proxyUrl=""
# Change values below based on your proxy setup
proxyProtocols=( http https ftp ) # Default protocols
proxyPort=8080

#== option variables ==#
declare -i AptProxyActive
amIInCompanyNetwork=1
flagOptErr=0
flagArgErr=0
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
	case "${OPTION}" in
	    i ) netInterfaceForProxy=$OPTARG
            info "Interface in wich the proxy must be activated is: ${netInterfaceForProxy}"
        ;;

        p )	proxyPort=$OPTARG
            info "Proxy port is ${proxyPort}"
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


#== print usage if option error and exit ==#
[ ${flagOptErr} -eq 1 ] && exitFromScript




#============================
#  MAIN SCRIPT
#============================

flagMainScriptStart=0


#== Check if I am root ==#
[ $( whoami ) != "root" ] && exitFromScript error "Must be root to run ${SCRIPT_NAME}"

#== Check if netInterfaceForProxy is present, then the proxy will be activated only if the specified interface is UP ==#
if [ -n ${netInterfaceForProxy} ]; then

    if ! interfaceExists ${netInterfaceForProxy} ; then # Exit in case of interface do not exist
        exitFromScript error "Interface ${netInterfaceForProxy} do not exists, please check your interface name"
    elif ! isInterfaceUP ${netInterfaceForProxy} ; then # If first condition not match, so it checks if interface is UP
        exitFromScript error "Interface \e[1m${netInterfaceForProxy}\e[0m is \e[1mDOWN\e[0m, please check your connectivity"
	fi

else
    info "You don't have specified a preferred network interface, ${SCRIPT_NAME} do not check this option" 
fi

#==	Check if Network as arg1 is in a right form	==#
companyNetwork=${1}

if [ -n ${companyNetwork} ]  && isValidIP ${companyNetwork} ; then
	
	if ! isPrivateIP "${companyNetwork}" ; then
		exitFromScript error "You have not specified a private IP"
	fi

else
	exitFromScript error "You have specified an invalid IP"
fi


#==	Check if proxyUrl as arg2 is a valid url	==#
proxyUrl=${2}

# Check if URL is not empty
[ -z ${proxyUrl} ] && exitFromScript error "You must specify proxy URL" # Since $proxyUrl is empy, then exit

if isValidProxy "${proxyUrl}" ; then
	info "Proxy Url is valid"
else
	exitFromScript error "arg proxyUrl is invalid"
fi


#== Check if APT configuration file already exist, otherwise creates it ==#
if [ ! -e ${dir_proxyConfFile} ] ; then
	createDefaultAptConfFile
	info "The APT proxy configuration file does not exist. It has been created to you"

	#== If conf file exist, check if in the right form ==#
elif [ -s ${dir_proxyConfFile} ] ; then

	# Check if each line in apt.conf contains only one "#"(Hashtag)
	RemoveUselessHastag && info "Removed useless # for each lines in ${dir_proxyConfFile}"

	isEachLineInCorrectForm

	case $? in
		0)	
			# each line is in right form, so checks if proxy is already active
			isProxyActive 
		;;
		1)
			exitFromScript error "One line in ${aptConfFile} isn't in the right form"
		;;
		2)
			exitFromScript error "One line in ${aptConfFile} is different from others" 
		;;
	esac

else
	exitFromScript error "Check your apt.conf file"
fi


#== General info ==#
info "Your company network is $companyNetwork"
info "Proxy to configure is $proxyUrl"


#==	Check and change my apt proxy status ==#
isCompanyNetwork ${companyNetwork}

case ${AptProxyActive} in
	0)
		if (( ${amIInCompanyNetwork} == 0 )) ; then
			printf '\e[36;1m##== Proxy already ACTIVATED ==##\e[0m\n'
		else
			deactiveProxy
            [ $? ] && AptProxyActive=1 && printf '\e[1;34m#==== Proxy for APT is now Deactivated ====#\e[0m\n'
        fi
	;;
	1)
		if (( ${amIInCompanyNetwork} == 0 )) ; then
            activeProxy
            [ $? ] && AptProxyActive=0 && printf '\e[1;34m#==== Proxy for APT is now Activated ====#\e[0m\n'
		else
            printf '\e[36;1m##=== Proxy already DEACTIVATED ==##\e[0m\n'
		fi
	;;
	*)
		exitFromScript error "Unexpected Error"
	;;
esac


flagMainScriptStart=1




exit 0