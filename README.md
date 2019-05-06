<div align="center">

# changeAPTproxyState
### Change the proxy state for APT. Active or deactive proxy rules in /etc/apt/apt.conf

</div>
<br/>
<div align="center">
  
[![Bash Shell](https://badges.frapsoft.com/bash/v1/bash.png?v=103)](https://github.com/ellerbrock/open-source-badges/)
![Version](https://img.shields.io/badge/version-0.2--alpha-red.svg)
[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.png?v=103)](https://github.com/ellerbrock/open-source-badges/)

</div>
<br/>

Compatibility
-----
Tested on Ubuntu 18.10 and 19.04

Usage
-----
You Must execute ./onStartUpUpdateProxy with root privileges

```
 SYNOPSIS
    ${SCRIPT_NAME} [-iphv] companyNetwork proxyUrl

 OPTIONS
    -i, --interface       Check if the specified interface is up, then the proxy will change or not
    -p, --port            Set the port of the Proxy. Default port: 8080
    -h, --help            Print this help
    -v, --version         Print script information

 EXAMPLES
    sudo onStartUpUpdateProxy.sh 10.11.12.0 proxy.domain.xx
    sudo onStartUpUpdateProxy.sh -i enp2s0 10.11.12.0 proxy.domain.xx
```

Shortcuts
------------
Beyond manual use, there are some method to simplified the script calls:

* Create alias in your ~/.bashrc ( ~/.zshrc -> in case of ZSH)
  
  > alias SHORTCUT='sudo bash SCRIPT_PATH/changeAPTproxyState/onStartupUpdateProxy.sh -i enp0s2 10.21.0.0 proxy.domain.sh'


License
-------
The project is under GPL v3 (see [LICENSE.md](https://https://github.com/Sonic0/changeAPTproxyState/blob/master/LICENSE.md))


