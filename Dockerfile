# 2020-03-09 00:01:19+00:00
FROM ubuntu:18.04

ENV LANG C.UTF-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg dirmngr && \
    echo 'deb http://ppa.launchpad.net/hvr/ghc/ubuntu bionic main' > /etc/apt/sources.list.d/ghc.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F6F88286 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ghc-8.8.3 ghc-8.8.3-prof ghc-8.8.3-dyn ghc-8.8.3-htmldocs alex-3.1.7 cabal-install-3.2 happy-1.19.5 \
        zlib1g-dev libtinfo-dev libsqlite3-0 libsqlite3-dev ca-certificates g++ git curl xz-utils make netbase && \
    sh -c 'curl -sSL https://get.haskellstack.org/ | sh' && \
    /usr/local/bin/stack config set system-ghc --global true && \
    apt-get purge -y --auto-remove curl && \
    rm -rf /var/lib/apt/lists/*

ENV PATH /root/.cabal/bin:/root/.local/bin:/opt/cabal/3.2/bin:/opt/ghc/8.8.3/bin:/opt/happy/1.19.5/bin:/opt/alex/3.1.7/bin:$PATH

CMD ["ghci"]
