FROM mama-ng-run
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

ADD build/hellomama-registration-static /app/static

RUN $PIP_INSTALL hellomama-registration
