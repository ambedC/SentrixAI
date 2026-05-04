# ──────────────────────────────────────────────────────────────
# Minimal, Render-compatible Dockerfile for SentrixAI backend
# No GPU, no ML inference, no uv – plain pip + requirements.txt
# ──────────────────────────────────────────────────────────────
FROM python:3.10-slim

# Sane Python defaults for containers
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Minimal system libs required only for opencv-python-headless
# libgl1 replaces deprecated libgl1-mesa-glx on Debian Bullseye/Bookworm slim
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libgl1 \
        libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies first (layer-cached separately from source code)
COPY backend/requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application source
COPY backend/ ./backend/

# Create runtime directories the app expects (non-restricted paths)
RUN mkdir -p backend/uploads backend/assets/videos

# Render injects $PORT at runtime; default to 10000 for local testing
EXPOSE 10000

CMD ["sh", "-c", "uvicorn backend.main:app --host 0.0.0.0 --port ${PORT:-10000}"]
