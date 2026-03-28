#!/usr/bin/env bash
set -euo pipefail

: "${GATEWAY_HOST:=openclaw}"
: "${GATEWAY_PORT:=18789}"
: "${NODE_DISPLAY_NAME:=browser-node}"
: "${OPENCLAW_CONFIG_PATH:=/home/node/.openclaw/openclaw.json}"

if [[ -z "${OPENCLAW_GATEWAY_TOKEN:-}" && -z "${OPENCLAW_GATEWAY_PASSWORD:-}" ]]; then
  echo "ERROR: set OPENCLAW_GATEWAY_TOKEN (or OPENCLAW_GATEWAY_PASSWORD)." >&2
  exit 1
fi

mkdir -p /home/node/.openclaw/browser/openclaw /home/node/.openclaw
cp /opt/openclaw/openclaw.browser-node.json "$OPENCLAW_CONFIG_PATH"

echo "[browser-node] chromium: $(chromium --version 2>/dev/null || echo missing)"
echo "[browser-node] gateway: ${GATEWAY_HOST}:${GATEWAY_PORT}"
echo "[browser-node] node display name: ${NODE_DISPLAY_NAME}"

TLS_ARGS=()
if [[ "${GATEWAY_TLS:-false}" == "true" ]]; then
  TLS_ARGS+=(--tls)
fi
if [[ -n "${GATEWAY_TLS_FINGERPRINT:-}" ]]; then
  TLS_ARGS+=(--tls-fingerprint "$GATEWAY_TLS_FINGERPRINT")
fi

exec openclaw node run \
  --host "$GATEWAY_HOST" \
  --port "$GATEWAY_PORT" \
  --display-name "$NODE_DISPLAY_NAME" \
  "${TLS_ARGS[@]}"
