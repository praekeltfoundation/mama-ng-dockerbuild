FROM mama-ng-base

ADD build/wheelhouse /wheelhouse

ENV PIP_INSTALL="pip install --no-index -f wheelhouse"
