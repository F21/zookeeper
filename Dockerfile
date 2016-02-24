# Zookeeper 3.4.7

FROM f21global/java:8
MAINTAINER Francis Chuang <francis.chuang@boostport.com>

ENV EXHIBITOR_VER 1.5.6
ENV ZOOKEEPER_VER 3.4.8

RUN groupadd zookeeper \
    && adduser --system --home /opt/zookeeper --disabled-login --ingroup zookeeper zookeeper \
    && apt-get update \
    && apt-get install -y wget \
    && wget -q -O - http://apache.mirror.serversaustralia.com.au/zookeeper/zookeeper-${ZOOKEEPER_VER}/zookeeper-${ZOOKEEPER_VER}.tar.gz | tar -xzf - -C /opt/zookeeper --strip-components 1 \
    && chown -R zookeeper:zookeeper /opt/zookeeper

RUN apt-get install -y ca-certificates maven\
    && mkdir -p /tmp/exhibitor \
    && wget -O /tmp/exhibitor/pom.xml https://raw.githubusercontent.com/Netflix/exhibitor/v${EXHIBITOR_VER}/exhibitor-standalone/src/main/resources/buildscripts/standalone/maven/pom.xml \
    && cd /tmp/exhibitor \
    && mvn clean package \
    && mkdir -p /opt/exhibitor \
    && mv /tmp/exhibitor/target/exhibitor-1.5.5.jar /opt/exhibitor/exhibitor.jar \
    && rm -rf /tmp/exhibitor \
    && apt-get purge --auto-remove maven -y \
    && mkdir -p /var/lib/zookeeper/data \
    && chown -R zookeeper:zookeeper /opt/exhibitor \
    && chown -R zookeeper:zookeeper /var/lib/zookeeper

RUN arch="$(dpkg --print-architecture)" \
	&& set -x \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.7/gosu-$arch" \
	&& chmod +x /usr/local/bin/gosu

ADD run-exhibitor.sh /run-exhibitor.sh

VOLUME ["/var/lib/zookeeper/data"]

EXPOSE 2181 2888 3888 8080

CMD ["/run-exhibitor.sh"]