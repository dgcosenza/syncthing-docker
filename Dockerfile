# syntax=docker/dockerfile:1.7

# ---------------------------------------------------------------------------
# Syncthing compiled from official Go source on Debian 13 (trixie-slim).
#
# Drop-in compatible with linuxserver/syncthing: same /config home and config
# directory, PUID/PGID (default 1000:1000), UMASK/UMASK_SET, TZ,
# STGUIADDRESS=0.0.0.0:8384, ports 8384/22000/21027, and /rest/noauth/health
# healthcheck. Also supports rootless + read-only rootfs execution when run
# with --user 1000:1000 --read-only --cap-drop ALL.
#
# Every version and base digest below is a documented default; CI overrides
# them on each run (see .github/workflows/daily.yml).
# ---------------------------------------------------------------------------

ARG GO_BASE=golang:1.27.4-trixie@sha256:430985542100b871e108ccc00e8dcc5eef08ca14ee5825e98ebf563d8ffec4ee
ARG DEBIAN_BASE=debian:trixie-slim@sha256:8aa5a7bf5a1955bddbe7d74fcdd0b91ab30e74362a8b73af672b0481b35b44a0
ARG GO_VERSION=1.27.4

ARG SYNCTHING_VERSION=v2.1.7
ARG GO_X_NET_VERSION=v0.63.0
ARG GO_X_CRYPTO_VERSION=v0.59.0
ARG GO_X_SYS_VERSION=v0.50.0
ARG SYNCTHING_UID=1000
ARG SYNCTHING_GID=1000

ARG IMAGE_CREATED=""
ARG IMAGE_REVISION=""
ARG IMAGE_SOURCE="https://github.com/dgcosenza/syncthing-docker"

# ---- Stage 1: compile Syncthing from official source with patched Go deps --
FROM ${GO_BASE} AS builder

ARG SYNCTHING_VERSION
ARG GO_X_NET_VERSION
ARG GO_X_CRYPTO_VERSION
ARG GO_X_SYS_VERSION
ARG TARGETOS
ARG TARGETARCH

ENV GOTOOLCHAIN=local
ENV GOFLAGS=-buildvcs=false

WORKDIR /src

# go run build.go executes Syncthing's local build script; Go security modules are pinned via build-args
# hadolint ignore=DL3062
RUN set -eux; \
    git clone --depth 1 --branch "${SYNCTHING_VERSION}" \
        https://github.com/syncthing/syncthing.git .; \
    go mod edit \
        -require="golang.org/x/net@${GO_X_NET_VERSION}" \
        -require="golang.org/x/crypto@${GO_X_CRYPTO_VERSION}" \
        -require="golang.org/x/sys@${GO_X_SYS_VERSION}"; \
    go mod tidy; \
    git config user.email "build@syncthing-docker.invalid" && \
    git config user.name "syncthing-docker build" && \
    git add -A && git commit -q -m "patch Go module dependencies" || true; \
    CGO_ENABLED=0 GOOS="${TARGETOS:-linux}" GOARCH="${TARGETARCH:-amd64}" \
        go run build.go -no-upgrade -version "${SYNCTHING_VERSION}" build syncthing; \
    ./syncthing --version

# ---- Stage 2: fully upgraded Debian 13 runtime OS layer --------------------
FROM ${DEBIAN_BASE} AS os-base

ARG SYNCTHING_UID
ARG SYNCTHING_GID

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y --no-install-recommends upgrade \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        tini \
        tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && groupadd --gid "${SYNCTHING_GID}" syncthing \
    && useradd --uid "${SYNCTHING_UID}" --gid syncthing \
        --home-dir /config --no-create-home --shell /usr/sbin/nologin syncthing \
    && install -d -o syncthing -g syncthing -m 0750 /config

# ---- Stage 3: clean multi-arch runtime image (zero base-upgrade waste) -----
FROM scratch

ARG GO_VERSION
ARG SYNCTHING_VERSION
ARG IMAGE_CREATED
ARG IMAGE_REVISION
ARG IMAGE_SOURCE

# hadolint ignore=DL3067
COPY --from=os-base / /
COPY --from=builder /src/syncthing /usr/local/bin/syncthing
COPY --from=builder /src/LICENSE /usr/share/doc/syncthing-notices/LICENSE
COPY --chmod=0755 docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    DEBIAN_FRONTEND=noninteractive \
    PUID=1000 \
    PGID=1000 \
    UMASK=022 \
    HOME=/config \
    STHOMEDIR=/config \
    STGUIADDRESS=0.0.0.0:8384

RUN /usr/local/bin/syncthing --version

LABEL org.opencontainers.image.title="Syncthing (Debian 13)" \
      org.opencontainers.image.description="Hardened, multi-arch Debian 13 (trixie-slim) build of Syncthing compiled from official Go source with patched dependencies, drop-in compatible with linuxserver/syncthing." \
      org.opencontainers.image.url="https://hub.docker.com/r/dgcosenza/syncthing" \
      org.opencontainers.image.source="${IMAGE_SOURCE}" \
      org.opencontainers.image.documentation="${IMAGE_SOURCE}#readme" \
      org.opencontainers.image.version="${SYNCTHING_VERSION}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.created="${IMAGE_CREATED}" \
      org.opencontainers.image.licenses="MPL-2.0 AND MIT" \
      org.opencontainers.image.vendor="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.authors="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.base.name="debian:trixie-slim" \
      io.github.dgcosenza.syncthing.upstream_version="${SYNCTHING_VERSION}" \
      io.github.dgcosenza.syncthing.go_version="${GO_VERSION}"

VOLUME ["/config"]
EXPOSE 8384/tcp 22000/tcp 22000/udp 21027/udp

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD ["sh", "-c", "curl -fsS http://127.0.0.1:8384/rest/noauth/health >/dev/null || exit 1"]

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
