# --- Etapa 1: Constructor (Builder) ---
FROM python:3.11-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# ✅ CORREGIDO: Se añade "pip install" después de definir el montaje de la caché
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# --- Etapa 2: Imagen Final (Producción) ---
FROM python:3.11-slim

WORKDIR /app

# ✅ CORREGIDO: Eliminado apt-get. Dependencias puramente estáticas en python.
COPY --from=builder /install /usr/local

# ✅ CORREGIDO: Se crea el usuario ANTES y se inyectan los archivos con el propietario correcto en un solo paso
RUN useradd -m devopsuser

COPY --chown=devopsuser:devopsuser . .

USER devopsuser

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
