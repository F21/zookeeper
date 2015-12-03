#!/usr/bin/env bash

java -jar exhibitor.jar --hostname $(awk 'NR==1 {print $1}' /etc/hosts) --defaultconfig /opt/exhibitor/exhibitor.properties -c "$@"