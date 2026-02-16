# Dockerfile for Salamanca eXist-db Webapp
#
# Build image with
# . .env && time TMPDIR="/home/awagner/Temp" buildah bud --secret=id=setadminpw,src=./.setadminpw --build-arg SVN_USER=${SVN_USER} --build-arg SVN_PASS=${SVN_PASS} --build-arg EXIST_USER=${EXIST_USER} --build-arg EXIST_PASS=${EXIST_PASS} -t ghcr.io/digicademy/svsal/svsal-exist:3.0rc2 -f Dockerfile .
#
# Then run with
#   buildah from svsal-exist
#   buildah run --tty -p 8080:8080 -p 8443:8443 svsal-exist-working-container /bin/bash
#
# or
#   podman run --rm -it -p 8080:8080 -p 8443:8443 --name exist ghcr.io/digicademy/svsal/svsal-exist:3.0rc2
#     perhaps add mount options:
#       -v svsal-webdata:/var/data/exist/data/export -v $(pwd)/tmp/logs:/exist/logs
#
# This is the last working podman run command:
#
#  stats_dictpodman run --rm -it -p 8080:8080 -p 8443:8443 --name=exist -v ./existexport:/exist/data/export -v ./exist/log:/exist/logs ghcr.io/digicademy/svsal/svsal-exist:3.0rc2
#
# These are (systemd service unit) podman parameters used in production,
# whether they make sense depends on the environment the container is being run in:
#
# -e JAVA_TOOL_OPTIONS='-Xmx10g -Xms10g -XX:MaxRAMPercentage=75.0'

# === STAGE 1 ===

# FROM openjdk:8-jdk-slim as builder
FROM eclipse-temurin:21-jre-jammy as builder

USER root

# Install tools required to build eXist apps
WORKDIR /usr/local
RUN apt-get update && apt-get -y install apt-utils && apt-get -y dist-upgrade && apt-get install -y --no-install-recommends \
  git \
  git-svn \
  curl \
  ca-certificates \
  gnupg \
  openssh-client \
  ant

