FROM mama-ng-base

ENV PATH="/appenv/bin:$PATH"
RUN . /appenv/bin/activate

ADD build/wheelhouse /wheelhouse

ENV PIP_INSTALL="pip install --no-index -f wheelhouse"
