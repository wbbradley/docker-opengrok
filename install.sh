#!/bin/sh

wget -O - https://java.net/projects/opengrok/downloads/download/opengrok-0.12.1.5.tar.gz | tar zxvf -
mv opengrok-* opengrok
cd /etc/tomcat7 && patch -p1 < 0001-tomcat-increase-http-header-size-to-65536.patch
