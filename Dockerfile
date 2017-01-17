# Builds a docker image for rpm-ostree building and hosting 
# so we can build and host our own CentOS Atomic images
FROM fedora:25

# install needed packages
RUN dnf install -y rpm-ostree git python; \
dnf clean all

# create working dir and clone centos atomic definitions
# checkout downstream branch per this link

RUN mkdir -p /home/working; \
cd /home/working; \
git clone https://github.com/CentOS/sig-atomic-buildscripts; \
cd /home/working/sig-atomic-buildscripts && \
git checkout downstream; \
# create and initialize repo directory
mkdir -p /srv/rpm-ostree/repo && \
cd /srv/rpm-ostree/ && \
ostree --repo=repo init --mode=archive-z2
#
# copy custom build configs 
COPY centos-atomic-host-custom.json /home/working/sig-atomic-buildscripts
COPY config.ini /home/working/sig-atomic-buildscripts

# expose default SimpleHTTPServer port, set working dir
EXPOSE 8000
WORKDIR /home/working

# start SimpleHTTPServer
CMD pushd /srv/rpm-ostree/repo; python -m SimpleHTTPServer; popd
