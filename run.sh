#!/bin/sh

if ! [ -f $OPENGROK_INSTANCE_BASE/deploy ]; then
  mkdir -p $OPENGROK_INSTANCE_BASE/data
  mkdir -p $OPENGROK_INSTANCE_BASE/etc

  /opengrok/bin/OpenGrok deploy
  touch $OPENGROK_INSTANCE_BASE/deploy

  mv /etc/readonly_configuration.xml /grok/etc
fi

export JAVA_OPTS="-Xmx8192m -server"
export OPENGROK_FLUSH_RAM_BUFFER_SIZE="-m 256"
export READ_XML_CONFIGURATION="/grok/etc/readonly_configuration.xml"

sysctl -w fs.inotify.max_user_watches=8192000

service tomcat7 start

mkdir -p $OPENGROK_INSTANCE_BASE/src

# first-time index
echo "** Running first-time indexing"
/opengrok/bin/OpenGrok index

# ... and we keep running the indexer to keep the container on
echo "** Waiting for source updates..."
touch $OPENGROK_INSTANCE_BASE/reindex

if [ $INOTIFY_NOT_RECURSIVE ]; then
  INOTIFY_CMDLINE="inotifywait -m -e CLOSE_WRITE $OPENGROK_INSTANCE_BASE/reindex"
else
  INOTIFY_CMDLINE="inotifywait -mr -e CLOSE_WRITE $OPENGROK_INSTANCE_BASE/src"
fi

$INOTIFY_CMDLINE | while read f; do
  printf "*** %s\n" "$f"
  echo "*** Updating index"
  /opengrok/bin/OpenGrok index
done
