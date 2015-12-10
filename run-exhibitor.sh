#!/usr/bin/env bash

CMD="java -jar exhibitor.jar --defaultconfig /opt/exhibitor/exhibitor.properties --hostname $(awk 'NR==1 {print $1}' /etc/hosts)"

if [ "$CONFIGTYPE" = "file" ]; then

    CMD=$CMD" --configtype file"
    CMD=$CMD${FSCONFIGDIR:+" --fsconfigdir $FSCONFIGDIR"}
    CMD=$CMD${FSCONFIGLOCKPREFIX:+" --fsconfiglockprefix $FSCONFIGLOCKPREFIX"}
    CMD=$CMD${FSCONFIGNAMEX:+" --fsconfigname $FSCONFIGNAME"}

elif [ "$CONFIGTYPE" = "s3" ]; then

    CMD=$CMD" --configtype s3"
    CMD=$CMD${S3CREDENTIALS:+" --s3credentials $S3CREDENTIALS"}
    CMD=$CMD${S3REGION:+" --s3region $S3REGION"}
    CMD=$CMD${S3CONFIG:+" --s3config $S3CONFIG"}
    CMD=$CMD${S3CONFIGPREFIX:+" --s3configprefix $S3CONFIGPREFIX"}

elif [ "$CONFIGTYPE" = "zookeeper" ];then

    : ${ZKCONFIGCONNECT:?"ZKCONFIGCONNECT is required for the zookeeper configtype"}
    : ${ZKCONFIGZPATH:?"ZKCONFIGZPATH is required for the zookeeper configtype"}

    CMD=$CMD${ZKCONFIGCONNECT:+" --zkconfigconnect $ZKCONFIGCONNECT"}
    CMD=$CMD${ZKCONFIGEXHIBITORPATH:+" --zkconfigexhibitorpath $ZKCONFIGEXHIBITORPATH"}
    CMD=$CMD${ZKCONFIGEXHIBITORPORT:+" --zkconfigexhibitorport $ZKCONFIGEXHIBITORPORT"}
    CMD=$CMD${ZKCONFIGPOLLMS:+" --zkconfigpollms $ZKCONFIGPOLLMS"}
    CMD=$CMD${ZKCONFIGRETRY:+" --zkconfigretry $ZKCONFIGRETRY"}
    CMD=$CMD${ZKCONFIGZPATH:+" --zkconfigzpath $ZKCONFIGZPATH"}
else
    CMD=$CMD" --configtype none"
    CMD=$CMD${NONECONFIGDIR:+" --noneconfigdir $NONECONFIGDIR"}
fi

CMD=$CMD${CONFIGCHECKMS:+" --configcheckms $CONFIGCHECKMS"}
CMD=$CMD${HEADINGTEXT:+" --headingtext $HEADINGTEXT"}
CMD=$CMD${JQUERYSTYLE:+" --jquerystyle $JQUERYSTYLE"}
CMD=$CMD${LOGLINES:+" --loglines $LOGLINES"}
CMD=$CMD${NODEMODIFICATION:+" --nodemodification $NODEMODIFICATION"}
CMD=$CMD${PORT:+" --port $PORT"}
CMD=$CMD${PREFSPATH:+" --prefspath $PREFSPATH"}
CMD=$CMD${SERVO:+" --servo $SERVO"}
CMD=$CMD${TIMEOUT:+" --timeout $TIMEOUT"}

CMD=$CMD${FILESYSTEMBACKUP:+" --filesystembackup $FILESYSTEMBACKUP"}
CMD=$CMD${S3BACKUP:+" --s3backup $S3BACKUP"}

CMD=$CMD${REALM:+" --realm $REALM"}
CMD=$CMD${REMOTEAUTH:+" --remoteauth $REMOTEAUTH"}
CMD=$CMD${SECURITY:+" --security $SECURITY"}

CMD=$CMD${ACLID:+" --aclid $ACLID"}
CMD=$CMD${ACLPERMS:+" --aclperms $ACLPERMS"}
CMD=$CMD${ACLSCHEME:+" --aclscheme $ACLSCHEME"}

