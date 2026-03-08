FROM ubuntu:20.04
ARG BUILD_USR=freetz
ARG BUILD_GRP=freetz
ARG BUILD_UID=1001
ARG BUILD_GID=1001
ARG BUILD_GCC=10

RUN apt-get -y update && apt-get -y upgrade && apt-get -y dist-upgrade \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install \
    bash locales libarchive-zip-perl  \
    pv cpio rsync kmod imagemagick inkscape graphicsmagick subversion git bc unar wget sudo gcc-${BUILD_GCC} g++-${BUILD_GCC} binutils autoconf automake \
    autopoint libtool-bin make bzip2 libncurses5-dev libreadline-dev zlib1g-dev flex bison patch texinfo tofrodos gettext pkg-config ecj \
    perl libstring-crc32-perl ruby ruby1.9 gawk libusb-dev unzip intltool libacl1-dev libcap-dev libc6-dev-i386 lib32ncurses5-dev \
    gcc-${BUILD_GCC}-multilib bsdmainutils lib32stdc++6 libglib2.0-dev ccache cmake lib32z1-dev libsqlite3-dev sqlite3 libzstd-dev netcat curl \
    uuid-dev libssl-dev libgnutls28-dev u-boot-tools device-tree-compiler openssl libelf-dev patchutils \
    $(apt-cache depends build-essential | awk '/Depends:/ {print $2}' | grep -vE 'gcc|g\+\+') gcc- g++- gcc-multilib- \
 && DEBIAN_FRONTEND=noninteractive apt-get -y clean \
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

