FROM mama-ng-run
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

RUN . /appenv/bin/activate && \
    $PIP_INSTALL vxfreeswitch
