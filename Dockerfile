# 'Version: 7.92'

FROM alpine:latest
RUN apk update && apk upgrade && \
    apk add --no-cache \
    pcre \
    lua5.3-libs \
    openssl-dev \
    openssl \
    libressl-dev \
    libressl \
    libssl1.1 \
    libssh-dev \
    libssh2-dev \
    libssh2-dbg \
    openssh \
    libssh2-static \
    libssh \
    libssh2 \
    lua \
    lua-ossl \
    g++ \
    flex \
    libpcap \
    bison \
    make \
    git \
    gcc \
    linux-headers \
    musl-dev \
    zlib-dev \
    zlib \
    zlib-static \
    autoconf 

RUN apk search openssl && apk add openssl-d-dev || echo "Could not add openssl-d-dev attempting to continue despite this."

RUN rm -f /var/cache/apk/*

RUN wget "https://nmap.org/dist/nmap-7.92.tgz"

RUN tar -zxvf ./nmap* && \
    rm -rf './nmap*.tgz' && \
    chmod 755 -R ./nmap* && \
    mv ./nmap*/ /usr/share/nmap && \
    export PATH=$PATH:/usr/share/nmap

RUN cd /usr/share/nmap && ./configure && make && make install && make check && /usr/share/nmap/nmap --script-updatedb

FROM scratch
COPY --from=0 /usr/share/nmap/nmap /usr/bin/nmap
COPY --from=0 /etc/hosts /etc/hosts
COPY --from=0 /etc/passwd /etc/passwd
COPY --from=0 /etc/group /etc/group
COPY --from=0 /etc/ssl/openssl.cnf /etc/ssl/openssl.cnf
COPY --from=0 /usr/local/share/nmap/ /usr/local/share/nmap/
COPY --from=0 /usr/share/nmap /usr/share/nmap 
COPY --from=0 /usr/lib/ /usr/lib/
COPY --from=0 /lib/ /lib/

ENTRYPOINT ["/usr/bin/nmap"]
