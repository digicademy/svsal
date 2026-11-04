#!/bin/sh

# Enable binding to privileged ports 80 and 443 for non-root users

# Check current value (distros differ; Ubuntu 24.04+ defaults to 0)
sysctl net.ipv4.ip_unprivileged_port_start

# Enable globally
sysctl -w net.ipv4.ip_unprivileged_port_start=0

# Persist
echo 'net.ipv4.ip_unprivileged_port_start=0' | \
  tee /etc/sysctl.d/99-podman-privileged-ports.conf
sysctl --system
