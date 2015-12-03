# Zookeeper 3.4.6

FROM ubuntu:14.04
MAINTAINER Francis Chuang <francis.chuang@boostport.com>

RUN apt-get update \
    && apt-get install -y software-properties-common wget \
    && add-apt-repository ppa:webupd8team/java \
    && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
    && apt-get update && apt-get install -y oracle-java8-installer oracle-java8-set-default \
    && apt-get purge --auto-remove software-properties-common -y

RUN wget -q -O - http://apache.mirror.serversaustralia.com.au/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz | tar -xzf - -C /opt \
    && mv /opt/zookeeper-3.4.6 /opt/zookeeper \
    && cp /opt/zookeeper/conf/zoo_sample.cfg /opt/zookeeper/conf/zoo.cfg \
    && mkdir -p /var/lib/zookeeper \
    && sed -i 's/dataDir=\/tmp\/zookeeper/dataDir=\/var\/lib\/zookeeper/g' /opt/zookeeper/conf/zoo.cfg

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

EXPOSE 2181 2888 3888

WORKDIR /opt/zookeeper

VOLUME ["/opt/zookeeper/conf", "/var/lib/zookeeper"]

ENTRYPOINT ["/opt/zookeeper/bin/zkServer.sh"]
CMD ["start-foreground"]