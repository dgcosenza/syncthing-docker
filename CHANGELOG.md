# Changelog

Maintained by Daniel G. Cosenza from FNX Labs.

All notable changes to this image are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and image tags track
the upstream `syncthing/syncthing` release version.

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
