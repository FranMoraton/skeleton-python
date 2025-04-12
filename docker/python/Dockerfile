FROM python:3.12-slim AS base


COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

RUN --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --dev --no-cache

ENV PATH="/app/.venv/bin:$PATH"
ENV PATH=/root/.local/bin:$PATH

COPY . /app

EXPOSE 9000

FROM base AS development

CMD ["uv", "run", "fastapi", "dev", "--port", "9000", "--host", "0.0.0.0"]

FROM base AS prod

RUN uv sync --frozen --compile-bytecode

CMD ["uv", "run", "fastapi", "run", "--port", "9000", "--host", "0.0.0.0", "--workers", "20"]

#CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "9000", "--workers", "20"]