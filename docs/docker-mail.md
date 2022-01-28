# Sending mail from docker container

Set mail host to the container's host ip i.e.:

```python
mail.smtp.server = 72.14.189.242
```

Configure `postfix` to accept conections from docker container, which normally is running with network `172.17.0.0/255.255.255.0`

/etc/postfix/main.cf
```
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 172.17.0.0/24
```
