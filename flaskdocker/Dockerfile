FROM python:3.7-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Definir el directorio de trabajo
WORKDIR /app


# Instalar dependencias necesarias del sistema
RUN apt-get update && apt-get install -y procps && rm -rf /var/lib/apt/lists/*

# Copiar e instalar requerimientos de Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar solo los recursos necesarios para Flask
COPY . .

# Exponer el puerto en el que corre Flask
EXPOSE 5001

# Lanzar la app Flask
ENTRYPOINT ["python3", "/app/resources/web/predict_flask.py"]
