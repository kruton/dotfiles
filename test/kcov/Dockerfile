FROM kcov/kcov:latest

ARG UID=1000
ARG GID=1000
ARG WORKDIR=/source

# renovate: datasource=github-releases depName=neovim/neovim
ARG NVIM_VERSION=v0.12.5

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install \
      -y --no-install-recommends \
      bash-completion \
      ca-certificates \
      curl \
      git \
      ncurses-bin \
      ncurses-term \
      vim \
      && \
    git config --system --add safe.directory '*' && \
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin && \
    case "$(dpkg --print-architecture)" in \
      amd64) nvim_arch="linux-x86_64" ;; \
      arm64) nvim_arch="linux-arm64" ;; \
      *) echo "Unsupported architecture for Neovim"; exit 1 ;; \
    esac && \
    curl -fsLS "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-${nvim_arch}.tar.gz" | \
      tar -xz -C /opt && \
    ln -s "/opt/nvim-${nvim_arch}/bin/nvim" /usr/local/bin/nvim && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd --gid "$GID" -r abc && \
    useradd --uid "$UID" --create-home --system --gid abc abc && \
    mkdir -p "$WORKDIR/coverage" && \
    chown -R abc:abc "$WORKDIR"

ENV HOME=/home/abc
USER abc

WORKDIR "$WORKDIR/coverage"
