FROM python:3.11-slim
WORKDIR /app
COPY /scripts/container_entrypoint.sh /app/container_entrypoint.sh
RUN chmod +x /app/container_entrypoint.sh
RUN apt-get update && apt-get install -y --no-install-recommends jq ca-certificates && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["/app/container_entrypoint.sh"]