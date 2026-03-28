# browser-node

Dedicated OpenClaw node-host + Chromium service for Zeabur.

## What this service does
- Installs Chromium persistently in its own service image
- Runs `openclaw node run` as a headless node host
- Exposes browser automation to the main Gateway through node browser proxy
- Restricts proxy access to the isolated `openclaw` browser profile only

## Files
- `Dockerfile` — service image
- `start-browser-node.sh` — runtime entrypoint
- `openclaw.browser-node.json` — local browser + nodeHost config inside the service
- `gateway.browser-routing.patch.json` — Gateway patch to apply **after** the node is online

## Zeabur deploy
Create a new service from this directory.

### Required env
- `GATEWAY_HOST=openclaw`
- `GATEWAY_PORT=18789`
- `OPENCLAW_GATEWAY_TOKEN=<same token as gateway.auth.token>`
- `NODE_DISPLAY_NAME=browser-node`

### Optional env
- `GATEWAY_TLS=false`
- `GATEWAY_TLS_FINGERPRINT=`

## Recommended persistent volume
Mount a volume to:
- `/home/node/.openclaw`

This keeps node identity / pairing state / browser profile data across restarts.

## First boot
1. Deploy the service
2. Wait for `openclaw node run` to connect to Gateway
3. Approve the pending node pairing request if Gateway asks for approval
4. Verify from Gateway:
   - `nodes status`
   - `browser status target=node node=browser-node profile=openclaw`
   - `browser start target=node node=browser-node profile=openclaw`

## Gateway routing (optional)
Do **not** apply browser routing before the service is online.

After `browser-node` is connected and verified, patch Gateway with the object in:
- `gateway.browser-routing.patch.json`

Equivalent patch:
```json
{
  "gateway": {
    "nodes": {
      "browser": {
        "mode": "auto",
        "node": "browser-node"
      }
    }
  }
}
```
