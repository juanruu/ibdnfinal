FROM bitnami/kafka:3.9

WORKDIR /opt/bitnami/kafka

# Copia el archivo de configuración y el script
COPY kafkadocker/server.properties /opt/bitnami/kafka/config/server.properties
COPY kafkadocker/start-kafka.sh /opt/bitnami/kafka/start-kafka.sh

# Cambia permisos y dueño para que user 1001 pueda leerlo
USER root
RUN chmod 644 /opt/bitnami/kafka/config/server.properties && \
    chown 1001:1001 /opt/bitnami/kafka/config/server.properties && \
    chmod +x /opt/bitnami/kafka/start-kafka.sh

# Cambia al usuario no root de bitnami
USER 1001

ENTRYPOINT ["/opt/bitnami/kafka/start-kafka.sh"]
