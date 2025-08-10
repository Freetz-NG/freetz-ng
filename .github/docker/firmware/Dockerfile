FROM ubuntu:22.04
ARG BUILD_USER=builduser

RUN \
    apt-get -y update && apt-get -y upgrade && apt-get -y dist-upgrade \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install \
    bash locales \
    pv cpio rsync kmod imagemagick inkscape graphicsmagick subversion git bc unar wget sudo gcc g++ binutils autoconf automake \
    autopoint libtool-bin make bzip2 libncurses5-dev libreadline-dev zlib1g-dev flex bison patch texinfo tofrodos gettext pkg-config ecj \
    perl libstring-crc32-perl ruby gawk libusb-dev unzip intltool libacl1-dev libcap-dev libc6-dev-i386 \
    lib32ncurses5-dev gcc-multilib bsdmainutils lib32stdc++6 libglib2.0-dev ccache cmake lib32z1-dev libsqlite3-dev sqlite3 libzstd-dev \
    netcat curl uuid-dev libssl-dev libgnutls28-dev u-boot-tools device-tree-compiler libelf-dev patchutils \
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

