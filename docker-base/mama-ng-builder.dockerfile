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

COPY scripts/create-volume-user.sh /
COPY scripts/build-application.sh /
CMD /create-volume-user.sh /build builder builder; \
    chown -R builder /appenv; \
    su -l builder -c "/build-application.sh"
