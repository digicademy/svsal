# Dockerfile for Salamanca eXist-db Webapp
#
# Build image with
# . .env && time TMPDIR="/mnt/c/tmp" buildah bud --no-cache --secret id=setadminpw,src=../setadminpw --build-arg SVN_USER=${SVN_USER} --build-arg SVN_PASS=${SVN_PASS} --build-arg EXIST_PASS=${EXIST_PASS} --build-arg EXIST_VERSION=${EXIST_VERSION} -t ghcr.io/digicademy/svsal/svsal-exist:3.0rc4 -f Dockerfile .
#
# Then run with
#   buildah from svsal-exist
#   buildah run --tty -p 8080:8080 -p 8443:8443 svsal-exist-working-container /bin/bash
#
# or
#   podman run --rm -it -p 8080:8080 -p 8443:8443 --name exist ghcr.io/digicademy/svsal/svsal-exist:3.0rc4
#     perhaps add mount options:
#       -v svsal-webdata:/var/data/exist/data/export
#       -v $(pwd)/tmp/logs:/exist/logs
#
# This is the last working podman run command:
#
#  podman run --rm -it -p 8080:8080 -p 8443:8443 --name=exist -v ./exist_mount/export:/exist/data/export -v ./exist_mount/logs:/exist/logs ghcr.io/digicademy/svsal/svsal-exist:3.0rc4
#
# These are (systemd service unit) podman parameters used in production,
# whether they make sense depends on the environment the container is being run in:
#
# -e JAVA_TOOL_OPTIONS='-Xmx10g -Xms10g -XX:MaxRAMPercentage=75.0'
#
#
# If all is well, login to container registry (with podman/buildah login ghcr.io) and upload with
#   buildah push svsal-caddy ghcr.io/digicademy/svsal/svsal-exist:3.0rc4
# or
#   podman push ghcr.io/digicademy/svsal/svsal-exist:3.0rc4

ARG EXIST_VERSION=6.4.0

# === STAGE 1 ===

FROM ghcr.io/eeditiones/builder:latest AS builder

# USER root

# Install tools required to build eXist apps
WORKDIR /tmp
RUN mkdir -p /tmp/svsal-xar

RUN apt-get update && apt-get install -y --no-install-recommends \
  git-svn

# add github.com host key
# RUN mkdir -p ~/.ssh && ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

ARG SVN_USER
ARG SVN_PASS
# For Salamanca Webapp, we need these eXist apps:
# - svsal-existadmin from SVN
# - svsal from github
# - svsal-tei from SVN
# - svsal-webdata from SVN

# -- svsal-existadmin --

ARG APP1_REPO=https://svn.adwmainz.net/04-39/trunk/svsal-existadmin
ARG APP1_PATH=svsal-existadmin

