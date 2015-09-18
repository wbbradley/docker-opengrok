#!/bin/sh
mkdir $OPENGROK_INSTANCE_BASE
[ -d $OPENGROK_INSTANCE_BASE/data ] || mkdir $OPENGROK_INSTANCE_BASE/data
[ -d $OPENGROK_INSTANCE_BASE/etc ] || mkdir $OPENGROK_INSTANCE_BASE/etc
[ -d $OPENGROK_INSTANCE_BASE/src ] || mkdir $OPENGROK_INSTANCE_BASE/src

wget -O - https://java.net/projects/opengrok/downloads/download/opengrok-0.12.1.tar.gz | tar zxvf -
mv opengrok-* opengrok
cd /opengrok/bin
./OpenGrok deploy
