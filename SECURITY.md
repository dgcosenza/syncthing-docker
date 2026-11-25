# Security policy

Maintainer: Daniel G. Cosenza from FNX Labs.

## Supported versions

Only the `latest` tag and the newest `<syncthing-version>` tag are supported.
The image is rebuilt daily from `debian:trixie-slim` with a full
`apt-get upgrade`, the latest Go toolchain on Debian 13, and patched Go
security dependencies.

## Reporting a vulnerability

Open a private security advisory at
<https://github.com/dgcosenza/syncthing-docker/security/advisories/new>.
Please do not open a public issue for an undisclosed vulnerability.

## What this repository covers

This repository owns the container packaging layer: the Dockerfile, entrypoint,
smoke tests, CI pipeline, and published tags. Vulnerabilities in Syncthing
itself should also be reported upstream via
<https://github.com/syncthing/syncthing/security>.

## Scanning and gates

* **Trivy:** the build fails on any fixable **CRITICAL** or **HIGH** finding
  across Debian OS packages and the compiled Syncthing Go binary. Full reports
  are retained for 90 days and SARIF results are uploaded to GitHub code
  scanning.
* **Grype:** runs as a blocking gate (`--only-fixed`, severity high/critical),
  with reports archived for 90 days.
* **SBOM:** an SPDX JSON software bill of materials is generated with Syft and
  archived for 90 days.
* **Privilege drop:** the entrypoint applies `PUID`, `PGID`, and `UMASK`/`UMASK_SET`,
  fixes `/config` ownership only where needed, and drops privileges via
  `setpriv --no-new-privs` so Syncthing never runs as root.

## Hardening recommendations

* Pin production deployments by `@sha256:<digest>`.
* Run with `security_opt: [no-new-privileges:true]`.
* Bind the Web UI port `8384` to loopback or a trusted management interface
  rather than `0.0.0.0`, and configure GUI authentication + HTTPS inside
  Syncthing settings.
* Protect your `/config` volume (`cert.pem`, `key.pem`, `config.xml` contain
  device identity keys and API credentials).
