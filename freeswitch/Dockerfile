FROM debian:jessie
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

# Add Freeswitch 1.6 repo
RUN echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main" > /etc/apt/sources.list.d/freeswitch.list \
    && apt-key adv --keyserver pool.sks-keyservers.net --recv-key D76EDC7725E010CF

# Install Freeswitch (use regular apt-get install to avoid weird dependency problems)
RUN apt-get update \
    && apt-get -qy install \
        freeswitch-meta-vanilla \
        freeswitch-mod-flite \
        freeswitch-mod-shout \
    && rm -rf /var/lib/apt/lists/*

# Copy basic configuration files
RUN cp -a /usr/share/freeswitch/conf/vanilla/. /etc/freeswitch/

# Don't expose any ports - use host networking

# Run Freeswitch
CMD stdbuf -i0 -o0 -e0 /usr/bin/freeswitch -c
