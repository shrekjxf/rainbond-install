#!/bin/bash

secretkey=$(yq r /srv/pillar/rainbond.sls secretkey)

cat /etc/passwd | grep saltapi || (
    useradd -M -s /sbin/nologin saltapi
    echo saltapi:$secretkey | chpasswd
    #echo $secretkey | passwd saltapi --stdin

for ((i=1;i<=60;i++ ));do
    sleep 1
    notready=$(curl http://127.0.0.1:7999/login -H "Accept: application/x-yaml" -d username='saltapi' -d password=$secretkey -d eauth='pam' | grep token)
    [ ! -z "$notready" ] && (
        curl http://127.0.0.1:7999/login -H 'Accept: application/x-yaml' -d username=saltapi -d password=$secretkey -d eauth=pam -s | grep token | awk '{print $2}' > /tmp/.token
    ) && break
done
) 


