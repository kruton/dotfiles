FROM kcov/kcov:38

ARG UID=1000
ARG GID=1000
ARG WORKDIR=/source

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install \
      -y --no-install-recommends \
      bash-completion \
      fish \
      ;

RUN groupadd --gid "$GID" -r abc && \
    useradd --uid "$UID" --create-home --system --gid abc abc && \
    mkdir -p "$WORKDIR/coverage" && \
    chown -R abc:abc "$WORKDIR"

USER abc

WORKDIR "$WORKDIR/coverage"
