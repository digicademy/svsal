#!/bin/sh

curl -X POST \
	-H "Content-Type: application/json" \
	-d @/var/data/caddy/site/data/combined_routes.json \
	"http://localhost:2019/id/routing_map/mappings/..."
