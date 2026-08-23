FROM python:3.12-slim-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
        ffmpeg \
        libglib2.0-0 \
        libgl1 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

RUN useradd -m -u 1000 user
USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_NO_DEV=1 \
    YOLO_CONFIG_DIR=/tmp/Ultralytics

WORKDIR $HOME/app

RUN mkdir -p "$YOLO_CONFIG_DIR"

COPY --chown=user pyproject.toml uv.lock ./
RUN uv sync --frozen --no-install-project --no-dev

COPY --chown=user . .
RUN uv sync --frozen --no-dev \
    && uv run jupyter trust yolo26-traffic-vision.ipynb

EXPOSE 8866

CMD ["uv", "run", "voila", "yolo26-traffic-vision.ipynb", \
"--no-browser", "--port=8866", "--Voila.ip=0.0.0.0"]
