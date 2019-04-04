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
APT.CONF file must already exist in /etc/apt/ in form:

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
Execute the script with 2 parameter: first two bytes of the network address where the proxy must be activated and the proxy URL.
You must be _root_ .

_For example:_
```
./onStartUpUpdateProxy 10.11 myproxy.mydomain.com
```

License
-------
The project is under GPL v3 (see [LICENSE.md](https://https://github.com/Sonic0/changeAPTproxyState/blob/master/LICENSE.md))


