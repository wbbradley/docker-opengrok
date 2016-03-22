#!/bin/sh

mkdir -p $OPENGROK_INSTANCE_BASE/data
mkdir -p $OPENGROK_INSTANCE_BASE/etc

wget -O - https://java.net/projects/opengrok/downloads/download/opengrok-0.12.1.tar.gz | tar zxvf -
mv opengrok-* opengrok

/opengrok/bin/OpenGrok deploy

cd /etc/tomcat7 && patch -p1 < 0001-tomcat-increase-http-header-size-to-65536.patch
