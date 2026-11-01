#!/bin/sh

ETC_DIR="/etc/caddy"
DEFAULTS_DIR="/opt/caddy/defaults"
CERT_DIR="/root/certs"

# If /etc/caddy is empty (i.e., a mount overrode it with an empty dir),
# populate it from the image defaults.
if [ -z "$(ls -A ${ETC_DIR} 2>/dev/null)" ]; then
    echo "${ETC_DIR} is empty — copying defaults from ${DEFAULTS_DIR}"
    cp -rn ${DEFAULTS_DIR}/* ${ETC_DIR}/
fi

# Same for certificates
if [ -z "$(ls -A ${CERT_DIR} 2>/dev/null)" ]; then
    echo "${CERT_DIR} is empty — copying defaults from /tmp/caddy/certs"
    cp -rn /tmp/caddy/certs/* ${CERT_DIR}/
fi

# ... and for site files
SITE_DIR="/var/data/caddy/site"
if [ -z "$(ls -A ${SITE_DIR} 2>/dev/null)" ]; then
    echo "${SITE_DIR} is empty — copying defaults from /tmp/caddy/site"
    cp -rn /tmp/caddy/site/* ${SITE_DIR}/
fi

# Run caddy either in development or production mode
if [ "$1" = "devel" ]; then
  echo "Running Caddy in development mode (set environment variable MODE=prod for production)"
  caddy run --config /etc/caddy/caddy_config.devel.json
elif [ "$1" = "prod" ]; then
  echo "Running Caddy in production mode"
  caddy run --config /etc/caddy/caddy_config.prod.json
else
  echo "Usage: $0 [devel|prod]"
  exit 1
fi
