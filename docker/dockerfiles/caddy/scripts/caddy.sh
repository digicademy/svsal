#!/bin/sh

# Copy files back from temporary directory if not already present

echo "Copying config files to /etc/caddy/ if necessary"
cp -rn /tmp/caddy/etc/*    /etc/caddy

echo "Copying certificate to /root/certs/ if necessary"
cp -rn /tmp/caddy/certs/*  /root/certs

echo "Copying website files to /var/data/caddy/site/ if necessary"
cp -rn /tmp/caddy/site/*   /var/data/caddy/site


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
