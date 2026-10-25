# API image for Cloud Run.
#
#   docker build -t doubt-api .
#   docker run -p 8080:8080 doubt-api
FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS build

WORKDIR /app
ENV UV_LINK_MODE=copy UV_COMPILE_BYTECODE=1 UV_PYTHON_DOWNLOADS=never

COPY pyproject.toml uv.lock .python-version ./
RUN uv sync --frozen --no-install-project --no-dev

FROM python:3.13-slim-bookworm

WORKDIR /app
RUN useradd --system --uid 10001 app
COPY --from=build /app/.venv /app/.venv
COPY app ./app

ENV PATH="/app/.venv/bin:${PATH}" PYTHONUNBUFFERED=1 PORT=8080
USER app
CMD ["sh", "-c", "exec uvicorn app.main:app --host 0.0.0.0 --port ${PORT} --proxy-headers --forwarded-allow-ips='*'"]
