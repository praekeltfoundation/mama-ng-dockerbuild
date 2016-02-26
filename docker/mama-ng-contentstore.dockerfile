FROM mama-ng-run
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

ADD build/mama-ng-contentstore-static /app/static

RUN $PIP_INSTALL mama-ng-contentstore
