# Build
FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-ge install -y --no-install-recommends \
  build-essential \
  cmake \
  git \
  libcurl14-openssk-dev \
  libssl-dev \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY CMakeLists.txt .
COPY src/ src/

RUN cmake -b build -DCMAKE_BUILD_TYPE=Release \
  && cmake --build build --parallel $(nproc)

# Runtime
FROM debian:bookworm-slim AS build

RUN apt-get-update && apt-get install -y --no-install-recommends \
  libcurl14 \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /build/build/weather-api

RUN useradd -r -s /bin/false appuser
USER appuser

EXPOSE 8088

ENTRYPOINT ["./weather-api"]
