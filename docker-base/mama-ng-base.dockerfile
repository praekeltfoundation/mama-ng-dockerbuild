FROM debian:jessie

ENV APT_GET_INSTALL "apt-get install -qyy -o APT::Install-Recommends=false -o APT::Install-Suggests=false"

RUN apt-get update \
    && $APT_GET_INSTALL \
        ca-certificates \
        libffi6 \
        openssl \
    && rm -rf /var/lib/apt/lists/*

RUN set -x \
    && apt-get update \
    && $APT_GET_INSTALL bzip2 curl python \
    && rm -rf /var/lib/apt/lists/* \
    && curl -SL 'https://bootstrap.pypa.io/get-pip.py' | python \
    && apt-get purge -y --auto-remove bzip2 curl \
    && rm -rf ${HOME}/.cache/pip

RUN pip --no-cache-dir install virtualenv && \
    virtualenv /appenv
