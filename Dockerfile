FROM node:24-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/home/node \
    OPENCLAW_HOME=/home/node/.openclaw \
    OPENCLAW_STATE_DIR=/home/node/.openclaw \
    PUPPETEER_SKIP_DOWNLOAD=1

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      chromium \
      tini \
      fonts-liberation \
 && rm -rf /var/lib/apt/lists/*

RUN npm install -g openclaw@2026.3.24 --no-audit --no-fund \
 && npm cache clean --force \
 && rm -rf /root/.npm /tmp/*

RUN install -d -o node -g node /home/node/.openclaw /workspace

WORKDIR /workspace

COPY --chown=node:node start-browser-node.sh /usr/local/bin/start-browser-node.sh
COPY --chown=node:node openclaw.browser-node.json /opt/openclaw/openclaw.browser-node.json

RUN chmod +x /usr/local/bin/start-browser-node.sh

USER node

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 CMD pgrep -af "openclaw node run" >/dev/null || exit 1

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/start-browser-node.sh"]
