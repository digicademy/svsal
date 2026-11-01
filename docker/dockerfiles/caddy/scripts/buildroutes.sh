#!/bin/sh

[ ! -f /var/data/caddy/site/data/combined_routes.json ] || mv /var/data/caddy/site/data/combined_routes.json /var/data/caddy/site/data/combined_routes.bak.json

# nice jq -n 'reduce inputs as $in (null;
#   . + if $in|type == "array" then $in else [$in] end)
# ' $(find -L /var/data/caddy/site/data -name '*_routes.json') | jq 'sort_by(.input)' > /var/data/caddy/site/data/combined_routes.json

nice -n 19 find -L /var/data/caddy/site/data -name '*_routes.json' -exec cat {} \; | \
nice -n 19 jq --slurp 'map(if type == "array" then . else [.] end) | add | sort_by(.input)' \
  > /var/data/caddy/site/data/combined_routes.json

