# Build image with
# time TMPDIR="/home/awagner/Temp" buildah bud -t ghcr.io/digicademy/svsal/svsal-caddy:2.8.4rc3 -f Dockerfile .
#
# Then run with
#   buildah from svsal-caddy
#   buildah run -e MODE=devel   --tty -p 8180:80 -p 8443:443 svsal-caddy-working-container /bin/bash
#
# or
#   podman run -e MODE=devel --rm -it -p 8180:80 -p 8443:443 --sysctl=net.core.rmem_max=7500000 --systl=net.core.wmem_max=7500000 --name caddy ghcr.io/digicademy/svsal/svsal-caddy:2.8.4rc3
#
#     perhaps add more mount options:
#       -v caddy/certs:/root/certs
#       -v caddy/log:/var/log/caddy
#       -v website:/var/data/caddy/site
#       -v existexport:/var/data/existdb/data/export
#
#     or change the MODE to "prod" and mount the production config:
#       -e MODE=prod
#
# This is the last working podman run command:
#
#   podman run -e MODE=devel --rm -it -p 8888:80 -p 8444:443 -v ./caddy/etc:/etc/caddy -v ./caddy/log:/var/log/caddy -v ./caddy/certs:/root/certs -v ./existexport:/var/data/caddy/existdb/export/data:ro -v ./website:/var/data/caddy/site --name caddy ghcr.io/digicademy/svsal/svsal-caddy:2.8.4rc3
#
# if all is well, upload with
#   buildah push svsal-caddy ghcr.io/digicademy/svsal/svsal-caddy:2.8.4rc3
# or
#   podman push ghcr.io/digicademy/svsal/svsal-caddy:2.8.4rc3

# === STAGE 1 ===

FROM caddy:2.8.4-builder AS builder

ENV CADDY_VERSION="v2.8.4"

RUN xcaddy build ${CADDY_VERSION} \
    --with github.com/mpilhlt/caddy-conneg \
    --with github.com/caddyserver/replace-response



# === STAGE 2 ===

FROM caddy:2.8.4

LABEL org.opencontainers.image.source https://github.com/digicademy/svsal
LABEL org.opencontainers.image.description "The School of Salamanca. Caddy Webserver Application"
LABEL org.opencontainers.image.licenses MIT

ENV CADDY_VERSION="v2.8.4" \
    CADDY_ETC_DIR="/etc/caddy" \
    CADDY_CERT_DIR="/root/certs" \
    CADDY_LOG_DIR="/var/log/caddy" \
    CADDY_SITE_DIR="/var/data/caddy/site" \
    SALAMANCA_DATA=/var/data/existdb/data/export/

# install curl and other tools
RUN apk update && \
    apk upgrade && \
    apk add curl jq git vim nss-tools

# copy caddy binary from builder
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# create directories
RUN mkdir -p ${CADDY_ETC_DIR} && \
    mkdir -p ${CADDY_CERT_DIR} && \
    mkdir -p ${CADDY_LOG_DIR} && \
    mkdir -p -m 777 ${CADDY_SITE_DIR} && \
    mkdir -p -m 777 ${SALAMANCA_DATA} && \
    mkdir -p /tmp/caddy/etc && \
    mkdir -p /tmp/caddy/certs && \
    mkdir -p /tmp/caddy/site

# copy scripts, config and certificates
COPY --chmod=775  scripts/*     /usr/bin/
COPY etc/*                      ${CADDY_ETC_DIR}/
COPY certs/*                    ${CADDY_CERT_DIR}/

# Copy config to a second, temporary directory in case the etc dir get mounted and is rest to empty.
# Then caddy.sh can copy the config from the temporary directory back to the etc dir.
COPY etc/*                      /tmp/caddy/etc/
COPY certs/*                    /tmp/caddy/certs/



# === Get Website files ===

ARG APP_NAME=svsal-website
ARG APP_REPO=https://github.com/digicademy/svsal-website.git
ARG APP_TAG_OR_BRANCH=v3

# Copy the website files
RUN cd $HOME && \
 git clone -b ${APP_TAG_OR_BRANCH} --single-branch ${APP_REPO} && \
  cd ${APP_NAME} \
  cp -r site/* ${CADDY_SITE_DIR} && \
  cp -r site/* /tmp/caddy/site && \
  cd $HOME && \
  rm -rf ${APP_NAME}



# === Finalize ===

VOLUME [ ${CADDY_ETC_DIR}, \
         ${CADDY_CERT_DIR}, \
         ${CADDY_LOG_DIR}, \
         ${CADDY_SITE_DIR}, \
         ${SALAMANCA_DATA} \
       ]

EXPOSE 80 443

ENV MODE="devel"
# or "prod"

CMD ["sh", "-c", "/usr/bin/caddy.sh ${MODE}"]
