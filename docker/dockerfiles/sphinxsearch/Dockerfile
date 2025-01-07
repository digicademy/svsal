# Sphinx Search
#
# @author 	andreas wagner <wagner@lhlt.mpg.de>
#
# Build image with
# time TMPDIR="/home/awagner/Temp" buildah bud -t ghcr.io/digicademy/svsal/svsal-sphinxsearch:2.2.11rc1 -f Dockerfile .
#
# Then run with
#   buildah from svsal-sphinxsearch
#   buildah run --tty         -p 9312:9312 -p 9306:9306 -p 8081:80 svsal-sphinxsearch-working-container /bin/sh
#
# or
#   podman run --tty --rm -it -p 9312:9312 -p 9306:9306 -p 8081:80 --name sphinxsearch ghcr.io/digicademy/svsal/svsal-sphinxsearch:2.2.11rc1
#
#     perhaps add mount options:
#       -v ./sphinx/etc:/etc/sphinx
#       -v ./sphinx/index:/var/lib/sphinx/data
#       -v ./sphinx/log:/var/log/dockerservices
#       -v ./sphinx/opensphinxsearch:/opt/opensphinxsearch
#       -v ./existexport:/var/data/existdb/data/export
#
#     taken together, and assuming there are subdirectories ./sphinx/{index,log,etc,opensphinxsearch} and ./existexport, this could be:
#   podman run --rm -it --tty -p 8022:22 -p 9312:9312 -p 9306:9306 -p 8081:80 -v ./sphinx/log:/var/log/dockerservices -v ./sphinx/etc:/etc/sphinx -v ./sphinx/index:/var/lib/sphinx/data -v ./sphinx/opensphinxsearch:/opt/opensphinxsearch -v ./existexport:/var/data/existdb/data/export --name sphinxsearch ghcr.io/digicademy/svsal/svsal-sphinxsearch:2.2.11rc1
#     currently, the pasta network does not work when no upstream network is available (host is offline), so we might need to use slirp4netns:
#   podman run --rm -it --tty -p 8022:22 -p 9312:9312 -p 9306:9306 -p 8081:80 -v ./sphinx/log:/var/log/dockerservices -v ./sphinx/etc:/etc/sphinx -v ./sphinx/index:/var/lib/sphinx/data -v ./sphinx/opensphinxsearch:/opt/opensphinxsearch -v ./existexport:/var/data/existdb/data/export --name sphinxsearch ghcr.io/digicademy/svsal/svsal-sphinxsearch:2.2.11rc1 --network=slirp4netns:allow_host_loopback=true
#
# This is the last working podman run command:
#
#   podman run --rm -it --tty -p 9312:9312 -p 9306:9306 -p 8081:80 -v ./sphinx/log:/var/log/dockerservices -v ./sphinx/etc:/etc/sphinx -v ./sphinx/index:/var/lib/sphinx/data -v ./sphinx/opensphinxsearch:/opt/opensphinxsearch -v ./existexport:/var/data/existdb/data/export --name sphinxsearch ghcr.io/digicademy/svsal/svsal-sphinxsearch:2.2.11rc1
#
# if all is well, upload (after podman login/buildah login) with
#   buildah push svsal-sphinxsearch ghcr.io/digicademy/svsal/svsal-sphinxsearch:2.2.11rc1
# or
#   podman push ghcr.io/digicademy/svsal/svsal-sphinxsearch:2.2.11rc1
#
# When deploying, set SERVER_NAME with a build argument, e.g.:
#   `--build-arg SERVER_NAME="search.salamanca.school"` or `--build-arg SERVER_NAME=${SERVER_NAME}` (where SERVER_NAME is set in the environment)
#
# As of 2024-12-16, this installs
# - php7.4
# - sphinxsearch 2.2.11

FROM php:7.4.29-fpm-alpine3.14

LABEL org.opencontainers.image.source https://github.com/digicademy/svsal
LABEL org.opencontainers.image.description "The School of Salamanca. (Open)Sphinxsearch Application"
LABEL org.opencontainers.image.licenses MIT

