<div align="center">

# changeAPTproxyState
### Change the proxy state for APT. It activates or deactivates proxy rules in /etc/apt/apt.conf

</div>
<br/>
<div align="center">
  
[![Bash Shell](https://badges.frapsoft.com/bash/v1/bash.png?v=103)](https://github.com/ellerbrock/open-source-badges/)
![Version](https://img.shields.io/badge/version-0.2.3--alpha-red.svg)
[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.png?v=103)](https://github.com/ellerbrock/open-source-badges/)

</div>
<br/>

Compatibility
-----
Tested on _Ubuntu 18.10_ and _19.04_ .<br/>
Not work in _Ubuntu 16.04_, yet.

Usage
-----
You Must execute ./updateProxy with root privileges

```
 SYNOPSIS
    ./updateProxy [-iphv] companyNetwork proxyUrl

 OPTIONS
    -i, --interface       Check if the specified interface is up, then the proxy will change or not
    -p, --port            Set the port of the Proxy. Default port: 8080
    -h, --help            Print this help
    -v, --version         Print script information

 EXAMPLES
    sudo ./updateProxy 10.11.12.0 proxy.domain.xx
    sudo ./updateProxy -i enp2s0 10.11.12.0 proxy.domain.xx
```

Shortcuts
------------
Beyond manual use, there are some method to simplified the script calls:

* Create alias in your ~/.bashrc ( ~/.zshrc -> in case of ZSH)
  
  > alias "SHORTCUT_NAME"='sudo bash SCRIPT_PATH/changeAPTproxyState/updateProxy.sh -i enp0s2 10.11.12.0 proxy.domain.sh'


License
-------
The project is under GPL v3 (see [LICENSE.md](https://https://github.com/Sonic0/changeAPTproxyState/blob/master/LICENSE.md))


