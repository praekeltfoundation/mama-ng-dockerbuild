FROM mama-ng-run
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

ADD build/mama-ng-control-static /app/static

RUN $PIP_INSTALL mama-ng-control
