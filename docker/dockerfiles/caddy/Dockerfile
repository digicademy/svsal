# Build image with
#
# time TMPDIR="/mnt/c/tmp" buildah bud --no-cache -t ghcr.io/digicademy/svsal/svsal-caddy:2.11.7rc1 -f Dockerfile .
#
# Then run with
#   buildah from svsal-caddy
#   buildah run -e MODE=devel   --tty -p 8180:80 -p 8443:443 svsal-caddy-working-container /bin/bash
#
# or
#   podman run -e MODE=devel --rm -it -p 8180:80 -p 8443:443 --sysctl=net.core.rmem_max=7500000 --systl=net.core.wmem_max=7500000 --name caddy ghcr.io/digicademy/svsal/svsal-caddy:2.11.7rc1
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
# This is the last working podman run command:
#
#   podman run -e MODE=devel --rm -it -p 8888:80 -p 8444:443 -v ./caddy/etc:/etc/caddy -v ./caddy/log:/var/log/caddy -v ./caddy/certs:/root/certs -v ./existexport:/var/data/caddy/existdb/export/data:ro -v ./website:/var/data/caddy/site --name caddy ghcr.io/digicademy/svsal/svsal-caddy:2.11.7rc1
#
#
# If all is well, login to container registry (with podman/buildah login ghcr.io) and upload with
#   buildah push svsal-caddy ghcr.io/digicademy/svsal/svsal-caddy:2.11.7rc1
# or
#   podman push ghcr.io/digicademy/svsal/svsal-caddy:2.11.7rc1

# === STAGE 1 ===

ARG CADDY_VERSION="2.11.7"

FROM caddy:${CADDY_VERSION}-builder AS builder

ARG CADDY_VERSION

RUN xcaddy build ${CADDY_VERSION} \
    --with github.com/mpilhlt/caddy-conneg \
    --with github.com/caddyserver/replace-response



# === STAGE 2 ===

FROM caddy:${CADDY_VERSION}

ARG ETC_DIR="/etc/caddy"
ARG CERT_DIR="/root/certs"
ARG LOG_DIR="/var/log/caddy"
ARG SITE_DIR="/var/data/caddy/site"
ARG SAL_DATA_DIR="/var/data/existdb/data/export"

LABEL org.opencontainers.image.source https://github.com/digicademy/svsal
LABEL org.opencontainers.image.description "The School of Salamanca. Caddy Webserver Application"
LABEL org.opencontainers.image.licenses MIT

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
    mkdir -p -m 777 ${SAL_DATA_DIR}
    # mkdir -p /tmp/caddy/etc && \
    # mkdir -p /tmp/caddy/certs && \
    # mkdir -p /tmp/caddy/site

# copy scripts, config and certificates
COPY --chmod=775  scripts/*     /usr/bin/
COPY etc/*                      ${ETC_DIR}/
COPY certs/*                    ${CERT_DIR}/

# Copy config to a second, temporary directory in case the etc dir get mounted and is rest to empty.
# Then caddy.sh can copy the config from the temporary directory back to the etc dir.
# COPY etc/*                      /tmp/caddy/etc/
# COPY certs/*                    /tmp/caddy/certs/



# === Get Website files ===

ARG APP_NAME=svsal-website
ARG APP_REPO=https://github.com/digicademy/svsal-website.git
ARG APP_TAG_OR_BRANCH=feature/embeddings

# Copy the website files
RUN cd $HOME && \
  git clone ${APP_REPO} && \
  cd ${APP_NAME} && \
  echo "Checking out ${APP_TAG_OR_BRANCH}..." && \
  git checkout ${APP_TAG_OR_BRANCH} && \
  cp -r site/* ${CADDY_SITE_DIR} && \
  cd $HOME && \
  rm -rf ${APP_NAME}
  # cp -r site/* /tmp/caddy/site && \



# === Finalize ===

VOLUME [ ${ETC_DIR}, \
         ${CERT_DIR}, \
         ${LOG_DIR}, \
         ${SITE_DIR}, \
         ${SAL_DATA_DIR} \
       ]

EXPOSE 80 443

ENV MODE="devel"
# or "prod"

CMD ["sh", "-c", "/usr/bin/caddy.sh ${MODE}"]
