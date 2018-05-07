# 2018-05-07 11:40:38+00:00
FROM debian:stretch

ENV LANG C.UTF-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg dirmngr && \
    echo 'deb http://ppa.launchpad.net/hvr/ghc/ubuntu xenial main' > /etc/apt/sources.list.d/ghc.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F6F88286 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ghc-8.4.2 alex-3.1.7 cabal-install-2.2 happy-1.19.5 \
        zlib1g-dev libtinfo-dev libsqlite3-0 libsqlite3-dev ca-certificates g++ git curl xz-utils make

RUN curl -sSL https://get.haskellstack.org/ | sh

RUN /usr/local/bin/stack config set system-ghc --global true && \
    apt-get purge -y --auto-remove curl && \
    rm -rf /var/lib/apt/lists/*

ENV PATH /root/.cabal/bin:/root/.local/bin:/opt/cabal/2.2/bin:/opt/ghc/8.4.2/bin:/opt/happy/1.19.5/bin:/opt/alex/3.1.7/bin:$PATH

CMD ["ghci"]
