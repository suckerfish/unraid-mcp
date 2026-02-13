FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir uv==0.8.15

COPY pyproject.toml uv.lock README.md ./
COPY unraid_mcp/ ./unraid_mcp/

RUN uv pip install --system --no-cache .

RUN useradd --create-home appuser
USER appuser

EXPOSE 6970

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -sf -o /dev/null -w '%{http_code}' http://localhost:6970/mcp | grep -q '406' || exit 1

CMD ["unraid-mcp-server"]
