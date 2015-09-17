#!/bin/sh
export JAVA_OPTS="-Xmx8192m -server"

sysctl -w fs.inotify.max_user_watches=8192000

cd /etc/tomcat7 && patch -p1 < 0001-tomcat-increase-http-header-size-to-65536.patch

service tomcat7 start

# link mounted source directory to opengrok
ln -s /src $OPENGROK_INSTANCE_BASE/src

# first-time index
echo "** Running first-time indexing"
cd /opengrok/bin
OPENGROK_FLUSH_RAM_BUFFER_SIZE="-m 256" ./OpenGrok index

# ... and we keep running the indexer to keep the container on
echo "** Waiting for source updates..."
touch $OPENGROK_INSTANCE_BASE/reindex
inotifywait -mr -e CLOSE_WRITE $OPENGROK_INSTANCE_BASE/src | while read f; do
  printf "*** %s\n" "$f"
  echo "*** Updating index"
  OPENGROK_FLUSH_RAM_BUFFER_SIZE="-m 256" ./OpenGrok index
done
