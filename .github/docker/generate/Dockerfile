FROM ubuntu:20.04
ARG BUILD_USR=freetz
ARG BUILD_GRP=freetz
ARG BUILD_UID=1001
ARG BUILD_GID=1001
ARG DEBIAN_FRONTEND=noninteractive

RUN printf "deb http://old-releases.ubuntu.com/ubuntu hirsute main restricted universe multiverse\n" > /etc/apt/sources.list.d/hirsute.list \
 && printf "Package: gcc g++ cpp gcc-multilib\nPin: release n=hirsute,o=Ubuntu\nPin-Priority: 700\n\nPackage: *\nPin: release n=hirsute,o=Ubuntu\nPin-Priority: -10\n" > /etc/apt/preferences.d/hirsute

RUN apt-get -y update && apt-get -y upgrade && apt-get -y dist-upgrade \
 && apt-get -y install \
    git bash locales imagemagick netcat-openbsd curl bsdmainutils xxd libarchive-zip-perl wget \
    \
    \
    \
    \
    \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/* \
 && locale-gen en_US.utf8 && locale-gen de_DE.UTF-8 && update-locale \
 && groupadd $BUILD_GRP -o -g $BUILD_GID \
 && useradd $BUILD_USR -o -s $(which bash) -d /workspace -u $BUILD_UID -g $BUILD_GID \
 && usermod $BUILD_USR -a -G root \
 && echo "$BUILD_USR ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
 && mkdir -p /workspace \
 && echo -e 'export LANG=en_US.utf8\n' > /workspace/.profile \
 && chown -R $BUILD_USR:$BUILD_GRP /workspace

WORKDIR /workspace
ENV BUILD_USER=$BUILD_USR
ADD entrypoint.sh /usr/local/bin
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
LABEL org.opencontainers.image.description="For internal use only!"
LABEL org.opencontainers.image.source=https://github.com/Freetz-NG/freetz-ng/

