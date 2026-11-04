#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEV="$ROOT/packages/openfilm/.dev"
PID_FILE="$DEV/dev.pid"
LOG_FILE="$DEV/codespace.log"
URL_FILE="$DEV/codespace-url.txt"

cd "$ROOT"
mkdir -p "$DEV"

configure_codespace_origins() {
  if [[ -n "${CODESPACE_NAME:-}" && -n "${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-}" ]]; then
    local domain="${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
    export OPENFILM_STUDIO_ORIGIN="https://${CODESPACE_NAME}-4848.${domain}"
    export OPENFILM_FILM_ORIGIN="https://${CODESPACE_NAME}-4849.${domain}"
  fi
}

print_url() {
  if [[ -n "${OPENFILM_STUDIO_ORIGIN:-}" && -f "$DEV/run.json" ]]; then
    local key
    key="$(node -e "const r=require(process.argv[1]); process.stdout.write(r.key)" "$DEV/run.json")"
    printf '%s/open?key=%s\n' "$OPENFILM_STUDIO_ORIGIN" "$key" > "$URL_FILE"
    printf 'OpenFilm Studio: %s\n' "$(cat "$URL_FILE")"
  else
    printf 'OpenFilm Studio is starting. Open port 4848 from the Ports panel.\n'
  fi
}

configure_codespace_origins

if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  print_url
  exit 0
fi

nohup env OPENFILM_NO_BROWSER=1 node packages/openfilm/scripts/dev.mjs \
  >"$LOG_FILE" 2>&1 </dev/null &
echo "$!" > "$PID_FILE"

for _ in $(seq 1 60); do
  if grep -q 'Studio (dev)' "$LOG_FILE" 2>/dev/null; then
    break
  fi
  sleep 1
done

if [[ -s "$LOG_FILE" ]]; then
  tail -n 20 "$LOG_FILE"
fi
print_url
