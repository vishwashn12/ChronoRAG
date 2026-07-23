FROM python:3.10-slim

# Install Node.js for building frontend
RUN apt-get update && apt-get install -y curl gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs gcc g++ \
    && rm -rf /var/lib/apt-get/lists/*

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install Frontend dependencies and build React app
COPY frontend/package*.json ./frontend/
RUN cd frontend && npm install
COPY frontend/ ./frontend/
RUN cd frontend && npm run build

# Copy Backend code
COPY backend/ ./backend/
COPY .env .env

# Run document ingestion to pre-populate database
RUN python backend/ingest.py

# Expose port
EXPOSE 8000

# Start server
CMD ["uvicorn", "backend.server:app", "--host", "0.0.0.0", "--port", "8000"]
