ARG FLAMENCO_VERSION=3.2
ARG BLENDER_VERSION=3.6
ARG BLENDER_VERSION_PATCH=3.6.5

ARG FLAMENCO_MIRROR_URL="https://flamenco.blender.org"
ARG BLENDER_MIRROR_URL="https://mirrors.ocf.berkeley.edu"

ARG FLAMENCO_DOWNLOAD_URL="${FLAMENCO_MIRROR_URL}/downloads/flamenco-${FLAMENCO_VERSION}-linux-amd64.tar.gz"
ARG BLENDER_DOWNLOAD_URL="${BLENDER_MIRROR_URL}/blender/release/Blender${BLENDER_VERSION}/blender-${BLENDER_VERSION_PATCH}-linux-x64.tar.xz"

FROM --platform=amd64 debian:bookworm-slim AS base-downloader
RUN apt-get update \
  && apt-get install -y \
  curl \
  tar \
  xz-utils \
  gzip \
  && rm -rf /var/lib/apt/lists/*

FROM base-downloader AS flamenco-downloader
WORKDIR /data/flamenco
ARG FLAMENCO_DOWNLOAD_URL
RUN curl -sSL "$FLAMENCO_DOWNLOAD_URL" | tar -xzv --strip-components=1
RUN  ls -la

FROM base-downloader AS blender-downloader
WORKDIR /data/blender
ARG BLENDER_DOWNLOAD_URL
RUN curl -sSL "$BLENDER_DOWNLOAD_URL" | tar -xJv --strip-components=1
RUN  ls -la

FROM --platform=amd64 debian:bookworm-slim AS base-runtime
RUN apt-get update \
  && apt-get install -y \
  xorg \
  xvfb \
  libxkbcommon0 \
  && rm -rf /var/lib/apt/lists/*
RUN ln -s /opt/blender/blender /usr/local/bin/blender
COPY --link --from=blender-downloader /data/blender /opt/blender

FROM base-runtime AS flamenco-manager
RUN ln -s /opt/flamenco/flamenco-manager /usr/local/bin/flamenco-manager
RUN ln -s /opt/flamenco/flamenco-manager.yaml /usr/local/bin/flamenco-manager.yaml
CMD ["flamenco-manager"]
COPY --link --from=flamenco-downloader /data/flamenco/flamenco-manager /opt/flamenco/
WORKDIR /workdir
COPY --link flamenco-manager.yaml .

FROM base-runtime AS flamenco-worker
RUN ln -s /opt/flamenco/flamenco-worker /usr/local/bin/flamenco-worker
CMD ["flamenco-worker"]
COPY --link --from=flamenco-downloader /data/flamenco/flamenco-worker /opt/flamenco/
COPY --link --from=flamenco-downloader /data/flamenco/tools/ /opt/flamenco/tools/
WORKDIR /workdir
