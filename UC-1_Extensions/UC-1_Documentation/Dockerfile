FROM python:3.11-alpine

# Set working directory
WORKDIR /docs

# Install system dependencies
RUN apk add --no-cache \
    git \
    build-base \
    libffi-dev \
    && rm -rf /var/cache/apk/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy documentation source
COPY . .

# Expose port
EXPOSE 8000

# Command to serve documentation
CMD ["mkdocs", "serve", "--dev-addr=0.0.0.0:8000", "--no-livereload"]