FROM ubuntu:22.04
ARG BUILD_USER=builduser

RUN \
    apt-get -y update && apt-get -y upgrade && apt-get -y dist-upgrade \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install \
    git bash locales imagemagick netcat curl bsdmainutils xxd libarchive-zip-perl wget \
 && DEBIAN_FRONTEND=noninteractive apt-get -y clean \
 && rm -rf /var/lib/apt/lists/* \
 && locale-gen en_US.utf8 && locale-gen de_DE.UTF-8 && update-locale \
 && useradd $BUILD_USER -s $(which bash) -M -d /workspace && \
    echo "$BUILD_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /workspace && \
    echo -e 'umask 0022\nexport LANG=en_US.utf8' > /workspace/.profile && \
    chown -R $BUILD_USER /workspace

WORKDIR /workspace
ENV BUILD_USER=$BUILD_USER
ADD entrypoint.sh /usr/local/bin
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
LABEL org.opencontainers.image.description="For internal use only!"
LABEL org.opencontainers.image.source=https://github.com/Freetz-NG/freetz-ng/

