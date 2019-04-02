# changeAPTproxyState
### Change the proxy state for APT. Active or deactive proxy rules in /etc/apt/apt.conf

*This is a draft of code.*

APT.CONF file must already exist in /etc/apt/ in this form:

```
Acquire::http::Proxy "http://$yourProxy:$port";
Acquire::https::proxy "https://$yourProxy:$port";
Acquire::ftp::proxy "ftp://$yourProxy:$port";
```
