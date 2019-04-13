<div align="center">

# changeAPTproxyState
### Change the proxy state for APT. Active or deactive proxy rules in /etc/apt/apt.conf

</div>
<br/>
<div align="center">
  
[![Bash Shell](https://badges.frapsoft.com/bash/v1/bash.png?v=103)](https://github.com/ellerbrock/open-source-badges/)
![Version](https://img.shields.io/badge/version-pre--alpha-red.svg)
[![Open Source Love](https://badges.frapsoft.com/os/gpl/gpl.svg?v=102)](https://github.com/ellerbrock/open-source-badge/)

</div>
<br/>

Prerequisites
-----
**apt.conf** file must already exist in **/etc/apt/** in form:

```
Acquire::http::proxy "http://$yourProxy:$port";
Acquire::https::proxy "https://$yourProxy:$port";
Acquire::ftp::proxy "ftp://$yourProxy:$port";
```

Installation
------------
For now --> clone this repo and execute manually the script

Usage
-----
You Must execute ./onStartUpUpdateProxy with root privileges

```
 SYNOPSIS
    ${SCRIPT_NAME} [-iphv] companyNetwork proxyUrl

 OPTIONS
    -i, --interface       Check if the specified interface is up, then the proxy will change or not
    -p, --port            Set the port of the Proxy
    -h, --help            Print this help
    -v, --version         Print script information

 EXAMPLES
    sudo onStartUpUpdateProxy.sh 10.11.12.0 proxy.domain.xx
    sudo onStartUpUpdateProxy.sh -i enp2s0 10.11.12.0 proxy.domain.xx
```

License
-------
The project is under GPL v3 (see [LICENSE.md](https://https://github.com/Sonic0/changeAPTproxyState/blob/master/LICENSE.md))