# Build the app
RUN echo ${SVN_PASS} | git svn clone --username ${SVN_USER} ${APP1_REPO} \
  && cd ${APP1_PATH} \
  && ant \
  && cp build/*.xar /tmp/svsal-xar \
  && cd ..

# -- svsal --

ARG APP2_NAME=svsal
ARG APP2_REPO=https://github.com/digicademy/svsal.git
ARG APP2_TAG_OR_BRANCH=feature/cicd

# Build the app
RUN  git clone ${APP2_REPO} \
  && cd ${APP2_NAME} \
  && echo Checking out ${APP2_TAG_OR_BRANCH} \
  && git checkout ${APP2_TAG_OR_BRANCH} \
  && ant \
  && cp build/*.xar /tmp/svsal-xar \
  && cd ..

# -- svsal-tei --

ARG APP3_REPO=https://svn.adwmainz.net/04-39/trunk/svsal-tei
ARG APP3_PATH=svsal-tei

# Build the app
RUN echo ${SVN_PASS} | git svn clone --username ${SVN_USER} ${APP3_REPO} \
  && cd ${APP3_PATH} \
  && ant \
  && cp build/*.xar /tmp/svsal-xar \
  && cd ..

# -- svsal-webdata --

ARG APP4_REPO=https://svn.adwmainz.net/04-39/trunk/svsal-webdata
ARG APP4_PATH=svsal-webdata

# Build the app
RUN echo ${SVN_PASS} | git svn clone --username ${SVN_USER} ${APP4_REPO} \
  && cd ${APP4_PATH} \
  && ant \
  && cp build/*.xar /tmp/svsal-xar \
  && cd ..

# -- other eXist apps and libraries --

ARG TEMPLATING_VERSION=1.2.1
ARG EXPATH_BIN_VERSION=1.0.1
ARG FUNCTX_VERSION=1.0.1
ARG EXIDE_VERSION=3.5.5
ARG MONEX_VERSION=4.2.4
ARG EXISTDB_BACKUP_VERSION=1.1.1-prod
ARG DASHBOARD_VERSION=2.0.9
ARG PACKAGESERVICE_VERSION=1.3.14
ARG PACKAGEMANAGER_VERSION=4.6.2
ARG SEMVER_VERSION=3.0.0
ARG USERMANAGER_VERSION=0.16.5-prod

RUN curl -L -o /tmp/templating-${TEMPLATING_VERSION}.xar             http://exist-db.org/exist/apps/public-repo/public/templating-${TEMPLATING_VERSION}.xar
RUN curl -L -o /tmp/expath-bin-${EXPATH_BIN_VERSION}.xar             http://exist-db.org/exist/apps/public-repo/public/expath-bin-module-${EXPATH_BIN_VERSION}.xar
RUN curl -L -o /tmp/functx-${FUNCTX_VERSION}.xar                     http://exist-db.org/exist/apps/public-repo/public/functx-${FUNCTX_VERSION}.xar
RUN curl -L -o /tmp/eXide-${EXIDE_VERSION}.xar                       http://exist-db.org/exist/apps/public-repo/public/eXide-${EXIDE_VERSION}.xar
RUN curl -L -o /tmp/monex-${MONEX_VERSION}.xar                       http://exist-db.org/exist/apps/public-repo/public/monex-${MONEX_VERSION}.xar
RUN curl -L -o /tmp/existdb-backup-${EXISTDB_BACKUP_VERSION}.xar     http://exist-db.org/exist/apps/public-repo/public/existdb-backup-${EXISTDB_BACKUP_VERSION}.xar
RUN curl -L -o /tmp/dashboard-${DASHBOARD_VERSION}.xar               http://exist-db.org/exist/apps/public-repo/public/dashboard-${DASHBOARD_VERSION}.xar
RUN curl -L -o /tmp/packageservice-${PACKAGESERVICE_VERSION}.xar     http://exist-db.org/exist/apps/public-repo/public/packageservice-${PACKAGESERVICE_VERSION}.xar
RUN curl -L -o /tmp/packagemanager-${PACKAGEMANAGER_VERSION}.xar     http://exist-db.org/exist/apps/public-repo/public/packagemanager-${PACKAGEMANAGER_VERSION}.xar
RUN curl -L -o /tmp/semver-xq-${SEMVER_VERSION}.xar                  http://exist-db.org/exist/apps/public-repo/public/semver-xq-${SEMVER_VERSION}.xar
RUN curl -L -o /tmp/usermanager-${USERMANAGER_VERSION}.xar           http://exist-db.org/exist/apps/public-repo/public/usermanager-${USERMANAGER_VERSION}.xar

RUN echo "Contents of /tmp:"
RUN ls -la /tmp
RUN ls -la /tmp/svsal-xar



# === STAGE 2 ===

FROM ghcr.io/jinntec/base:${EXIST_VERSION}

# ARG EXIST_PASS
ARG USR=nonroot:nonroot
ARG HTTP_PORT=8080
ARG HTTPS_PORT=8443
ARG EXIST_PASS

LABEL org.opencontainers.image.source https://github.com/digicademy/svsal
LABEL org.opencontainers.image.description "The School of Salamanca. XQuery Web Application"
LABEL org.opencontainers.image.licenses MIT

# Copy Builder files and configs
COPY --from=builder /tmp/*.xar                   /exist/autodeploy/
COPY --from=builder /tmp/svsal-xar/*.xar         /exist/autodeploy/
COPY etc/conf.xml                                /exist/etc/
COPY etc/log4j2.xml                              /exist/etc/
COPY etc/controller-config.xml                   /exist/etc/webapp/WEB-INF/
COPY etc/web.xml                                 /exist/etc/webapp/WEB-INF/
# COPY --chown=${USR} etc/standard.enabled-jetty-configs          /exist/etc/jetty/
# COPY --chown=${USR} etc/jetty-ssl-context.xml etc/keystore.p12  /exist/etc/jetty/

# Configure JVM for use in container (here be dragons)
# also sets default values to previous two arguments
ENV JAVA_TOOL_OPTIONS="\
  -Dfile.encoding=UTF8 \
  -Dsun.jnu.encoding=UTF-8 \
  -Djava.awt.headless=true \
  -Djetty.home=/exist \
  -Dexist.home=/exist \
  -Dexist.configurationFile=/exist/etc/conf.xml \
  -Dexist.jetty.config=/exist/etc/jetty/standard.enabled-jetty-configs \
  -Dlog4j.configurationFile=/exist/etc/log4j2.xml \
  -XX:+UseG1GC \
  -XX:+UseStringDeduplication \
  -XX:+UseContainerSupport \
  -XX:+ExitOnOutOfMemoryError"
  # -XX:MaxRAMPercentage=${JVM_MAX_RAM_PERCENTAGE:-75.0} \
  # -Dorg.exist.db-connection.cacheSize=${CACHE_MEM:-256}M \
  # -Dorg.exist.db-connection.pool.max=${MAX_BROKER:-20} \
  # -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 \

# pre-populate the database by launching it once
# RUN [ "java", "org.exist.start.Main", "client", "--no-gui",  "-l" ]

# Set admin password using secret file if available
# this presupposes a secret file ".setadminpw" containing "sm:passwd('admin','123')"
# being passed via --secret=id=setadminpw,src=./.setadminpw to the build process
RUN --mount=type=secret,id=setadminpw,target=/setadminpw,mode=0444 ["java", "org.exist.start.Main", "client", "--no-gui", "-l", "-u", "admin", "-P", "", "-F", "/setadminpw" ]

# === Finalize ===

VOLUME [ /exist/data/export, \
         /exist/logs, \
         /exist/etc \
       ]

EXPOSE ${HTTP_PORT} ${HTTPS_PORT}

# HEALTHCHECK CMD [ "java", \
#     "org.exist.start.Main", "client", \
#     "--no-gui", \
#     "--user", "guest", "--password", "guest", \
#     "--xpath", "system:get-version()" ]
