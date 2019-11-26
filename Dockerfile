FROM centos:8
MAINTAINER Toioiz <toioiz@toioiz.com>

RUN yum -y install libatomic python3 \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	# Create service account and set permissions.
	&& groupadd dropbox \
	&& useradd -m -d /dropbox -c "Dropbox Daemon Account" -s /usr/sbin/nologin -g dropbox dropbox
# Install init script and dropbox command line wrapper
COPY dropbox  /usr/bin/dropbox
COPY start /root/start


# let Dropbox do it's thing
USER dropbox
RUN mkdir -p /dropbox/.dropbox /dropbox/.dropbox-dist /dropbox/Dropbox /dropbox/base \
	&& echo y | dropbox start -i

# Switch back to root, since the start script needs root privs to chmod to the user's preferrred UID
USER root

# Lets move dropbox into opt 
RUN mkdir -p /opt/dropbox \
	# Prevent dropbox to overwrite its binary
	&& cp -rfp /dropbox/.dropbox-dist/* /opt/dropbox/ \
        && chmod 000 /dropbox/.dropbox-dist 

WORKDIR /dropbox/Dropbox
EXPOSE 17500
VOLUME ["/dropbox/"]
ENTRYPOINT ["/root/start"]
