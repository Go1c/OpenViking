# OpenViking Server - installs from PyPI (pre-compiled binaries included)
FROM python:3.13-slim-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    libstdc++6 \
 && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir openviking

# Entrypoint: generates /app/ov.conf from environment variables at startup.
# Strip Windows CRLF line endings before making executable.
COPY docker-entrypoint-server.sh /docker-entrypoint.sh
RUN sed -i 's/\r$//' /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh

RUN mkdir -p /app/data

ENV OPENVIKING_CONFIG_FILE="/app/ov.conf"

EXPOSE 1933

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD curl -fsS http://127.0.0.1:1933/health || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["openviking-server"]
