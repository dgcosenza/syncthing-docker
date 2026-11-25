# Third-party notices

This image compiles and packages Syncthing from official upstream Go source.
The MIT license in `LICENSE` applies only to the container packaging,
entrypoint, CI workflow, and documentation maintained by Daniel G. Cosenza from FNX Labs.

| Component | Version | License | Source |
|---|---|---|---|
| Syncthing (`syncthing/syncthing`) | v2.1.7 | MPL-2.0 | https://github.com/syncthing/syncthing |
| Go standard library & module dependencies | resolved and patched at build time | BSD-3-Clause / Apache-2.0 / MIT (per `go.mod`) | https://go.dev/ |
| Debian 13 runtime packages | trixie | Debian Free Software Guidelines (DFSG) | https://www.debian.org/ |

Notes:

* Syncthing is licensed under the **Mozilla Public License 2.0 (MPL-2.0)**,
  which permits building and redistributing binaries provided the MPL-2.0
  license notice is retained and source availability requirements are met.
* The upstream `LICENSE` file is preserved inside the image at
  `/usr/share/doc/syncthing-notices/LICENSE`.
* Upstream source is published at <https://github.com/syncthing/syncthing> (at
  the tag recorded in image labels and `versions.json`), and any security-patch
  Go dependency bumps applied at build time are recorded in this repository's
  `Dockerfile`.
* Syncthing is a trademark of the Syncthing Foundation. This image is an
  independent build and is not endorsed by or affiliated with the Syncthing
  Foundation or LinuxServer.io.
