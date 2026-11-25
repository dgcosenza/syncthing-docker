# syntax=docker/dockerfile:1

# ---------------------------------------------------------------------------
# Syncthing compiled from official Go source on Debian 13 (trixie) slim.
#
# Drop-in compatible with linuxserver/syncthing: same /config home and config
# directory, PUID/PGID (default 1000:1000), UMASK/UMASK_SET, TZ,
# STGUIADDRESS=0.0.0.0:8384, ports 8384/22000/21027, and /rest/noauth/health
# healthcheck.
#
# Every version below is a documented default; CI overrides them with the
# latest upstream Syncthing release and Go toolchain (.github/workflows/daily.yml).
# ---------------------------------------------------------------------------

ARG GO_VERSION=1.27.4
ARG DEBIAN_VERSION=trixie-slim

ARG SYNCTHING_VERSION=v2.1.7
ARG SYNCTHING_UID=1000
ARG SYNCTHING_GID=1000

ARG IMAGE_CREATED=""
ARG IMAGE_REVISION=""
ARG IMAGE_SOURCE="https://github.com/dgcosenza/syncthing-docker"

# ---- Stage 1: compile Syncthing from official source with patched Go deps --
FROM golang:${GO_VERSION}-trixie AS builder

ARG SYNCTHING_VERSION
ARG TARGETOS=linux
ARG TARGETARCH=amd64

WORKDIR /src

RUN git clone --depth 1 --branch "${SYNCTHING_VERSION}" \
    https://github.com/syncthing/syncthing.git .

# Refresh Go security-sensitive x/* modules (resolving CVEs such as
# CVE-2026-78661 in golang.org/x/net) before building the static binary.
RUN set -eux; \
    go get golang.org/x/net@latest golang.org/x/crypto@latest golang.org/x/sys@latest; \
    go mod tidy; \
    CGO_ENABLED=0 GOOS="${TARGETOS}" GOARCH="${TARGETARCH}" \
        go run build.go -no-upgrade -version "${SYNCTHING_VERSION}" build syncthing; \
    ./syncthing --version

# ---- Stage 2: hardened Debian 13 runtime -----------------------------------
FROM debian:${DEBIAN_VERSION}

ARG DEBIAN_VERSION
ARG GO_VERSION
ARG SYNCTHING_VERSION
ARG SYNCTHING_UID
ARG SYNCTHING_GID
ARG IMAGE_CREATED
ARG IMAGE_REVISION
ARG IMAGE_SOURCE

LABEL org.opencontainers.image.title="Syncthing (Debian 13)" \
      org.opencontainers.image.description="Hardened, up-to-date Debian 13 (trixie) build of Syncthing compiled from official Go source with patched dependencies, drop-in compatible with linuxserver/syncthing." \
      org.opencontainers.image.url="https://hub.docker.com/r/dgcosenza/syncthing" \
      org.opencontainers.image.source="${IMAGE_SOURCE}" \
      org.opencontainers.image.documentation="${IMAGE_SOURCE}#readme" \
      org.opencontainers.image.version="${SYNCTHING_VERSION}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.created="${IMAGE_CREATED}" \
      org.opencontainers.image.licenses="MPL-2.0" \
      org.opencontainers.image.vendor="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.authors="Daniel G. Cosenza from FNX Labs" \
      io.github.dgcosenza.syncthing.upstream_version="${SYNCTHING_VERSION}" \
      io.github.dgcosenza.syncthing.go_version="${GO_VERSION}" \
      io.github.dgcosenza.syncthing.base="debian:${DEBIAN_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive \
    PUID=1000 \
    PGID=1000 \
    UMASK=022 \
    HOME=/config \
    STHOMEDIR=/config \
    STGUIADDRESS=0.0.0.0:8384

RUN apt-get update \
    && apt-get -y --no-install-recommends upgrade \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        tini \
        tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Default service account (1000:1000, overridden at runtime via PUID/PGID).
RUN groupadd --gid "${SYNCTHING_GID}" syncthing \
    && useradd --uid "${SYNCTHING_UID}" --gid syncthing \
        --home-dir /config --no-create-home --shell /usr/sbin/nologin syncthing \
    && install -d -o syncthing -g syncthing -m 0750 /config

COPY --from=builder /src/syncthing /usr/local/bin/syncthing
COPY --from=builder /src/LICENSE /usr/share/doc/syncthing-notices/LICENSE
COPY --chmod=0755 docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN /usr/local/bin/syncthing --version

VOLUME ["/config"]
EXPOSE 8384/tcp 22000/tcp 22000/udp 21027/udp

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD ["sh", "-c", "curl -fsS http://127.0.0.1:8384/rest/noauth/health >/dev/null || exit 1"]

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
