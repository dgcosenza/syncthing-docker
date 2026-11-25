#!/bin/sh
# Drop-in entrypoint for dgcosenza/syncthing (compatible with linuxserver/syncthing).
# Honors PUID, PGID, UMASK / UMASK_SET, HOME, STHOMEDIR, STGUIADDRESS, and drops
# privileges via Debian util-linux `setpriv --no-new-privs`.
set -eu

# Apply umask (supports both UMASK and linuxserver's UMASK_SET)
UMASK_VAL="${UMASK_SET:-${UMASK:-022}}"
umask "$UMASK_VAL"

# Allow running an explicit non-option command directly (e.g. `syncthing --version`)
if [ $# -gt 0 ] && [ "${1#-}" = "$1" ] && [ "$1" != "syncthing" ] && [ "$1" != "/usr/local/bin/syncthing" ]; then
  exec "$@"
fi

# Strip leading `syncthing` if passed explicitly
if [ $# -gt 0 ] && { [ "$1" = "syncthing" ] || [ "$1" = "/usr/local/bin/syncthing" ]; }; then
  shift
fi

PUID="${PUID:-1000}"
PGID="${PGID:-1000}"
HOME="${HOME:-/config}"
STHOMEDIR="${STHOMEDIR:-/config}"
STGUIADDRESS="${STGUIADDRESS:-0.0.0.0:8384}"
export HOME STHOMEDIR STGUIADDRESS

if [ "$(id -u)" = "0" ]; then
  mkdir -p "${STHOMEDIR}"
  # Only chown paths whose ownership differs, preserving fast startup on large volumes.
  if [ -z "${SKIP_CHOWN:-}" ]; then
    find "${STHOMEDIR}" \( ! -user "${PUID}" -o ! -group "${PGID}" \) \
      -exec chown "${PUID}:${PGID}" '{}' + 2>/dev/null || true
  fi
  exec /usr/bin/setpriv \
    --reuid="${PUID}" \
    --regid="${PGID}" \
    --clear-groups \
    --no-new-privs \
    -- env HOME="${HOME}" STHOMEDIR="${STHOMEDIR}" STGUIADDRESS="${STGUIADDRESS}" \
    /usr/local/bin/syncthing \
      --no-browser \
      --no-restart \
      --home="${STHOMEDIR}" \
      --gui-address="${STGUIADDRESS}" \
      "$@"
fi

exec /usr/local/bin/syncthing \
  --no-browser \
  --no-restart \
  --home="${STHOMEDIR}" \
  --gui-address="${STGUIADDRESS}" \
  "$@"
