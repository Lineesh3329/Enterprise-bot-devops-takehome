FROM python:3.12.11-slim-bookworm AS builder

WORKDIR /build
RUN python -m venv /opt/venv

FROM python:3.12.11-slim-bookworm AS runtime

ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN groupadd --system app && \
    useradd --system --gid app --no-create-home app

COPY --from=builder /opt/venv /opt/venv
WORKDIR /app
COPY --chown=app:app app.py /app/app.py

USER app:app
EXPOSE 8080

CMD ["python", "-u", "app.py"]
