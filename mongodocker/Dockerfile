FROM mongo:4.0


RUN apt-get update && apt-get install -y curl 

COPY resources/import_distances.sh /docker-entrypoint-initdb.d/import_distances.sh
RUN chmod +x /docker-entrypoint-initdb.d/import_distances.sh


EXPOSE 27017