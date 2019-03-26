FROM debian:jessie

ENV OPENVAS_LIBRARIES_VERSION=9.0.1 \
  OPENVAS_SCANNER_VERSION=5.0.8

RUN apt-get update -y && \
  apt-get install -y --no-install-recommends --fix-missing \
  pkg-config libssh-dev libgnutls28-dev libglib2.0-dev libpcap-dev \
  libgpgme11-dev uuid-dev bison libksba-dev libhiredis-dev libsnmp-dev \
  rsync wget cmake build-essential libgcrypt-dev libldap2-dev doxygen \
  openssl net-tools nmap \
  sqlite3 \
  rsync \
  ruby \
  make \
  man-db \
  manpages \
  manpages-dev \
  mime-support \
  ndiff \
  net-tools \
  netbase \
  nikto \
  nmap &&\
  rm -rf /var/lib/apt/lists/*

RUN mkdir /openvas-src && \

    # Building openvas-libraries
    cd /openvas-src && \
    wget -nv http://wald.intevation.org/frs/download.php/file/2420/openvas-libraries-${OPENVAS_LIBRARIES_VERSION}.tar.gz && \
    tar zxvf openvas-libraries-${OPENVAS_LIBRARIES_VERSION}.tar.gz && \
    cd /openvas-src/openvas-libraries-${OPENVAS_LIBRARIES_VERSION} && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j $(nproc) && \
    make install && \
    make rebuild_cache && \

    # Building openvas-scanner
    cd /openvas-src && \
    wget -nv http://wald.intevation.org/frs/download.php/file/2436/openvas-scanner-${OPENVAS_LIBRARIES_VERSION}.tar.gz
    tar zxvf openvas-scanner-${OPENVAS_SCANNER_VERSION}.tar.gz && \
    cd /openvas-src/openvas-scanner-${OPENVAS_SCANNER_VERSION} && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j $(nproc) && \
    make install && \
    make rebuild_cache && \

    ldconfig

RUN ln -sf /proc/1/fd/1 /usr/local/var/log/openvas/openvassd.messages

EXPOSE 9391 9390 

COPY docker-entrypoint.sh /

VOLUME [ "/usr/local/var/lib/openvas", "/usr/local/var/cache/openvas" ]

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "--help" ]
