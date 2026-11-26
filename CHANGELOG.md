# Changelog

Maintained by Daniel G. Cosenza from FNX Labs.

All notable changes to this image are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and image tags track
the upstream `syncthing/syncthing` release version.

## [2.1.7] - 2026-11-26

### Automated Daily Build
- Verified components: Syncthing `v2.1.7`, Go toolchain `1.27.4`, Base OS `Debian 13.8 (trixie-slim)`.
- Architectures verified: `linux/amd64, linux/arm64` (native smoke tests + Dive efficiency gate).
- Upstream status: refreshed base OS, dependencies, and supply-chain attestations.
- Vulnerability gate: **0 fixable findings of any severity** in Trivy and Grype (SBOM scan) (15 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/syncthing@sha256:6cf676329c1bc1d20d91a35e6c6750f7c71908b824ffbc568650a0a2d22c4b0d` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).
## [2.1.7] - 2026-11-25

### Automated Daily Build
- Verified components: Syncthing `v2.1.7`, Go toolchain `1.27.4`, Base OS `Debian 13.8 (trixie-slim)`.
- Architectures verified: `linux/amd64, linux/arm64` (native smoke tests + Dive efficiency gate).
- Upstream status: refreshed base OS, dependencies, and supply-chain attestations.
- Vulnerability gate: **0 fixable Critical/High** in Trivy and Grype (SBOM scan) (15 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/syncthing@sha256:26f4d853f51b87be6c4955ccdcabf1c0dd61e24316b40b7fe7aafd6b0508755d` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).
## [2.1.7] - 2026-11-25

### Changed

- Rebuilt on Debian `13.8` (`debian:trixie-slim`) with syncthing `v2.1.7`, go `1.27.4`.
- Verified `0` fixable CRITICAL/HIGH vulnerabilities in Trivy and Grype.
- Published digest: `dgcosenza/syncthing@sha256:6e6f2c06a30eb05d78de7e03e7059b837070c7d4c6f5ffdc939de44969dfe12c`.
## [2.1.7] - 2026-11-24

### Added

- Initial public build: Syncthing `v2.1.7` compiled from official Go source
  (`CGO_ENABLED=0`, `-no-upgrade`) on Debian 13 (trixie) slim with refreshed
  Go security dependencies (resolving `CVE-2026-78661` in `golang.org/x/net`).
- Drop-in compatibility with `linuxserver/syncthing`: `/config` home and
  configuration directory, `PUID`/`PGID` (default `1000:1000`),
  `UMASK`/`UMASK_SET`, `TZ`, `STGUIADDRESS=0.0.0.0:8384`, ports `8384/tcp`,
  `22000/tcp+udp`, `21027/udp`, and `/rest/noauth/health` healthcheck.
- `tini` as PID 1 and pure-C `setpriv --no-new-privs` privilege drop.
- Automated 7-step daily CI pipeline: upstream release and Go toolchain check,
  clean `--no-cache` build, Trivy and Grype blocking gates, SPDX SBOM,
  functional and negative smoke tests, Docker Hub publishing, automated
  README/CHANGELOG sync, and failure alerting.
