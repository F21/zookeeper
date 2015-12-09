# Zookeeper 3.4.7

FROM f21global/java:8
MAINTAINER Francis Chuang <francis.chuang@boostport.com>

ENV EXHIBITOR_VER 1.5.5
ENV ZOOKEEPER_VER 3.4.7

RUN apt-get update \
    && apt-get install -y wget \
    && wget -q -O - http://apache.mirror.serversaustralia.com.au/zookeeper/zookeeper-${ZOOKEEPER_VER}/zookeeper-${ZOOKEEPER_VER}.tar.gz | tar -xzf - -C /opt \
    && mv /opt/zookeeper-${ZOOKEEPER_VER} /opt/zookeeper

RUN apt-get install -y ca-certificates maven\
    && mkdir -p /tmp/exhibitor \
    && wget -O /tmp/exhibitor/pom.xml https://raw.githubusercontent.com/Netflix/exhibitor/v${EXHIBITOR_VER}/exhibitor-standalone/src/main/resources/buildscripts/standalone/maven/pom.xml \
    && cd /tmp/exhibitor \
    && mvn clean package \
    && mkdir -p /opt/exhibitor \
    && mv /tmp/exhibitor/target/exhibitor-1.0.jar /opt/exhibitor/exhibitor.jar \
    && rm -rf /tmp/exhibitor \
    && apt-get purge --auto-remove maven -y \
    && mkdir -p /var/lib/zookeeper/data

ADD exhibitor.properties /opt/exhibitor/exhibitor.properties
ADD run-exhibitor.sh /opt/exhibitor/run-exhibitor.sh

EXPOSE 2181 2888 3888 8080

WORKDIR /opt/exhibitor

CMD ["/opt/exhibitor/run-exhibitor.sh"]