ARG PHP_EXTENSIONS="bz2 intl" \
    SERVER_NAME=":80" \
    LOG_DIR=/var/log/dockerservices/

ENV LOG_DIR=${LOG_DIR} \
    SPHINX_LOG_DIR=${LOG_DIR} \
    CRON_LOG_DIR=${LOG_DIR} \
    CADDY_LOG_DIR=${LOG_DIR} \
    PHP_LOG_DIR=${LOG_DIR} \
    SPHINX_CONF_DIR=/etc/sphinx/ \
    SPHINX_RUN_DIR=/run/sphinx/ \
    SPHINX_HOME_DIR=/var/lib/sphinx/ \
    SPHINX_INDEX_DIR=${SPHINX_HOME_DIR}data/ \
    SPHINX_USER=sphinx \
    SPHINX_GROUP=sphinx \
    OPENSPHINXSEARCH_DIR=/opt/opensphinxsearch/ \
    SALAMANCA_DATA=/var/data/existdb/data/export/



# === Install System Packages

RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/community" >> /etc/apk/repositories

RUN apk update && \
    apk del php8 php8-phar composer && \
    apk upgrade

RUN apk add openrc \
    busybox-initscripts \
    logrotate \
    util-linux \
    caddy \
    'sphinx<3' \
    php7 \
    php7-fpm \
    composer \
    curl \
    wget \
    git \
    vim



# === Configure PHP and Caddy

COPY etc/php.ini etc/php-fpm.conf   /etc/php7/
COPY etc/www.conf                   /etc/php7/php-fpm.d/www.conf
COPY etc/Caddyfile                  /etc/caddy/Caddyfile
# COPY etc/99-php-fpm.ini             /etc/php7/conf.d/99-php-fpm.ini




# === Configure Sphinxsearch

# Add sphinx user and group and set permissions
RUN addgroup -S ${SPHINX_GROUP} && \
    adduser -S ${SPHINX_USER} -G ${SPHINX_GROUP} -h ${SPHINX_LOG_DIR} -s /sbin/nologin

# prepare directories
RUN mkdir -p -m 777 ${LOG_DIR} && \
    mkdir -p -m 777 ${SPHINX_CONF_DIR} && \
    mkdir -p -m 777 ${SPHINX_RUN_DIR} && \
    mkdir -p -m 777 ${SPHINX_INDEX_DIR} && \
    chown -R ${SPHINX_USER}:${SPHINX_GROUP} ${SPHINX_HOME_DIR} && \
    chown -R ${SPHINX_USER}:${SPHINX_GROUP} ${SPHINX_RUN_DIR} && \
    chown -R ${SPHINX_USER}:${SPHINX_GROUP} ${SPHINX_CONF_DIR} && \
    mkdir -p -m 777 ${OPENSPHINXSEARCH_DIR}views && \
    mkdir -p -m 777 ${OPENSPHINXSEARCH_DIR}templates && \
    mkdir -p -m 777 ${SALAMANCA_DATA} && \
    mkdir -p -m 777 /tmp/opensphinxsearch/views && \
    mkdir -p -m 777 /tmp/opensphinxsearch/templates && \
    mkdir -p -m 777 /tmp/sphinx && \
    mkdir -p -m 777 /tmp/salamancadata

# add Salamanca sphinxsearch customization/configuration
COPY --chmod=775 \
    scripts/fixns.sh \
    scripts/index-all.sh \
    scripts/xmlpipe.sh \
    /usr/bin/

COPY etc/stopwords*.txt \
     etc/wordforms*.txt \
     etc/sphinx.conf \
     etc/base.conf \
     etc/index-svsal.conf \
     etc/sal-schema.xml \
     ${SPHINX_CONF_DIR}

# add one dummy search snippet so that sphinxsearch startup can succeed
COPY etc/dummy.snippet.xml ${SALAMANCA_DATA}


# Copy the customization to an extra temporary location so that we can re-add it
# if the container is launched with an empty volume mounted at /etc/sphinx
# (this re-adding happens in the startup-init OpenRC script)
COPY etc/stop*.txt \
     etc/wordforms*.txt \
     etc/sphinx.conf \
     etc/base.conf \
     etc/index-svsal.conf \
     etc/sal-schema.xml \
     /tmp/sphinx/

