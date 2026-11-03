# Build image with
#
# time TMPDIR="/mnt/c/tmp" buildah bud --no-cache -t ghcr.io/digicademy/svsal/svsal-caddy:2.11.7rc3 -f Dockerfile .
#
# Then run with
#   buildah from svsal-caddy
#   buildah run -e MODE=devel   --tty -p 8180:80 -p 8443:443 svsal-caddy-working-container /bin/bash
#
# or
#   podman run -e MODE=devel --rm -it -p 8180:80 -p 8443:443 --sysctl=net.core.rmem_max=7500000 --systl=net.core.wmem_max=7500000 --name caddy ghcr.io/digicademy/svsal/svsal-caddy:2.11.7rc3
#
#     perhaps add more mount options:
#       -v caddy/certs:/root/certs
#       -v caddy/etc:/etc/caddy
#       -v caddy/log:/var/log/caddy
#       -v website:/var/data/caddy/site
#       -v existexport:/var/data/existdb/data/export
#
#     or change the MODE to "prod" and mount the production config:
#       -e MODE=prod
#
# Put the wildcard dummy certs in a directory that will be mounted to /root/certs in the container,
# for example /var/data/caddy/certs, then mount with -v /var/data/caddy/certs:/root/certs:ro
#
# This is the last working podman run command:
#
#  podman run -e MODE=devel --rm -it -p 8080:80 -p 8443:443 -v /var/data/caddy/etc:/etc/caddy -v /var/data/caddy/logs/:/var/log/caddy -v /var/data/caddy/certs:/root/certs -v /var/data/caddy/site:/var/data/caddy/site -v /var/data/existdb/export:/var/data/existdb/data/export:ro --name caddy ghcr.io/digicademy/svsal/svsal-caddy:2.11.7rc3
#
# If all is well, login to container registry (with podman/buildah login ghcr.io) and upload with
#   buildah push svsal-caddy ghcr.io/digicademy/svsal/svsal-caddy:2.11.7rc3
# or
#   podman push ghcr.io/digicademy/svsal/svsal-caddy:2.11.7rc3

# === STAGE 1 ===

ARG CADDY_VERSION="2.11.7"

FROM caddy:${CADDY_VERSION}-builder AS builder

ARG CADDY_VERSION

RUN xcaddy build ${CADDY_VERSION} \
    --with github.com/mpilhlt/caddy-conneg \
    --with github.com/caddyserver/replace-response \
    --with pkg.jsn.cam/caddy-defender



# === STAGE 2 ===

FROM caddy:${CADDY_VERSION}

ARG ETC_DIR="/etc/caddy"
ARG DEFAULTS_DIR="/opt/caddy/defaults"
ARG CERT_DIR="/root/certs"
ARG LOG_DIR="/var/log/caddy"
ARG SITE_DIR="/var/data/caddy/site"
ARG SAL_DATA_DIR="/var/data/existdb/data/export"

LABEL org.opencontainers.image.source https://github.com/digicademy/svsal
LABEL org.opencontainers.image.description "The School of Salamanca. Caddy Webserver Application"
LABEL org.opencontainers.image.licenses MIT

WORKDIR /tmp

# install curl and other tools
RUN apk update && \
    apk upgrade && \
    apk add curl jq git vim nss-tools

# copy caddy binary from builder
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# create directories
RUN mkdir -p ${ETC_DIR} && \
    mkdir -p ${CERT_DIR} && \
    mkdir -p ${LOG_DIR} && \
    mkdir -p -m 777 ${SITE_DIR} && \
    mkdir -p -m 777 ${SAL_DATA_DIR} && \
    mkdir -p /tmp/caddy/certs && \
    mkdir -p /tmp/caddy/site

# copy scripts, config and certificates
COPY --chmod=775  scripts/*     /usr/bin/
COPY certs/*                    ${CERT_DIR}/

# Copy defaults to a safe location (NOT the mount point)
COPY etc/*   ${DEFAULTS_DIR}/
# Also put them in the actual etc dir so it works without any mount
COPY etc/*   ${ETC_DIR}/

# Copy certificates to the temporary caddy directory for use during container initialization.
COPY certs/*                    /tmp/caddy/certs/

# === Get Website files ===

ARG APP_NAME=svsal-website
ARG APP_REPO=https://github.com/digicademy/svsal-website.git
ARG APP_TAG_OR_BRANCH=feature/embeddings

# Copy the website files
RUN git clone ${APP_REPO} && \
  cd ${APP_NAME} && \
  echo "Checking out ${APP_TAG_OR_BRANCH}..." && \
  git checkout ${APP_TAG_OR_BRANCH} && \
  cp -r site/* ${SITE_DIR}/ && \
  cp -r site/* /tmp/caddy/site && \
  cd .. && \
  rm -rf ${APP_NAME}


# === Finalize ===

EXPOSE 80 443

ENV MODE="prod"
# or "devel"

CMD ["sh", "-c", "/usr/bin/caddy.sh ${MODE}"]
