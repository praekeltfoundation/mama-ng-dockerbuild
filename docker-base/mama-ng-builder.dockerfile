FROM mama-ng-base

RUN apt-get update \
    && $APT_GET_INSTALL \
        gcc \
        libffi-dev \
        libpq-dev \
        libssl-dev \
        npm \
        python-dev \
    && rm -rf /var/lib/apt/lists/*

VOLUME /build
VOLUME /mama-ng-control
VOLUME /mama-ng-contentstore

COPY scripts/build-application.sh /
CMD /build-application.sh