COPY etc/dummy.snippet.xml /tmp/salamancadata


# add cronjob for indexer to pick up new materials even without restarting sphinxsearch/container
RUN echo "30 03 * * * indexer --quiet --rotate --all | grep -v 'duplicate' > /var/log/dockerservices/indexer.log" > /etc/crontabs/root



# === Install OpenSphinxsearch

# Stock OpenSphinxsearch Files
RUN cd && \
    git clone https://github.com/awagner-mainz/open-sphinxsearch.git && \
    cd open-sphinxsearch && \
    cp -r * ${OPENSPHINXSEARCH_DIR} && \
    cp -r * /tmp/opensphinxsearch/ && \
    cd ${OPENSPHINXSEARCH_DIR} && \
    composer install && \
    cd /tmp/opensphinxsearch/ && \
    composer install && \
    cd && \
    rm -rf open-sphinxsearch

# Salamanca OpenSphinxsearch (PHP) Customizations
RUN cd && \
    git clone -b v3 https://github.com/digicademy/svsal-website && \
    cd svsal-website/ && \
    cp searchengine/sal-oss-customizations/configuration.json ${OPENSPHINXSEARCH_DIR} && \
    cp searchengine/sal-oss-customizations/templates/* ${OPENSPHINXSEARCH_DIR}templates/ && \
    cp searchengine/sal-oss-customizations/configuration.json /tmp/opensphinxsearch/ && \
    cp searchengine/sal-oss-customizations/templates/* /tmp/opensphinxsearch/templates/ && \
    cd && \
    rm -rf svsal-website



# === Configure OpenRC Daemon Controller

RUN mkdir -p /run/openrc && \
    touch /run/openrc/softlevel

# Tell openrc its running inside a container, till now that has meant LXC
RUN sed -i 's/#rc_sys=""/rc_sys="lxc"/g' /etc/rc.conf && \
# Tell openrc loopback and net are already there, since docker handles the networking
    echo 'rc_provide="loopback net"' >> /etc/rc.conf && \
# no need for loggers
    sed -i 's/^#\(rc_logger="YES"\)$/\1/' /etc/rc.conf && \
# rc log output should do /var/log/dockerservices/rc.log
    sed -i 's/^#rc_log_path="\/var\/log\/rc.log"/rc_log_path="\/var\/log\/dockerservices\/rc.log"/g' /etc/rc.conf && \
# direct syslogd output to ${LOG_DIR}/syslog
    echo 'SYSLOGD_OPTS="-t -O /var/log/dockerservices/syslog.log"' > /etc/conf.d/syslog && \
# can't get ttys unless you run the container in privileged mode
    sed -i '/tty/d' /etc/inittab && \
# can't set hostname since docker sets it
    sed -i 's/hostname $opts/# hostname $opts/g' /etc/init.d/hostname && \
# can't mount tmpfs since not privileged
    sed -i 's/mount -t tmpfs/# mount -t tmpfs/g' /lib/rc/sh/init.sh && \
# can't do cgroups
    sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh && \
# clean apk cache
    rm -rf /var/cache/apk/*



# === Enable Services

COPY --chmod=775 scripts/startup-init /etc/init.d/startup-init

RUN rc-update add caddy        default && \
    rc-update add sphinx       default && \
    rc-update add crond        default && \
    rc-update add php-fpm7     default && \
    rc-update add startup-init boot    && \
    rc-update add syslog       boot



# === Diagnostics

RUN head -n 100 /etc/sphinx/wordforms-united.txt



# === Finalize

# expose directories
VOLUME [ "${SPHINX_CONF_DIR}", \
         "${SPHINX_INDEX_DIR}", \
         "${LOG_DIR}", \
         "${OPENSPHINXSEARCH_DIR}", \
         "${SALAMANCA_DATA}" , \
         "/sys/fs/cgroup" \
       ]

# expose ports
EXPOSE 80 9312 9306

WORKDIR "${SPHINX_CONF_DIR}"

# ENTRYPOINT ["entrypoint.sh"]
CMD ["/sbin/init"]
