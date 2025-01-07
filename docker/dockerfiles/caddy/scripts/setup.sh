#!/bin/bash

# This presupposes caddy, (GNU) sed, curl, jq and less to be available in the $PATH

# symlink /var/data/caddy/site/data to /var/data/existdb/data/export
# sudo chown -R existdb:podman /var/data/caddy/site/data
# sudo chmod -R g+w /var/data/caddy/site/data

# adapt Caddyfile to json format
sudo ./caddy adapt --config /etc/caddy/Caddyfile --validate --pretty > /etc/caddy/caddy_config.json

# add label for routing map config in json
sed -i --follow-symlinks '
/^\s*"destinations": \[$/ {
   N
    /\s*"{myfile}",$/ {
      N
      /\s*"{online}"$/ {
          i \ \t\t\t\t\t\t\t\t\t\t\t\t\t"@id": "routing_map",
      }
    }
}
' caddy_config.conneg.json

# launch caddy
sudo ./caddy run --config /etc/caddy/caddy_config.json

# load config
curl -X POST "http://localhost:2019/load" \
	-H "Content-Type: application/json" \
	-d @caddy_config.json

# remove routing information
curl -X DELETE \
	"http://localhost:2019/id/routing_map/mappings"

# add routing information of a single work
curl -X POST \
	-H "Content-Type: application/json" \
	-d @/var/data/caddy/site/data/W0095/W0095_routes.json \
	"http://localhost:2019/id/routing_map/mappings/..."

# see config
curl -X GET \
	"http://localhost:2019/config/apps/http/servers" | jq | less

# see first 10 mappings results:
curl -X GET \
	"http://localhost:2019/id/routing_map/mappings" | jq '.[0:10]'

# see mappings that satisfy some criterion:
curl -X GET \
	"http://localhost:2019/id/routing_map/mappings" | jq '.[] | select (.input == "/texts/W0018")'


# build a single json file with routing information from exist-db exports (also buildroutes.sh):
jq -n 'reduce inputs as $in (null;
	. + if $in|type == "array" then $in else [$in] end)
	' $(find /var/data/caddy/site/data -name '*_routes.json') > /var/data/caddy/site/data/combined_routes.json

# post routing information from single file (also postroutes.sh):
curl -X POST \
	-H "Content-Type: application/json" \
	-d @/var/data/caddy/site/data/combined_routes.json \
	"http://localhost:2019/id/routing_map/mappings"
