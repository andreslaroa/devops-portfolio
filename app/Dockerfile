# --- Etapa 1: Constructor (Builder) ---
FROM python:3.11-slim AS builder

WORKDIR /app

# Instalar dependencias del sistema necesarias para compilar ciertas librerías de Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Descargamos las dependencias en una carpeta local llamada /install
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# --- Etapa 2: Imagen Final (Producción) ---
FROM python:3.11-slim

WORKDIR /app

# Instalar solo la librería en tiempo de ejecución para PostgreSQL
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Copiamos solo las librerías instaladas en la etapa anterior (pesa mucho menos)
COPY --from=builder /install /usr/local
COPY . .

# BUENA PRÁCTICA DE SEGURIDAD: No correr el contenedor como Root
RUN useradd -m devopsuser && chown -R devopsuser:devopsuser /app
USER devopsuser

EXPOSE 8000

# Comando para arrancar la API con Uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
