FROM mama-ng-run
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

ADD build/seed-identity-store-static /app/static

RUN $PIP_INSTALL seed-identity-store
