# SvSal Podman Quadlet Deployment Guide

This directory contains Podman Quadlet configuration files for deploying the SvSal (School of Salamanca) application stack in production environments, as well as instructions for CI/CD derivative file generation workflows.

## Table of Contents

- [Overview](#overview)
- [Production Deployment (Quadlet)](#production-deployment-quadlet)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Managing Services](#managing-services)
  - [AutoUpdate Configuration](#autoupdate-configuration)
- [CI/CD Deployment (Docker Compose)](#cicd-deployment-docker-compose)
  - [Purpose](#purpose)
  - [Usage](#usage)
  - [Required Environment Variables](#required-environment-variables)
  - [Example Workflow](#example-workflow)
- [Network Aliases Configuration](#network-aliases-configuration)
- [Secrets Management](#secrets-management)
- [Image Building](#image-building)
- [Volume Management](#volume-management)
- [Troubleshooting](#troubleshooting)

## Overview

The SvSal stack consists of four main services:

- **existdb**: eXist-db XML database
- **caddy**: Web server and reverse proxy
- **sphinxsearch**: Full-text search engine
- **any23**: RDF extraction service

### Architecture

- All services run in a single Podman pod (`svsal-pod`)
- Named volumes for persistent data
- Systemd integration for automatic startup and management
- Pre-built container images from GitHub Container Registry (ghcr.io)

## Production Deployment (Quadlet)

### Prerequisites

1. **Podman** installed (version 4.4 or later recommended)
   ```bash
   # On Fedora/RHEL/CentOS
   sudo dnf install podman
   
   # On Ubuntu/Debian
   sudo apt install podman
   ```

2. **Systemd user service** enabled
   ```bash
   # Enable lingering to allow user services to run without active session
   sudo loginctl enable-linger $USER
   ```

3. **Quadlet directory** created
   ```bash
   mkdir -p ~/.config/containers/systemd
   ```

### Installation

1. **Copy Quadlet files** to the systemd user directory:
   ```bash
   cp *.container *.pod *.volume *.network ~/.config/containers/systemd/
   ```

2. **Reload systemd** to recognize the new units:
   ```bash
   systemctl --user daemon-reload
   ```

3. **Start the pod** and all services:
   ```bash
   # Start the pod (this will start all containers in the pod)
   systemctl --user start svsal.pod
   
   # Enable automatic startup on boot
   systemctl --user enable svsal.pod
   ```

   Alternatively, you can start individual services:
   ```bash
   systemctl --user start existdb.service
   systemctl --user start caddy.service
   systemctl --user start sphinxsearch.service
   systemctl --user start any23.service
   ```

### Managing Services

**Check service status:**
```bash
# Pod status
systemctl --user status svsal.pod

# Individual service status
systemctl --user status existdb.service
systemctl --user status caddy.service
systemctl --user status sphinxsearch.service
systemctl --user status any23.service

# Podman pod overview
podman pod ps

# Container details
podman ps -a
```

**Stop services:**
```bash
# Stop the entire pod
systemctl --user stop svsal.pod

# Or stop individual services
systemctl --user stop caddy.service
```

**Restart services:**
```bash
systemctl --user restart existdb.service
```

**View logs:**
```bash
# Service logs via journalctl
journalctl --user -u existdb.service -f

# Or directly via Podman
podman logs -f existdb
```

### AutoUpdate Configuration

By default, AutoUpdate is **commented out** in all container files to ensure manual control over updates. This prevents unexpected changes in production.

**To enable automatic updates:**

1. Edit the container file (e.g., `~/.config/containers/systemd/existdb.container`)
2. Uncomment the line: `# AutoUpdate=registry` → `AutoUpdate=registry`
3. Reload systemd: `systemctl --user daemon-reload`
4. Set up a systemd timer or cron job to run:
   ```bash
   podman auto-update
   systemctl --user restart existdb.service  # Restart services that were updated
   ```

**Manual updates** (recommended for production):
```bash
# Pull latest image
podman pull ghcr.io/digicademy/svsal/svsal-exist:3.0rc1

# Restart service to use new image
systemctl --user restart existdb.service
```

## CI/CD Deployment (Docker Compose)

### Purpose

The `docker-compose.cicd.yml` file provides a **lightweight configuration** specifically designed for CI/CD pipelines. It includes only the services needed for derivative file generation:

- **existdb**: For running XQuery scripts (e.g., `webdata-admin.xql`) to generate derivatives
- **any23**: For RDF extraction from TEI/XML files

This configuration has a reduced memory footprint and does not include caddy or sphinxsearch, which are not needed during the build/generation phase.

### Usage

```bash
# Start services
docker-compose -f docker/docker-compose.cicd.yml up -d

# Wait for services to be ready
sleep 10

# Run your derivative generation scripts
# Example: Call webdata-admin.xql via HTTP
curl -X POST http://localhost:8080/exist/apps/your-app/webdata-admin.xql

# Or use eXist-db client tools
# java -jar start.jar client -u admin -P $EXISTDB_ADMIN_PASSWORD ...

# Stop services
docker-compose -f docker/docker-compose.cicd.yml down
```

### Required Environment Variables

The following environment variables should be configured in your CI/CD platform (GitHub Actions, GitLab CI, Jenkins, etc.):

| Variable | Description | Required |
|----------|-------------|----------|
| `EXISTDB_ADMIN_PASSWORD` | Admin password for eXist-db | Yes |
| `SSH_PRIVATE_KEY` | SSH private key for rsync to webserver | Optional* |
| `WEBSERVER_HOST` | Target webserver hostname | Optional* |
| `WEBSERVER_USER` | SSH user for webserver | Optional* |

\* Required only if using rsync to deploy generated files to a remote webserver

**Important**: Never commit secrets to the repository. Use your CI/CD platform's secret management features.

#### Platform-Specific Configuration Examples

**GitHub Actions:**
```yaml
env:
  EXISTDB_ADMIN_PASSWORD: ${{ secrets.EXISTDB_ADMIN_PASSWORD }}
  SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
  WEBSERVER_HOST: ${{ secrets.WEBSERVER_HOST }}
  WEBSERVER_USER: ${{ secrets.WEBSERVER_USER }}
```

**GitLab CI:**
```yaml
variables:
  EXISTDB_ADMIN_PASSWORD: $EXISTDB_ADMIN_PASSWORD
  SSH_PRIVATE_KEY: $SSH_PRIVATE_KEY
  WEBSERVER_HOST: $WEBSERVER_HOST
  WEBSERVER_USER: $WEBSERVER_USER
```

**Jenkins:**
```groovy
environment {
    EXISTDB_ADMIN_PASSWORD = credentials('existdb-admin-password')
    SSH_PRIVATE_KEY = credentials('ssh-private-key')
    WEBSERVER_HOST = credentials('webserver-host')
    WEBSERVER_USER = credentials('webserver-user')
}
```

### Example Workflow

Here's a complete example of a CI/CD workflow that generates derivatives and deploys them:

```bash
#!/bin/bash
set -e

# 1. Start services
docker-compose -f docker/docker-compose.cicd.yml up -d

# 2. Wait for eXist-db to be ready
echo "Waiting for eXist-db to start..."
timeout 60 bash -c 'until curl -sf http://localhost:8080/exist/; do sleep 2; done'

# 3. Run derivative generation
echo "Generating derivatives..."
curl -X POST \
  -u admin:${EXISTDB_ADMIN_PASSWORD} \
  http://localhost:8080/exist/apps/svsal/webdata-admin.xql

# 4. Setup SSH for rsync (if needed)
if [ -n "$SSH_PRIVATE_KEY" ]; then
  mkdir -p ~/.ssh
  echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
  chmod 600 ~/.ssh/id_rsa
  
  # Optional: Add known hosts
  # ssh-keyscan $WEBSERVER_HOST >> ~/.ssh/known_hosts
  # Or use: -o StrictHostKeyChecking=no (less secure)
fi

# 5. Get the export volume path
EXPORT_PATH=$(docker volume inspect existexport-cicd --format '{{ .Mountpoint }}')

# 6. Rsync generated files to webserver
if [ -n "$SSH_PRIVATE_KEY" ]; then
  echo "Deploying to webserver..."
  rsync -avz -e "ssh -o StrictHostKeyChecking=no" \
    $EXPORT_PATH/ \
    ${WEBSERVER_USER}@${WEBSERVER_HOST}:/var/www/salamanca/data/
fi

# 7. Cleanup
docker-compose -f docker/docker-compose.cicd.yml down
```

**SSH Known Hosts Notes:**
- `SSH_KNOWN_HOSTS` is optional
- For automated CI/CD, you can either:
  - Pre-populate known_hosts with `ssh-keyscan $WEBSERVER_HOST >> ~/.ssh/known_hosts`
  - Use `-o StrictHostKeyChecking=no` (less secure, but acceptable for CI/CD)
  - Store and use a `SSH_KNOWN_HOSTS` secret

## Network Aliases Configuration

**Important**: Podman pods do not natively support Docker Compose-style network aliases. The `docker-compose.yml` file includes network aliases for service discovery, but these require external configuration when using Quadlet.

### Required Hostnames

The following hostnames are used by the application:

- `www.salamanca.school` → Caddy (web interface)
- `id.salamanca.school` → Caddy (identifier service)
- `search.salamanca.school` → Sphinxsearch

### Solutions by Environment

#### Production Deployment (Recommended)

Configure **DNS records** at your DNS provider:

```dns
www.salamanca.school.      A      <your-server-ip>
id.salamanca.school.       A      <your-server-ip>
search.salamanca.school.   A      <your-server-ip>
```

Or use CNAME records if appropriate:
```dns
www.salamanca.school.      CNAME  your-server.example.com.
id.salamanca.school.       CNAME  your-server.example.com.
search.salamanca.school.   CNAME  your-server.example.com.
```

#### Development/Testing

Add entries to `/etc/hosts` (requires root):

```bash
sudo tee -a /etc/hosts <<EOF
127.0.0.1 www.salamanca.school
127.0.0.1 id.salamanca.school
127.0.0.1 search.salamanca.school
EOF
```

Or use the pod's IP address:
```bash
POD_IP=$(podman inspect svsal-pod | jq -r '.[0].NetworkSettings.Networks[].IPAddress')
sudo tee -a /etc/hosts <<EOF
$POD_IP www.salamanca.school
$POD_IP id.salamanca.school
$POD_IP search.salamanca.school
EOF
```

#### CI/CD Environment

When using `docker-compose.cicd.yml`, **container names are used directly** for service discovery. No additional configuration is needed:

- `http://existdb:8080`
- `http://any23:8082`

## Secrets Management

**Critical**: Never commit secrets or credentials to the repository.

### Production Secrets

For production Quadlet deployments, sensitive configuration should be managed using:

1. **Environment files**: Create a `.env` file (not in git):
   ```bash
   # ~/.config/containers/svsal.env
   EXISTDB_ADMIN_PASSWORD=your-secure-password
   ```
   
   Reference in container file:
   ```ini
   EnvironmentFile=%h/.config/containers/svsal.env
   ```

2. **Systemd credentials** (Podman 4.5+):
   ```bash
   systemctl --user set-environment EXISTDB_ADMIN_PASSWORD='your-password'
   ```

3. **Secrets mounting** (for files):
   ```ini
   Secret=existdb-password,type=env,target=EXISTDB_PASSWORD
   ```

### CI/CD Secrets

Use your CI/CD platform's built-in secret management:

- **GitHub Actions**: Repository Secrets
- **GitLab CI**: CI/CD Variables (masked and protected)
- **Jenkins**: Credentials Plugin
- **Azure Pipelines**: Variable Groups (secret variables)

### Required Secrets List

| Secret | Purpose | Environment |
|--------|---------|-------------|
| `EXISTDB_ADMIN_PASSWORD` | eXist-db admin password | Production, CI/CD |
| `SSH_PRIVATE_KEY` | Deploy to webserver | CI/CD only |
| `WEBSERVER_HOST` | Target webserver hostname | CI/CD only |
| `WEBSERVER_USER` | SSH username for deployment | CI/CD only |

## Image Building

All services use **pre-built container images** from the GitHub Container Registry:

- `ghcr.io/digicademy/svsal/svsal-exist:3.0rc1`
- `ghcr.io/digicademy/svsal/svsal-caddy:2.8.4rc3`
- `ghcr.io/digicademy/svsal/svsal-sphinxsearch:2.2.11rc1`
- `ghcr.io/digicademy/svsal/svsal-any23:2.3rc2`

### For Maintainers: Building Images

**Note**: `any23` and `sphinxsearch` require large binary files that are not included in the repository. These must be downloaded or built separately before creating the images.

To build images locally:

```bash
# Build eXist-db image
cd docker/exist
podman build -t ghcr.io/digicademy/svsal/svsal-exist:3.0rc1 .

# Build Caddy image
cd docker/caddy
podman build -t ghcr.io/digicademy/svsal/svsal-caddy:2.8.4rc3 .

# Build Sphinxsearch (requires pre-downloaded binaries)
cd docker/sphinxsearch
# Download/prepare sphinx binaries first
podman build -t ghcr.io/digicademy/svsal/svsal-sphinxsearch:2.2.11rc1 .

# Build Any23 (requires pre-downloaded binaries)
cd docker/any23
# Download/prepare any23 binaries first
podman build -t ghcr.io/digicademy/svsal/svsal-any23:2.3rc2 .
```

### Pushing to Registry

```bash
# Login to GitHub Container Registry
echo $GITHUB_TOKEN | podman login ghcr.io -u USERNAME --password-stdin

# Push images
podman push ghcr.io/digicademy/svsal/svsal-exist:3.0rc1
podman push ghcr.io/digicademy/svsal/svsal-caddy:2.8.4rc3
podman push ghcr.io/digicademy/svsal/svsal-sphinxsearch:2.2.11rc1
podman push ghcr.io/digicademy/svsal/svsal-any23:2.3rc2
```

## Volume Management

### Named Volumes

The configuration uses named volumes for persistent data:

| Volume | Purpose | Shared By |
|--------|---------|-----------|
| `logs.volume` | Application logs | caddy, existdb |
| `website.volume` | Static website files | caddy |
| `existexport.volume` | eXist-db exports | caddy (ro), existdb, sphinxsearch (ro) |
| `sphinx-data.volume` | Search index data | sphinxsearch |
| `sphinx-logs.volume` | Search engine logs | sphinxsearch |

### SELinux Considerations

The `:z` flag is used on volume mounts to ensure SELinux compatibility:

- `:z` - Shared volume, accessible by multiple containers
- `:ro,z` - Read-only shared volume

If you're running on a system without SELinux (e.g., Ubuntu), the `:z` flag is harmless and can be left in place.

### Backup Strategies

**Backup volumes:**
```bash
# Create backup directory
mkdir -p ~/svsal-backups/$(date +%Y%m%d)

# Backup using podman volume export (if available)
podman volume export existexport > ~/svsal-backups/$(date +%Y%m%d)/existexport.tar

# Or use rsync to copy volume data
VOLUME_PATH=$(podman volume inspect existexport --format '{{ .Mountpoint }}')
sudo rsync -av $VOLUME_PATH/ ~/svsal-backups/$(date +%Y%m%d)/existexport/
```

**Restore volumes:**
```bash
# Stop services first
systemctl --user stop svsal.pod

# Import volume
podman volume import existexport < ~/svsal-backups/20240101/existexport.tar

# Or restore with rsync
VOLUME_PATH=$(podman volume inspect existexport --format '{{ .Mountpoint }}')
sudo rsync -av ~/svsal-backups/20240101/existexport/ $VOLUME_PATH/

# Restart services
systemctl --user start svsal.pod
```

### Volume Cleanup

```bash
# Remove unused volumes (CAUTION: This will delete data!)
podman volume prune

# Remove specific volume
podman volume rm existexport
```

## Troubleshooting

### Service won't start

1. **Check service status and logs:**
   ```bash
   systemctl --user status existdb.service
   journalctl --user -u existdb.service -n 50
   ```

2. **Check if the image is available:**
   ```bash
   podman images | grep svsal
   ```

3. **Manually pull the image:**
   ```bash
   podman pull ghcr.io/digicademy/svsal/svsal-exist:3.0rc1
   ```

### Port already in use

Check if another service is using the required ports:
```bash
ss -tlnp | grep -E ':(80|443|8080|8443|8081|8082|9312|9306)'
```

### Volume permission issues

Ensure the container user has permission to access the volumes:
```bash
# Check volume permissions
VOLUME_PATH=$(podman volume inspect existexport --format '{{ .Mountpoint }}')
sudo ls -la $VOLUME_PATH
```

### Pod networking issues

Check pod network configuration:
```bash
podman pod inspect svsal-pod
podman network inspect svsal-network
```

### Container crashes immediately

Check container logs:
```bash
podman logs existdb
journalctl --user -u existdb.service
```

### Memory issues

If containers are killed due to OOM (Out Of Memory):

1. Check system memory:
   ```bash
   free -h
   ```

2. Adjust memory limits in container files:
   ```ini
   PodmanArgs=--memory=512m
   ```

3. For eXist-db, adjust Java heap settings:
   ```ini
   Environment=JAVA_TOOL_OPTIONS='-Xmx8g -Xms4g'
   ```

### Systemd lingering not enabled

If services stop when you log out:
```bash
sudo loginctl enable-linger $USER
```

## Additional Resources

- [Podman Documentation](https://docs.podman.io/)
- [Podman Quadlet Documentation](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
- [eXist-db Documentation](https://exist-db.org/exist/apps/doc/)
- [Caddy Documentation](https://caddyserver.com/docs/)

## Support

For issues specific to the SvSal deployment, please open an issue in the [GitHub repository](https://github.com/digicademy/svsal).
