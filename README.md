# Syncthing for Debian 13 (trixie-slim)

[![Daily Syncthing image](https://github.com/dgcosenza/syncthing-docker/actions/workflows/daily.yml/badge.svg)](https://github.com/dgcosenza/syncthing-docker/actions/workflows/daily.yml)
[![Packaging License: MIT](https://img.shields.io/badge/packaging-MIT-blue.svg)](https://github.com/dgcosenza/syncthing-docker/blob/main/LICENSE)
[![Upstream License: MPL-2.0](https://img.shields.io/badge/upstream-MPL--2.0-green.svg)](https://github.com/syncthing/syncthing/blob/main/LICENSE)
[![Signed with Cosign](https://img.shields.io/badge/signed-cosign%20OIDC-blueviolet.svg)](#supply-chain-verification)
[![SLSA Level 3](https://img.shields.io/badge/SLSA-Level%203-brightgreen.svg)](#supply-chain-verification)
[![Architectures](https://img.shields.io/badge/arch-amd64%20%7C%20arm64-informational.svg)](#supported-architectures)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/dgcosenza/syncthing-docker/badge)](https://scorecard.dev/viewer/?uri=github.com/dgcosenza/syncthing-docker)
[![Docker Pulls](https://img.shields.io/docker/pulls/dgcosenza/syncthing)](https://hub.docker.com/r/dgcosenza/syncthing)
[![Docker Image Size](https://img.shields.io/docker/image-size/dgcosenza/syncthing/latest)](https://hub.docker.com/r/dgcosenza/syncthing)
[![Latest Release](https://img.shields.io/github/v/release/dgcosenza/syncthing-docker?label=version)](https://github.com/dgcosenza/syncthing-docker/releases)

A source-built, multi-arch, continuously rebuilt **Debian 13 (`trixie-slim`)** container image of [Syncthing](https://syncthing.net/), compiled with `-no-upgrade`, `CGO_ENABLED=0`, the latest Go toolchain, and patched Go security dependencies, maintained by **Daniel G. Cosenza from FNX Labs**.

- **Docker Hub:** [`dgcosenza/syncthing`](https://hub.docker.com/r/dgcosenza/syncthing)
- **GitHub Container Registry (GHCR):** [`ghcr.io/dgcosenza/syncthing`](https://github.com/dgcosenza/syncthing-docker/pkgs/container/syncthing) (identical signed multi-arch digest)
- **Source Repository:** [`dgcosenza/syncthing-docker`](https://github.com/dgcosenza/syncthing-docker)
- **Upstream Application:** [`syncthing/syncthing`](https://github.com/syncthing/syncthing) (`MPL-2.0`)

---

## Overview

`dgcosenza/syncthing` compiles official Syncthing Go source tags with refreshed security-sensitive Go modules (`golang.org/x/{net,crypto,sys}`) on **Debian 13 (`trixie-slim`)** for both `linux/amd64` and `linux/arm64`:

- **Drop-in replacement for `linuxserver/syncthing`:** Preserves `/config` (`cert.pem`, `key.pem`, `config.xml`, `index-v2/`), `PUID`/`PGID`, `UMASK`/`UMASK_SET`, `STGUIADDRESS=0.0.0.0:8384`, ports `8384`/`22000`/`21027`, and `/rest/noauth/health` — without s6-overlay overhead, using `tini` and `setpriv --no-new-privs`.
- **Rootless & read-only rootfs ready:** Verified natively on both architectures in both drop-in `PUID`/`PGID` mode and strict rootless mode (`--user 1000:1000 --read-only --cap-drop ALL --security-opt no-new-privileges:true`).
- **Hardened supply chain:** Hadolint + Gitleaks preflight, native multi-arch smoke tests, strict Dive efficiency gate (`>= 95%`, `<= 5%` wasted), Syft SPDX + CycloneDX SBOMs, Trivy + Grype (SBOM) zero-fixable High/Critical gates, Cosign keyless OIDC signatures & SBOM attestations, SLSA Build L3 provenance, dual-registry publishing, and signed GitHub Releases.

---

## Current Versions

<!-- versions:start -->
| Component | Resolved Version |
| --- | --- |
| Syncthing | `v2.1.7` |
| Go toolchain | `1.27.4` |
| Base OS | `Debian 13.8 (trixie-slim)` |
| Architectures | `linux/amd64, linux/arm64` |
| Compressed size (per arch) | `amd64: 52.8 MB, arm64: 52.1 MB` |
| Last verified build (UTC) | `2026-11-25` |
| Published multi-arch digest | `dgcosenza/syncthing@sha256:26f4d853f51b87be6c4955ccdcabf1c0dd61e24316b40b7fe7aafd6b0508755d` |
| GHCR mirror | `ghcr.io/dgcosenza/syncthing@sha256:26f4d853f51b87be6c4955ccdcabf1c0dd61e24316b40b7fe7aafd6b0508755d` |
| Supply chain | Cosign OIDC signed + SPDX & CycloneDX SBOM attestations + SLSA Build L3 provenance |
| Security gate (Trivy + Grype on SBOM) | **0 fixable findings of any severity** (15 upstream-unfixed) |

Currently tracked upstream-unfixed findings (no fix released): `CVE-2025-69720`, `CVE-2026-107494`, `CVE-2026-119373`, `CVE-2026-119374`, `CVE-2026-119379`, `CVE-2026-12064`, `CVE-2026-124709`, `CVE-2026-16742`, `CVE-2026-54369`, `CVE-2026-76642` (+5 more in CI artifacts).
<!-- versions:end -->

---

## Supported Tags & Tag Policy

Identical multi-arch OCI digests are published to **Docker Hub** (`dgcosenza/syncthing`) and **GHCR** (`ghcr.io/dgcosenza/syncthing`), accompanied by an automated signed [GitHub Release](https://github.com/dgcosenza/syncthing-docker/releases):

| Tag | Policy | Description |
| --- | --- | --- |
| `<version>-<YYYYMMDD>` (e.g. `2.1.7-20261125`) | **Immutable** | Date-stamped daily rebuild pinning the Syncthing release and UTC build date. |
| `sha-<short>` | **Immutable** | Packaging repository Git commit tag. |
| `<version>` (e.g. `2.1.7`) | Moving | Latest verified Debian 13 + patched Go rebuild of that Syncthing release. |
| `latest` | Moving | Latest verified build tracking the newest official Syncthing release. |

**Production pinning:** Pin by immutable digest:

```yaml
image: dgcosenza/syncthing:2.1.7@sha256:<digest>
# or via GitHub Container Registry (identical digest):
image: ghcr.io/dgcosenza/syncthing:2.1.7@sha256:<digest>
```

---

## Supported Architectures

| Architecture | Status | Verification |
| --- | --- | --- |
| `linux/amd64` | **Published & natively tested** | Compiled with latest Go `trixie` + patched `x/*` modules, smoke-tested (both drop-in and `--user 1000:1000 --read-only --cap-drop ALL`), Dive-gated, Syft/Trivy/Grype-scanned, and Cosign-signed on native x86_64 CI runners. |
| `linux/arm64` | **Published & natively tested** | Compiled with latest Go `trixie` + patched `x/*` modules, smoke-tested (both drop-in and `--user 1000:1000 --read-only --cap-drop ALL`), Dive-gated, Syft/Trivy/Grype-scanned, and Cosign-signed on native ARM64 CI runners. |

---

## Quick Start

### `docker run` (hardened, rootless, read-only)

```bash
docker run -d --name syncthing \
  --restart unless-stopped \
  --user 1000:1000 \
  --read-only \
  --cap-drop ALL \
  --security-opt no-new-privileges:true \
  --tmpfs /tmp:noexec,nosuid,size=32m \
  -e TZ=Etc/UTC \
  -e UMASK_SET=022 \
  -p 127.0.0.1:8384:8384/tcp \
  -p 22000:22000/tcp \
  -p 22000:22000/udp \
  -p 21027:21027/udp \
  -v ./config:/config \
  dgcosenza/syncthing:latest
```

Verify health:

```bash
curl -fsS http://127.0.0.1:8384/rest/noauth/health
```

### Hardened Docker Compose

See [`docker-compose.example.yml`](https://github.com/dgcosenza/syncthing-docker/blob/main/docker-compose.example.yml) for a hardened compose example running rootless (`user: "1000:1000"`) with `read_only: true`, `cap_drop: [ALL]`, `no-new-privileges:true`, `/tmp` `tmpfs`, and resource limits. (When migrating a host directory with mixed ownership from `linuxserver/syncthing`, omit `user:` and `cap_drop: [ALL]` so the entrypoint repairs ownership and drops to `PUID:PGID` via `setpriv`.)

---

## Configuration

### Ports & Volumes

| Resource | Details | Purpose |
| --- | --- | --- |
| `8384/tcp` | Web GUI / REST API | Bind to loopback or a management IP (`192.0.2.10`) where possible |
| `22000/tcp` & `22000/udp` | Sync protocol | TCP and QUIC peer sync |
| `21027/udp` | Discovery | Local LAN discovery broadcasts |
| `/config` | Persistent volume | `config.xml`, device identity (`cert.pem`/`key.pem`), TLS keys, `index-v2/` |
| `/data` *(optional)* | Persistent volume | Additional synced folders |

### Environment Variables

| Variable | Default | Description |
| --- | --- | --- |
| `PUID` / `PGID` | `1000` / `1000` | Numeric user/group IDs Syncthing drops privileges to when started as root |
| `UMASK` / `UMASK_SET` | `022` | File creation mask (`UMASK_SET` takes precedence for `linuxserver/syncthing` parity) |
| `TZ` | `UTC` | Container timezone |
| `HOME` / `STHOMEDIR` | `/config` | Syncthing state/config directory |
| `STGUIADDRESS` | `0.0.0.0:8384` | Web GUI bind address inside the container |
| `SKIP_CHOWN` | *(unset)* | Set to `1` to skip startup ownership repair on `/config` |

---

## Healthcheck

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD ["sh", "-c", "curl -fsS http://127.0.0.1:8384/rest/noauth/health >/dev/null || exit 1"]
```

Probes `/rest/noauth/health` directly and fails closed when Syncthing stops.

---

## Upgrading and Migrating from `linuxserver/syncthing`

1. **Back up `/config`** (`config.xml`, `cert.pem`, `key.pem`, `https-*.pem`, `index-v2/`) before making changes. Never share or expose `key.pem` or `config.xml`.
2. Replace `linuxserver/syncthing:latest` with `dgcosenza/syncthing:<version>@sha256:<digest>` (or `ghcr.io/dgcosenza/syncthing:<version>@sha256:<digest>`).
3. Keep your existing `PUID`, `PGID`, `TZ`, `UMASK_SET`, `/config`, data mounts, and port mappings.
4. Recreate the container (`docker compose up -d syncthing`), confirm `healthy` status, and verify your Device ID and folders remain unchanged.

---

## Supply-Chain Verification

Every published digest (multi-arch index and per-architecture manifests) on both Docker Hub and GHCR is keyless-signed with **Sigstore Cosign** (GitHub OIDC), attested with **SPDX** and **CycloneDX** SBOMs, and backed by **SLSA Build L3** provenance (`actions/attest-build-provenance`).

### Verify image signature with Cosign

```bash
cosign verify \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/syncthing-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/dgcosenza/syncthing:latest

# Or against Docker Hub (identical digest):
cosign verify \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/syncthing-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  dgcosenza/syncthing:latest
```

### Verify SPDX / CycloneDX SBOM attestations

```bash
cosign verify-attestation \
  --type spdxjson \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/syncthing-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/dgcosenza/syncthing@sha256:<arch-digest>
```

### Verify SLSA Build Provenance

```bash
gh attestation verify oci://ghcr.io/dgcosenza/syncthing:latest --owner dgcosenza
```

---

## Security

- **Preflight gates:** Every push and PR runs **Hadolint** (blocking on warning+), **Gitleaks** secret scanning across git history, and **public-content/attribution/license** checks.
- **Patched Go binary:** Compiled daily from official upstream tags with `CGO_ENABLED=0`, `-no-upgrade`, the latest Go `trixie` toolchain (`GOTOOLCHAIN=local`), and updated `golang.org/x/{net,crypto,sys}` modules (eliminating binary CVEs such as `CVE-2026-78661`).
- **Rootless & read-only ready:** Supports both `setpriv --no-new-privs` privilege drop and direct `--user 1000:1000 --read-only --cap-drop ALL` execution.
- **Vulnerability & efficiency gates (all severities with a fix):** Each architecture generates **Syft** SPDX + CycloneDX SBOMs, passes a strict **Dive** efficiency gate (`>= 95%`, `<= 5%` wasted), and must pass **Trivy** (table, JSON, SARIF to Code Scanning, blocking `--ignore-unfixed`) and **Grype** scanning the SPDX SBOM (`--only-fixed --fail-on negligible`) with **0 fixable findings of any severity** vulnerabilities.
- **Dependency automation:** Renovate (`renovate.json`) pins base image digests and GitHub Action commit SHAs; Dependabot security alerts and OpenSSF Scorecard monitoring are enabled.
- See [`SECURITY.md`](https://github.com/dgcosenza/syncthing-docker/blob/main/SECURITY.md) for vulnerability reporting.

---

## Build Locally

```bash
git clone https://github.com/dgcosenza/syncthing-docker.git
cd syncthing-docker

docker buildx build \
  --platform linux/amd64 \
  --load \
  --build-arg IMAGE_CREATED="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --build-arg IMAGE_REVISION="$(git rev-parse HEAD)" \
  -t dgcosenza/syncthing:local \
  .

./tests/smoke.sh dgcosenza/syncthing:local
```

| Build Arg | Default | Purpose |
| --- | --- | --- |
| `GO_BASE` | `golang:1.27.4-trixie@sha256:...` | Digest-pinned official Go builder image (refreshed daily by CI) |
| `DEBIAN_BASE` | `debian:trixie-slim@sha256:...` | Digest-pinned Debian 13 runtime base image (refreshed daily by CI) |
| `GO_VERSION` | `1.27.4` | Go toolchain version metadata |
| `SYNCTHING_VERSION` | `v2.1.7` | `syncthing/syncthing` Git tag |
| `SYNCTHING_UID` / `SYNCTHING_GID` | `1000` / `1000` | Default `syncthing` account IDs |

---

## Update Policy

[`.github/workflows/daily.yml`](https://github.com/dgcosenza/syncthing-docker/blob/main/.github/workflows/daily.yml) runs automatically every day at **05:50 UTC**, on pushes to `main`, on pull requests (verification only), and via `workflow_dispatch`:

1. **Preflight & upstream check:** Runs public-content checks, **Hadolint**, and **Gitleaks**; resolves the latest `syncthing/syncthing` release via authenticated GitHub API plus latest Go `trixie` and `debian:trixie-slim` digests; diffs against `versions.json` and emits `upstream-changes.md`.
2. **Multi-arch no-cache rebuild:** Refreshes `golang.org/x/{net,crypto,sys}`, compiles Syncthing (`-no-upgrade`, `CGO_ENABLED=0`) natively on `linux/amd64` and `linux/arm64` runners with `--no-cache` on schedule and full Debian 13 `apt-get upgrade`.
3. **Smoke, Dive & vulnerability gates:** Runs [`tests/smoke.sh`](https://github.com/dgcosenza/syncthing-docker/blob/main/tests/smoke.sh) natively on both architectures (drop-in `PUID`/`PGID` + strict `--user 1000:1000 --read-only --cap-drop ALL`), enforces the strict **Dive** efficiency gate (`>= 95%`, `<= 5%` wasted), generates **Syft** SPDX + CycloneDX SBOMs, and gates publication on **0 fixable findings of any severity** in both **Trivy** and **Grype** (SBOM scan).
4. **Dual-registry publish & signing:** Assembles the multi-arch OCI index on **GHCR** (`ghcr.io/dgcosenza/syncthing`) and mirrors the identical digest to **Docker Hub** (`dgcosenza/syncthing`) with tags `latest`, `<version>`, `<version>-<YYYYMMDD>`, and `sha-<short>`; keyless-signs digests and attaches SPDX/CycloneDX SBOM attestations via **Cosign** OIDC; emits **SLSA Build L3** provenance; and publishes a signed **GitHub Release**.
5. **Automated documentation sync:** Commits updated `versions.json`, the README `Current Versions` block, and a dated `CHANGELOG.md` entry via `github-actions[bot]` (`[skip ci]`), then syncs the Docker Hub overview and short description.
6. **Failure alerting:** Opens or updates a single GitHub issue labeled `ci-failure` on any `main` or scheduled failure, and closes it automatically on the next green run.

---

## Design Decisions

- **Source build with refreshed Go security dependencies:** Upstream prebuilt tarballs can ship lagged `golang.org/x/*` dependencies; rebuilding from official release tags clears binary CVEs immediately.
- **Debian 13 (`trixie-slim`) + `tini` + `setpriv` instead of Alpine + s6-overlay:** Preserves full `linuxserver/syncthing` parity with a concise, auditable POSIX entrypoint while supporting strict rootless read-only operation.
- **Two-layer zero-waste runtime layout:** Upgrading Debian 13 inside an `os-base` stage and assembling the final image with cleanly separated OS and compiled-binary layers eliminates overwritten base-layer files so Dive remains at ~100% efficiency and ~0% wasted space across daily security rebuilds.
- **Built with `-no-upgrade`:** Disables in-container self-upgrades so all updates flow through immutable signed images.
- **Hadolint `DL3008` ignore:** Daily `--no-cache` security rebuilds intentionally pull the newest Debian 13 security updates via `apt-get` rather than pinning stale package versions.

---

## License

This repository follows a clear packaging-vs-upstream license split:

- **Container packaging, entrypoint, CI workflows, scripts, and documentation (`packaging: MIT`):** Licensed under the [MIT License](https://github.com/dgcosenza/syncthing-docker/blob/main/LICENSE) — copyright **Daniel G. Cosenza from FNX Labs**.
- **Bundled upstream software — Syncthing (`upstream: MPL-2.0`):** Copyright The Syncthing Authors — licensed under the [Mozilla Public License 2.0 (`MPL-2.0`)](https://github.com/syncthing/syncthing/blob/main/LICENSE).

Full notices are preserved inside the image (`/usr/share/doc/syncthing-notices/LICENSE`) and in [`THIRD-PARTY-NOTICES.md`](https://github.com/dgcosenza/syncthing-docker/blob/main/THIRD-PARTY-NOTICES.md).

---

## Credits

- [The Syncthing Project](https://github.com/syncthing/syncthing)
- [LinuxServer.io](https://github.com/linuxserver/docker-syncthing) — `/config` and `PUID`/`PGID` conventions preserved for drop-in migration
- Container packaging, CI, and documentation: maintained by **Daniel G. Cosenza from FNX Labs** ([dgcosenza](https://github.com/dgcosenza))
