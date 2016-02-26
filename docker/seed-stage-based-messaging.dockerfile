FROM mama-ng-run
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

ADD build/seed-stage-based-messaging-static /app/static

RUN $PIP_INSTALL seed-stage-based-messaging
