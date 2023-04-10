# 2023-04-10 00:10:08+00:00
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE 1
ENV DEBCONF_NOWARNINGS yes
ENV LANG C.UTF-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg dirmngr && \
    echo 'deb http://ppa.launchpad.net/hvr/ghc/ubuntu focal main' > /etc/apt/sources.list.d/ghc.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F6F88286 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ghc-8.6.5 ghc-8.6.5-prof ghc-8.6.5-dyn ghc-8.6.5-htmldocs cabal-install-2.4 \
        zlib1g-dev libtinfo-dev libsqlite3-0 libsqlite3-dev ca-certificates g++ git curl xz-utils make netbase && \
    sh -c 'curl -sSL https://get.haskellstack.org/ | sh' && \
    /usr/local/bin/stack config set system-ghc --global true && \
    /usr/local/bin/stack config set install-ghc --global false && \
    apt-get purge -y --auto-remove curl && \
    rm -rf /var/lib/apt/lists/*

ENV PATH /root/.cabal/bin:/root/.local/bin:/opt/cabal/2.4/bin:/opt/ghc/8.6.5/bin:$PATH

CMD ["ghci"]
