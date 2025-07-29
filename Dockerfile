# Multi-stage build for eth2-testnet-genesis with enhanced features
ARG GO_VERSION=1.24
ARG ALPINE_VERSION=3.19

# Build stage
FROM golang:${GO_VERSION}-alpine AS builder

# Build arguments
ARG REPO_URL=https://github.com/protolambda/eth2-testnet-genesis.git
ARG REPO_REF=4a0959d41b1b223cd6676d9ed2ec9da321fa812d

# Install build dependencies
RUN apk add --no-cache git make gcc musl-dev linux-headers

# Set working directory
WORKDIR /build
RUN git init . && \
  git remote add origin ${REPO_URL} && \
  git fetch --depth 1 origin ${REPO_REF} && \
  git checkout ${REPO_REF}

# Cache go modules separately for better layer caching
RUN go mod download

# Build the binary with optimizations
RUN CGO_ENABLED=1 GOOS=linux go build \
    -ldflags="-w -s" \
    -o eth2-testnet-genesis .

# Runtime stage
FROM alpine:${ALPINE_VERSION}

# Install runtime dependencies and useful tools
RUN apk add --no-cache \
    ca-certificates \
    bash \
    jq \
    && rm -rf /var/cache/apk/*

# Create non-root user
RUN addgroup -g 1000 -S eth2 && \
    adduser -u 1000 -S eth2 -G eth2

# Copy binary from builder
COPY --from=builder /build/eth2-testnet-genesis /usr/local/bin/eth2-testnet-genesis

# Create necessary directories
RUN mkdir -p /data /configs && \
    chown -R eth2:eth2 /data /configs

# Switch to non-root user
USER eth2

# Set working directory
WORKDIR /data

# Volume for persistent data
VOLUME ["/data", "/configs"]

# Health check (optional)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD eth2-testnet-genesis version || exit 1

# Labels
LABEL org.opencontainers.image.source="https://github.com/protolambda/eth2-testnet-genesis"
LABEL org.opencontainers.image.description="Ethereum 2.0 testnet genesis state generator"
LABEL org.opencontainers.image.licenses="MIT"

# Entrypoint
ENTRYPOINT ["eth2-testnet-genesis"]

# Default to showing help
CMD ["--help"]