# add github.com host key
RUN mkdir -p ~/.ssh && ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

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
  && cp build/*.xar /tmp;

# -- svsal --

ARG APP2_NAME=svsal
ARG APP2_REPO=https://github.com/digicademy/svsal.git
ARG APP2_TAG_OR_BRANCH=feature/cicd

# Build the app
RUN  git clone -b ${APP2_TAG_OR_BRANCH} --single-branch ${APP2_REPO} \
  && cd ${APP2_NAME} \
  # && echo Checking out ${APP2_TAG_OR_BRANCH} \
  # && git checkout ${APP2_TAG_OR_BRANCH} \
  && ant \
  && cp build/*.xar /tmp;

# -- svsal-tei --

ARG APP3_REPO=https://svn.adwmainz.net/04-39/trunk/svsal-tei
ARG APP3_PATH=svsal-tei

# Build the app
RUN echo ${SVN_PASS} | git svn clone --username ${SVN_USER} ${APP3_REPO} \
  && cd ${APP3_PATH} \
  && ant \
  && cp build/*.xar /tmp;

# -- svsal-webdata --

ARG APP4_REPO=https://svn.adwmainz.net/04-39/trunk/svsal-webdata
ARG APP4_PATH=svsal-webdata

# Build the app
RUN echo ${SVN_PASS} | git svn clone --username ${SVN_USER} ${APP4_REPO} \
  && cd ${APP4_PATH} \
  && ant \
  && cp build/*.xar /tmp;

# -- other eXist apps and libraries --

ARG TEMPLATING_VERSION=1.2.1
ARG EXPATH_BIN_VERSION=1.0.1
ARG FUNCTX_VERSION=1.0.1

RUN curl -L -o /tmp/templating-${TEMPLATING_VERSION}.xar http://exist-db.org/exist/apps/public-repo/public/templating-${TEMPLATING_VERSION}.xar
RUN curl -L -o /tmp/expath-bin-${EXPATH_BIN_VERSION}.xar http://exist-db.org/exist/apps/public-repo/public/expath-bin-module-${EXPATH_BIN_VERSION}.xar
RUN curl -L -o /tmp/functx-${FUNCTX_VERSION}.xar http://exist-db.org/exist/apps/public-repo/public/functx-${FUNCTX_VERSION}.xar

RUN echo "Contents of /tmp:"
RUN ls -la /tmp



# === STAGE 2 ===

FROM existdb/existdb:6.4.0-DEBUG

LABEL org.opencontainers.image.source https://github.com/digicademy/svsal
LABEL org.opencontainers.image.description "The School of Salamanca. XQuery Web Application"
LABEL org.opencontainers.image.licenses MIT

# These are the labels of the existdb-6.4.0-DEBUG image:
# Build-time metadata as defined at http://label-schema.org
# and used by autobuilder @hooks/build
# LABEL org.label-schema.build-date=${maven.build.timestamp} \
#       org.label-schema.description="${project.description} (DEBUG version)" \
#       org.label-schema.name="existdb-debug" \
#       org.label-schema.schema-version="1.0" \
#       org.label-schema.url="${project.url}" \
#       org.label-schema.vcs-ref=${build-commit-abbrev} \
#       org.label-schema.vcs-url="${project.scm.url}" \
#       org.label-schema.vendor="existdb"

ARG EXIST_USER
ARG EXIST_PASS

ARG TOOLS="bash less curl ca-certificates wget gpg ant mlocate apt-transport-https"
ARG JDK="temurin-8-jdk"
ARG UTILS="git git-svn htop jq vim"
ARG LATEX="biber latexmk texlive-latex-recommended texlive-fonts-recommended texlive-latex-extra texlive-fonts-extra texlive-lang-all"

RUN apt-get update && apt-get -y install apt apt-utils && \
  apt-get -y dist-upgrade && \
  apt-get install -y --no-install-recommends \
  ${TOOLS}

RUN wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null
RUN echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list

RUN apt-get update && apt-get install -y --no-install-recommends \
  ${JDK} \
  ${UTILS} \
  ${LATEX}

# populate locate database
RUN updatedb

# TODO: update local ssl certificate

# Copy Salamanca files
COPY --from=builder /tmp/*.xar                   /exist/autodeploy/
COPY etc/log4j2.xml etc/conf.xml                 /exist/etc/
COPY etc/jetty-ssl-context.xml etc/keystore.p12  /exist/etc/jetty/
# COPY etc/web.xml                              /exist/etc/webapp/WEB-INF/
# COPY etc/controller-config.xml                /exist/etc/webapp/WEB-INF/
# COPY etc/standard.enabled-jetty-configs       /exist/etc/jetty/

# Configure JVM for use in container (here be dragons)
# also sets default values to previous two arguments
ENV JAVA_TOOL_OPTIONS \
  -Dfile.encoding=UTF8 \
  -Dsun.jnu.encoding=UTF-8 \
  -Djava.awt.headless=true \
  -Dorg.exist.db-connection.cacheSize=${CACHE_MEM:-256}M \
  -Dorg.exist.db-connection.pool.max=${MAX_BROKER:-20} \
  -Dlog4j.configurationFile=/exist/etc/log4j2.xml \
  -Dexist.home=/exist \
  -Dexist.configurationFile=/exist/etc/conf.xml \
  -Dexist.jetty.config=/exist/etc/jetty/standard.enabled-jetty-configs \
  -Djetty.home=/exist \
  -XX:+UseG1GC \
  -XX:+UseStringDeduplication \
  -XX:+UseContainerSupport \
  -XX:MaxRAMPercentage=${JVM_MAX_RAM_PERCENTAGE:-75.0} \
  -XX:+ExitOnOutOfMemoryError \
  -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005

# pre-populate the database by launching it once
# this presupposes a secret file ".setadminpw" containing "sm:passwd('admin','123')"
# being passed via --secret=id=setadminpw,src=./.setadminpw to the build process
RUN --mount=type=secret,id=setadminpw,target=setadminpw ["java", "org.exist.start.Main", "client", "--no-gui", "-l", "-u", "admin", "-P", "", "-F", "/setadminpw" ]

# === Finalize ===

VOLUME [ /exist/data/export, \
         /exist/logs, \
         /exist/etc \
      ]

EXPOSE 8080 8443

HEALTHCHECK CMD [ "java", \
    "org.exist.start.Main", "client", \
    "--no-gui", \
    "--user", "guest", "--password", "guest", \
    "--xpath", "system:get-version()" ]

# 6.4.0-Debug Dockerfile:
CMD [ "java", "org.exist.start.Main", "jetty" ]
