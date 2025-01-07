# This file is coming from <https://github.com/apache/any23-server>
#
# Build image with
# time TMPDIR="/home/awagner/Temp" buildah bud -t ghcr.io/digicademy/svsal/svsal-any23:2.3rc2 -f Dockerfile .
#
# Then run with
#   buildah from svsal-any23
#   buildah run --tty -p 8082:8082 svsal-any23-working-container /bin/bash
#
# or
#   podman run --rm -it -p 8082:8082 --name any23 ghcr.io/digicademy/svsal/svsal-any23:2.3rc2
#
# This is the last working podman run command:
#
#   podman run --rm -it -p 8082:8082 --name any23 ghcr.io/digicademy/svsal/svsal-any23:2.3rc2
#
# if all is well, upload with
#   buildah push svsal-any23 ghcr.io/digicademy/svsal/svsal-any23:2.3rc2
# or
#   podman push ghcr.io/digicademy/svsal/svsal-any23:2.3rc2
#
# These are (systemd service unit) parameters used in svsal production,
# whether they make sense depends on the environment the container is being run in:
#
# /usr/lib/jvm/java-8-openjdk-amd64/bin/java \
#   -Xms500m -Xmx500m -XX:PermSize=128m \
#   -XX:-UseGCOverheadLimit \
#   -Djava.net.preferIPv4Stack=true \
#   -jar jetty-runner-9.4.8.v20171121.jar \
#   --port 8082 \
#   --path /any23 \
#   apache-any23-service-2.3.war

FROM tomcat:9

LABEL org.opencontainers.image.source https://github.com/digicademy/svsal
LABEL org.opencontainers.image.description "The School of Salamanca. Any23 Application"
LABEL org.opencontainers.image.licenses MIT

ENV ANY23_VERSION=2.3
RUN apt-get update && apt-get -y upgrade

WORKDIR /usr/local/tomcat

COPY etc/tomcat-users.xml /usr/local/tomcat/conf/tomcat-users.xml
COPY etc/context.xml      /usr/local/tomcat/webapps/manager/META-INF/context.xml
COPY var/apache-any23-service-${ANY23_VERSION}.war /usr/local/tomcat/webapps/any23.war
RUN sed -i 's/port="8080"/port="8082"/' ${CATALINA_HOME}/conf/server.xml

# RUN mv /usr/local/tomcat/webapps /usr/local/tomcat/webapps2 && \
#     mv /usr/local/tomcat/webapps.dist /usr/local/tomcat/webapps

# https://archive.apache.org/dist/any23/${ANY23_VERSION}/apache-any23-service-${ANY23_VERSION}-src.tar.gz

EXPOSE 8082
