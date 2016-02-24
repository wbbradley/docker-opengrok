#!/bin/sh
export JAVA_OPTS="-Xmx8192m -server"

sysctl -w fs.inotify.max_user_watches=8192000

cd /etc/tomcat7 && patch -p1 < 0001-tomcat-increase-http-header-size-to-65536.patch

service tomcat7 start

# first-time index
echo "** Running first-time indexing"
cd /opengrok/bin
OPENGROK_FLUSH_RAM_BUFFER_SIZE="-m 256" ./OpenGrok index

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
  OPENGROK_FLUSH_RAM_BUFFER_SIZE="-m 256" ./OpenGrok index
done