rm -f /opt/exhibitor/exhibitor.properties

echo "zookeeper-install-directory=/opt/zookeeper" >> /opt/exhibitor/exhibitor.properties
echo ${LOG_INDEX_DIRECTORY:+"log-index-directory=$LOG_INDEX_DIRECTORY"} >> /opt/exhibitor/exhibitor.properties
echo "zookeeper-data-directory=${ZOOKEEPER_DATA_DIRECTORY:=/var/lib/zookeeper/data}" >> /opt/exhibitor/exhibitor.properties
echo ${ZOOKEEPER_LOG_DIRECTORY:+"zookeeper-log-directory=$ZOOKEEPER_LOG_DIRECTORY"} >> /opt/exhibitor/exhibitor.properties
echo ${SERVERS_SPEC:+"servers-spec=$SERVERS_SPEC"} >> /opt/exhibitor/exhibitor.properties
echo ${BACKUP_EXTRA:+"backup-extra=$BACKUP_EXTRA"} >> /opt/exhibitor/exhibitor.properties
echo "zoo-cfg-extra=${ZOO_CFG_EXTRA:=syncLimit\=5\&tickTime\=2000\&initLimit\=10}" >> /opt/exhibitor/exhibitor.properties
echo "java-environment=${JAVA_ENVIRONMENT:=export JAVA_OPTS\=\"-Xms1000m -Xmx1000m\"}" >> /opt/exhibitor/exhibitor.properties
echo ${LOG4J_PROPERTIES:+"log4j-properties=$LOG4J_PROPERTIES"} >> /opt/exhibitor/exhibitor.properties
echo "client-port=${CLIENT_PORT:=2181}" >> /opt/exhibitor/exhibitor.properties
echo "connect-port=${CONNECT_PORT:=2888}" >> /opt/exhibitor/exhibitor.properties
echo "election-port=${ELECTION_PORT:=3888}" >> /opt/exhibitor/exhibitor.properties
echo "check-ms=${CHECK_MS:=2000}" >> /opt/exhibitor/exhibitor.properties
echo "cleanup-period-ms=${CLEANUP_PERIOD_MS:=200000}" >> /opt/exhibitor/exhibitor.properties
echo "cleanup-max-files=${CLEANUP_MAX_FILES:=10}" >> /opt/exhibitor/exhibitor.properties
echo ${BACKUP_MAX_STORE_MS:+"backup-max-store-ms=$BACKUP_MAX_STORE_MS"} >> /opt/exhibitor/exhibitor.properties
echo ${BACKUP_PERIOD_MS:+"backup-period-ms=$BACKUP_PERIOD_MS"} >> /opt/exhibitor/exhibitor.properties
echo "auto-manage-instances=${AUTO_MANAGE_INSTANCES:=1}" >> /opt/exhibitor/exhibitor.properties
echo "auto-manage-instances-settling-period-ms=${AUTO_MANAGE_INSTANCES_SETTLING_PERIOD_MS:=10000}" >> /opt/exhibitor/exhibitor.properties
echo "observer-threshold=${OBSERVER_THRESHOLD:=3}" >> /opt/exhibitor/exhibitor.properties
echo ${AUTO_MANAGE_INSTANCES_FIXED_ENSEMBLE_SIZE:+"auto-manage-instances-fixed-ensemble-size=$AUTO_MANAGE_INSTANCES_FIXED_ENSEMBLE_SIZE"} >> /opt/exhibitor/exhibitor.properties
echo ${AUTO_MANAGE_INSTANCES_APPLY_ALL_AT_ONCE:+"auto-manage-instances-apply-all-at-once=$AUTO_MANAGE_INSTANCES_APPLY_ALL_AT_ONCE"} >> /opt/exhibitor/exhibitor.properties

trap 'kill -TERM $PID' TERM INT

$CMD &
PID=$!

wait $PID
trap - TERM INT
wait $PID
exit 0