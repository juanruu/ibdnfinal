#!/bin/bash

/opt/spark/sbin/stop-master.sh
/opt/spark/sbin/stop-worker.sh
/opt/spark/sbin/stop-history-server.sh

ROLE=${ROLE:-master}
MASTER_NAME=${MASTER_NAME:-localhost}

if [ "$ROLE" = "master" ]; then
    /opt/spark/sbin/start-master.sh
    cd /practica_creativa/flight_prediction
    sbt package
/opt/spark/bin/spark-submit --class es.upm.dit.ging.predictor.MakePrediction \
  --packages org.mongodb.spark:mongo-spark-connector_2.12:10.4.1,org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.3 \
  --master spark://$MASTER_NAME:7077 \
  /practica_creativa/flight_prediction/target/scala-2.12/*.jar

elif [ "$ROLE" = "worker" ]; then
    WORKER_COUNT=${WORKER_COUNT:-1}
    for i in $(seq 1 $WORKER_COUNT); do
        /opt/spark/sbin/start-worker.sh spark://$MASTER_NAME:7077
        sleep 5
    done
else
    echo "ERROR: ROLE debe ser 'master' o 'worker'"
    exit 1
fi

tail -f /dev/null
