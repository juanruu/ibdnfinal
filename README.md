# Práctica Final - IBDN

Autores: Ignacio Moyano Fernández y Juan Pérez Picciolato  

Este proyecto consiste en el despliegue de una arquitectura distribuida que permite realizar **predicciones en tiempo real sobre retrasos de vuelos**, utilizando un modelo predictivo basado en **Random Forest** entrenado con datos históricos.

---

## Objetivo

A partir de un dataset de vuelos pasados (con información sobre si salieron con retraso o no), se entrena un modelo de predicción. La arquitectura desplegada permite recibir solicitudes de predicción en tiempo real y devolver resultados mediante una integración de servicios.

---

## Arquitectura desplegada

El sistema se divide en 4 partes principales:

---

### 1. Dockerización de la arquitectura base

Todos los servicios están contenidos en un `docker-compose.yml`, que despliega:

- **Flask**: API web desarrollada en Python que recibe solicitudes de predicción. Se basa en una imagen con los requerimientos instalados y ejecuta `predict_flask.py`.

- **Kafka**: Sistema de mensajería usando `bitnami/kafka:3.9`. Se despliega el tópico `flask-ml-delays-request` mediante un script `start-kafka.sh`.

- **Spark (bitnami/spark:3.5.3)**:
  - 1 contenedor para el **Spark Master**
  - 2 contenedores para los **Spark Workers**
  - 1 contenedor adicional para el **spark-submit**, que compila y ejecuta el código Scala para generar predicciones

- **MongoDB**: Base de datos NoSQL (`mongo:4.0`) que almacena los datos históricos utilizados por Spark para entrenar el modelo. Estos datos se insertan mediante el script `import_distances.sh`.

> El correcto despliegue del clúster de Spark puede observarse desde la interfaz web del Spark Master.

---

### 2. Escritura de las predicciones en Kafka

Inicialmente, las predicciones se guardaban en Mongo y Flask las consultaba desde ahí.

Posteriormente:
- Se creó un nuevo tópico `flask-ml-delays-responses`.
- Se añadió lógica en **Scala** para publicar las predicciones en ese tópico.
- Se modificó **Flask** para recuperar las predicciones directamente desde Kafka.

---

### 3. Integración con Apache NiFi

Se desplegó un servicio adicional usando la imagen `apache/nifi:1.25.0`, con acceso a su interfaz web protegida por credenciales.

- Desde la interfaz se definió un flujo que:
  - Lee las predicciones del tópico Kafka
  - Las guarda automáticamente en un archivo `.txt` cada 10 segundos
  - Usa dos **Producers** y un **Connector**

---

### 4. Almacenamiento de predicciones en HDFS

Se añadió soporte para almacenar las predicciones en un sistema de archivos distribuido (HDFS):

- Despliegue usando las imágenes:
  - `bde2020/hadoop-namenode:2.0.0-hadoop3.2.1-java8`
  - `bde2020/hadoop-datanode:2.0.0-hadoop3.2.1-java8`

- Se configuraron:
  - Un **NameNode** (gestiona el sistema de ficheros)
  - Un **DataNode** (almacena físicamente los archivos de predicción)

> La correcta escritura en HDFS puede validarse desde la interfaz web del NameNode o desde el contenedor.

---

## Tecnologías utilizadas

- Docker & Docker Compose
- Apache Kafka
- Apache Spark (Scala)
- Apache NiFi
- MongoDB
- Hadoop HDFS
- Flask (Python)
- SBT (Scala Build Tool)

