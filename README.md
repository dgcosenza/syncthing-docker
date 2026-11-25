# Syncthing for Debian 13 (trixie)

[![Daily build, scan and publish](https://github.com/dgcosenza/syncthing-docker/actions/workflows/daily.yml/badge.svg)](https://github.com/dgcosenza/syncthing-docker/actions/workflows/daily.yml)
[![Docker Hub pulls](https://img.shields.io/docker/pulls/dgcosenza/syncthing.svg)](https://hub.docker.com/r/dgcosenza/syncthing)
[![Image size](https://img.shields.io/docker/image-size/dgcosenza/syncthing/latest.svg)](https://hub.docker.com/r/dgcosenza/syncthing)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A hardened, continuously rebuilt **Debian 13 (trixie)** container image of
[Syncthing](https://syncthing.net/), compiled directly from official Go source
tags (`-no-upgrade`, `CGO_ENABLED=0`) with the latest Go toolchain and patched
Go security dependencies (`golang.org/x/net`, `x/crypto`, `x/sys`).

It is a **drop-in replacement** for `linuxserver/syncthing`: same `/config`
configuration and identity directory (`cert.pem`, `key.pem`, `config.xml`,
`index-v2/`), same `PUID`/`PGID` and `UMASK`/`UMASK_SET` conventions, same
`STGUIADDRESS=0.0.0.0:8384`, same sync and discovery ports, and the same
`/rest/noauth/health` healthcheck — built on Debian 13 slim without s6-overlay
overhead, using `tini` and `setpriv --no-new-privs`.

## Current versions

<!-- versions:start -->

| Component | Resolved version |
|---|---|
| Base OS | Debian `13` (`debian:trixie-slim`) |
| `syncthing` | `v2.1.7` |
| `go` | `1.27.4` |
| Last verified build | `2026-11-24` |
| Fixable CRITICAL / HIGH CVEs | `0` (Trivy + Grype gate) |

<!-- versions:end -->

## Supported tags

| Tag | Meaning |
|---|---|
| `latest` | Newest successfully built, tested, and scanned image |
| `<version>` | Upstream Syncthing release, e.g. `2.1.7` (moves on daily rebuilds of that release) |
| `<version>-<YYYYMMDD>` | Immutable date-stamped build of that release |
| `sha-<short>` | Immutable build of a specific repository commit |

Pin production deployments by digest:

```bash
docker pull dgcosenza/syncthing:latest
docker inspect --format='{{index .RepoDigests 0}}' dgcosenza/syncthing:latest
# image: dgcosenza/syncthing@sha256:...
```

## Quick start

```bash
docker run -d --name syncthing \
  --restart unless-stopped \
  --security-opt no-new-privileges:true \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=UTC \
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

## Compose example

See [docker-compose.example.yml](docker-compose.example.yml) for a
production-style compose file with `PUID`/`PGID`, `UMASK_SET`,
`no-new-privileges:true`, resource limits, and healthcheck.

## Configuration

### Ports

| Port | Protocol | Purpose |
|---|---|---|
| `8384` | TCP | Web GUI and REST API (bind to loopback or a management IP where possible) |
| `22000` | TCP / UDP | Syncthing file transfer protocol (TCP and QUIC) |
| `21027` | UDP | Local LAN discovery broadcasts |

### Volumes

| Path | Purpose |
|---|---|
| `/config` | Syncthing configuration (`config.xml`), device identity keys (`cert.pem`, `key.pem`), GUI TLS material, and index database (`index-v2/`) |
| `/data` *(or custom mounts)* | Any additional host directories mounted for synced folders |

### Environment variables

| Variable | Default | Description |
|---|---|---|
| `PUID` | `1000` | Numeric user ID Syncthing drops privileges to |
| `PGID` | `1000` | Numeric group ID Syncthing drops privileges to |
| `UMASK` / `UMASK_SET` | `022` | File creation mask applied before starting Syncthing (`UMASK_SET` takes precedence when set for `linuxserver/syncthing` parity) |
| `TZ` | `UTC` | Container timezone |
| `HOME` / `STHOMEDIR` | `/config` | Syncthing configuration and state directory |
| `STGUIADDRESS` | `0.0.0.0:8384` | Web GUI bind address inside the container |
| `SKIP_CHOWN` | *(unset)* | Set to `1` to skip automatic ownership repair on `/config` at startup |

### UID / GID

At startup the entrypoint ensures files under `/config` whose ownership differs
from `PUID:PGID` are chowned to `PUID:PGID` (skipping files that already match),
then execs Syncthing via `setpriv --reuid=$PUID --regid=$PGID --clear-groups --no-new-privs`.
Syncthing itself never runs as root. You can also launch the container directly
with `--user <uid>:<gid>` if `/config` is already owned by that user.

## Healthcheck

```text
sh -c "curl -fsS http://127.0.0.1:8384/rest/noauth/health >/dev/null || exit 1"
```

Matches the standard `/rest/noauth/health` probe (30 s interval, 10 s timeout,
60 s start period, 3 retries) and fails closed if Syncthing stops.

## Upgrading and migrating from `linuxserver/syncthing`

1. **Back up `/config`** (`config.xml`, `cert.pem`, `key.pem`, `https-*.pem`,
   and `index-v2/`) before making changes. Never share or expose `key.pem` or
   `config.xml`.
2. Replace `linuxserver/syncthing:latest` in your compose file with
   `dgcosenza/syncthing:<version>@sha256:<digest>`.
3. Keep the exact same `PUID`, `PGID`, `TZ`, `UMASK_SET`, `/config` mount,
   data folder mounts, and port bindings.
4. Recreate the container (`docker compose up -d syncthing`), confirm `healthy`
   status, and verify your existing Device ID and synced folders appear
   unchanged in the GUI.

Rollback is immediate: restore the previous `linuxserver/syncthing` digest in
your compose file and run `docker compose up -d syncthing`.

## Security

* **Base OS:** `debian:trixie-slim`, fully upgraded (`apt-get upgrade`) on
  every build with `--no-install-recommends` and cleaned APT lists.
* **Patched Go binary:** Built daily from the official upstream Syncthing tag
  with `CGO_ENABLED=0`, `-no-upgrade`, the latest Go toolchain on Debian 13,
  and updated `golang.org/x/{net,crypto,sys}` modules (fixing upstream binary
  CVEs such as `CVE-2026-78661`).
* **Privilege drop & PID 1:** `tini` handles signal forwarding and zombie
  reaping; `setpriv --no-new-privs` drops to `PUID:PGID` before launching
  Syncthing.
* **Scan policy:** Every build must pass **Trivy** (`--ignore-unfixed`,
  `CRITICAL,HIGH`, scanning both OS packages and the Go binary) and **Grype**
  (`--only-fixed`, severity `high`) with **0 fixable CRITICAL or HIGH**
  vulnerabilities. Reports and a Syft SPDX SBOM are retained for 90 days; Trivy
  SARIF is uploaded to GitHub code scanning.
* **Current status:** see the CI badge above and "Current versions".

## Building locally

```bash
git clone https://github.com/dgcosenza/syncthing-docker.git
cd syncthing-docker
docker build -t dgcosenza/syncthing:dev .
./tests/smoke.sh dgcosenza/syncthing:dev
```

Build arguments:

| Argument | Default | Purpose |
|---|---|---|
| `DEBIAN_VERSION` | `trixie-slim` | Debian 13 base tag |
| `GO_VERSION` | tracked release | Official `golang:<ver>-trixie` builder toolchain |
| `SYNCTHING_VERSION` | tracked release | `syncthing/syncthing` Git tag |
| `SYNCTHING_UID` / `SYNCTHING_GID` | `1000` / `1000` | Default `syncthing` account IDs |
| `IMAGE_CREATED`, `IMAGE_REVISION`, `IMAGE_SOURCE` | empty / repo | OCI image metadata |

## Update policy

A GitHub Actions workflow (`.github/workflows/daily.yml`) runs **daily** (and on
every push to `main`, on pull requests, and on demand via `workflow_dispatch`),
gated first by `.github/workflows/public-check.yml`:

1. **Upstream check:** resolves the latest `syncthing/syncthing` release via
   the authenticated GitHub API (`GH_TOKEN`) and the newest Go `trixie` release
   from Docker Hub, diffs against `versions.json`, and fetches upstream release
   notes for new releases.
2. **Clean rebuild:** updates `golang.org/x/{net,crypto,sys}`, compiles
   Syncthing (`-no-upgrade`, `CGO_ENABLED=0`), and builds the Debian 13 slim
   runtime with `apt-get upgrade` and `--no-cache` on scheduled runs.
3. **Vulnerability fix and gate:** scans OS packages and the compiled Go binary
   with **Trivy** (table, JSON, SARIF to GitHub code scanning) and **Grype**;
   fails on any fixable **CRITICAL** or **HIGH** vulnerability, retains reports
   and an SPDX SBOM (Syft) for 90 days, and diffs findings against the prior
   build.
4. **Smoke test:** starts the container with `PUID=1000`/`PGID=1000`/`UMASK_SET=022`,
   waits for `healthy`, confirms Syncthing runs as uid `1000`, verifies
   `/rest/noauth/health` and `/config` identity file creation/ownership, and
   asserts healthcheck failure once stopped.
5. **Publish:** on non-PR runs with Docker Hub credentials configured, pushes
   `latest`, `<version>`, `<version>-<YYYYMMDD>` (immutable), and `sha-<short>`,
   recording the published digest.
6. **Automated documentation sync:** when versions, base OS, digest, or CVE
   status change, commits updated `versions.json`, the README "Current
   versions" block, and a dated `CHANGELOG.md` entry (`[skip ci]`), then syncs
   the README and short description to Docker Hub.
7. **Alerting:** on failure of any job on a scheduled or `main` run, opens or
   updates a single GitHub issue labeled `ci-failure` with the failing job and
   run link, and closes it automatically on the next green run.

## Design decisions

* **Built from source with patched Go modules instead of shipping the prebuilt
  tarball.** Upstream releases can lag behind `golang.org/x/*` security fixes
  (for example `CVE-2026-78661` in `golang.org/x/net`). Compiling from official
  source with refreshed security dependencies achieves 0 fixable CRITICAL/HIGH
  findings immediately.
* **Debian 13 slim + `tini` + `setpriv` instead of Alpine + s6-overlay.**
  Preserves full `linuxserver/syncthing` directory and environment-variable
  compatibility while keeping a minimal, auditable POSIX entrypoint on Debian 13.
* **Built with `-no-upgrade`.** In-container self-upgrades are disabled so all
  updates happen immutably through daily rebuilt and scanned container images.

## License

The packaging, entrypoint, workflow, and documentation in this repository are
licensed under the **MIT License** (see [LICENSE](LICENSE)).

Syncthing is licensed under the **Mozilla Public License 2.0 (`MPL-2.0`)**; the
upstream license file is preserved at `/usr/share/doc/syncthing-notices/LICENSE`
and summarized in [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).

## Credits

* [The Syncthing Project](https://github.com/syncthing/syncthing) — open-source
  continuous file synchronization
* [LinuxServer.io](https://github.com/linuxserver/docker-syncthing) — `/config`
  and `PUID`/`PGID` conventions preserved for drop-in migration
* Container packaging, CI, and documentation: maintained by Daniel G. Cosenza from FNX Labs ([dgcosenza](https://github.com/dgcosenza))
