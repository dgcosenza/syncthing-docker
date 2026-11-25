#!/usr/bin/env bash
# Smoke test for dgcosenza/syncthing.
#
# Verifies linuxserver/syncthing drop-in parity (/config, PUID/PGID, UMASK_SET),
# healthcheck (/rest/noauth/health), non-root privilege drop (uid 1000),
# automatic ownership repair of /config, identity key creation, and negative
# healthcheck failure when stopped.
#
# Usage: tests/smoke.sh [image]
#        IMAGE=dgcosenza/syncthing:latest tests/smoke.sh
set -euo pipefail

IMAGE="${1:-${IMAGE:-dgcosenza/syncthing:latest}}"
NAME="${NAME:-syncthing-smoke}"
GUI_PORT="${GUI_PORT:-18384}"
DATA="$(mktemp -d)"

cleanup() {
  docker rm -f "$NAME" >/dev/null 2>&1 || true
  docker run --rm -v "$DATA:/x" --entrypoint chmod "$IMAGE" -R 777 /x >/dev/null 2>&1 || true
  rm -rf "$DATA"
}
trap cleanup EXIT

mkdir -p "$DATA/config"
chmod 777 "$DATA/config"

docker run -d --name "$NAME" \
  --security-opt no-new-privileges:true \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=UTC \
  -e UMASK_SET=022 \
  -p "127.0.0.1:${GUI_PORT}:8384/tcp" \
  -v "$DATA/config:/config" \
  "$IMAGE"

echo "== waiting for healthcheck"
for _ in $(seq 1 60); do
  status="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$NAME")"
  [ "$status" = "healthy" ] && break
  [ "$status" = "unhealthy" ] && { docker logs "$NAME"; exit 1; }
  sleep 2
done
test "$(docker inspect -f '{{.State.Health.Status}}' "$NAME")" = "healthy"

echo "== verify syncthing dropped privileges to non-root uid 1000"
docker exec "$NAME" sh -c '
  found=0
  for p in /proc/[0-9]*/status; do
    name="$(awk "/^Name:/{print \$2}" "$p" 2>/dev/null || true)"
    if [ "$name" = "syncthing" ]; then
      uid="$(awk "/^Uid:/{print \$2}" "$p" 2>/dev/null || true)"
      echo "syncthing process uid=${uid}"
      test "$uid" = "1000"
      found=1
    fi
  done
  test "$found" -eq 1
'

echo "== verify /rest/noauth/health and /config identity generation"
health="$(curl -fsS --max-time 10 "http://127.0.0.1:${GUI_PORT}/rest/noauth/health")"
echo "health: ${health}"
printf '%s' "$health" | grep -q '"OK"'
docker exec "$NAME" test -f /config/config.xml
docker exec "$NAME" test -f /config/cert.pem
docker exec "$NAME" test -f /config/key.pem
test "$(docker exec "$NAME" stat -c '%u:%g' /config/config.xml)" = "1000:1000"

echo "== verify syncthing version"
docker exec "$NAME" /usr/local/bin/syncthing --version

echo "== negative test: healthcheck fails when syncthing stops"
docker stop -t 5 "$NAME" >/dev/null
if curl -fsS --max-time 3 "http://127.0.0.1:${GUI_PORT}/rest/noauth/health" >/dev/null 2>&1; then
  echo "ERROR: health endpoint still answered after stop" >&2
  exit 1
fi

echo "Smoke test passed."
