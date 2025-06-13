#!/bin/bash

CONFIG_FILE=/opt/bitnami/kafka/config/server.properties
DATA_DIR=/bitnami/kafka/data

# Formatear almacenamiento solo si no existe
if [ ! -f "$DATA_DIR/meta.properties" ]; then
    echo "[INFO] No se encontró meta.properties, generando cluster ID..."
    KAFKA_CLUSTER_ID=$(/opt/bitnami/kafka/bin/kafka-storage.sh random-uuid)
    echo "[INFO] Formateando almacenamiento con cluster ID $KAFKA_CLUSTER_ID..."
    /opt/bitnami/kafka/bin/kafka-storage.sh format -t "$KAFKA_CLUSTER_ID" -c "$CONFIG_FILE" --ignore-formatted
else
    echo "[INFO] Almacenamiento ya formateado, meta.properties encontrado."
fi

# Iniciar Kafka con KRaft
echo "[INFO] Iniciando Kafka..."
/opt/bitnami/kafka/bin/kafka-server-start.sh "$CONFIG_FILE" &

# Esperar a que arranque el broker
sleep 10

# Crear el topic si no existe
echo "[INFO] Creando topic 'flight-delay-ml-request'..."
/opt/bitnami/kafka/bin/kafka-topics.sh --create --if-not-exists \
  --bootstrap-server kafkaibdn:9092 \
  --replication-factor 1 \
  --partitions 1 \
  --topic flight-delay-ml-request

/opt/bitnami/kafka/bin/kafka-topics.sh --create --if-not-exists \
  --bootstrap-server kafkaibdn:9092 \
  --replication-factor 1 \
  --partitions 1 \
  --topic flight-delay-ml-response

# Mantener contenedor vivo
tail -f /dev/null
