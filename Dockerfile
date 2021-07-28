FROM ubuntu:20.04

# Upgrade system
RUN apt-get update \
  && apt-get upgrade

# Pre-install tzdata
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
RUN apt-get install -y tzdata

# Yocto Project basic dependencies
RUN apt-get install -y gawk wget git diffstat unzip texinfo gcc \
  build-essential chrpath socat cpio python3 python3-pip python3-pexpect \
  xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa \
  libsdl1.2-dev pylint3 xterm python3-subunit mesa-common-dev

# Set up locales and environment lang
RUN apt-get -y install locales apt-utils sudo \
  && dpkg-reconfigure locales \
  && locale-gen en_US.UTF-8 \
  && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.utf8

# Install repo
# RUN apt-get install -y curl
# RUN curl -o /usr/local/bin/repo https://storage.googleapis.com/git-repo-downloads/repo \
#   && chmod a+x /usr/local/bin/repo

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Replace dash with bash
RUN rm /bin/sh && ln -s bash /bin/sh

# User management
RUN groupadd -g 1000 dev \
  && useradd -u 1000 -g dev -ms /bin/bash dev \
  && usermod -a -G sudo dev \
  && usermod -a -G users dev

# Run as dev user from the installation path
ENV YOCTO_INSTALL_PATH "/opt/yocto"
RUN install -o 1000 -g 1000 -d $YOCTO_INSTALL_PATH
USER dev
WORKDIR ${YOCTO_INSTALL_PATH}

# Set the Yocto release
ENV YOCTO_RELEASE "dunfell"

# Install Poky
RUN git clone --branch ${YOCTO_RELEASE} git://git.yoctoproject.org/poky

# Make /home/dev the working directory
WORKDIR /home/dev
