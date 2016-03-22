FROM ubuntu:14.04
MAINTAINER Jun-Ru Chang "jrjang@gmail.com"

ENV DEBIAN_FRONTEND noninteractive
ENV OPENGROK_INSTANCE_BASE /grok
ENV TERM xterm-color

ADD readonly_configuration.xml /etc/readonly_configuration.xml
ADD patch/0001-tomcat-increase-http-header-size-to-65536.patch /etc/tomcat7/0001-tomcat-increase-http-header-size-to-65536.patch
ADD install.sh /usr/local/bin/install
ADD run.sh /usr/local/bin/run

RUN apt-get update \
 && apt-get install -y openjdk-7-jre-headless exuberant-ctags git subversion mercurial tomcat7 wget inotify-tools \
 && /usr/local/bin/install

ENTRYPOINT ["/usr/local/bin/run"]

EXPOSE 8080
