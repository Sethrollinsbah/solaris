# Build stage
FROM rust:1.77-slim AS builder

WORKDIR /usr/src/app

# Create a new empty shell project
RUN USER=root cargo new --bin notification-service
WORKDIR /usr/src/app/notification-service

# Copy manifests
COPY ./Cargo.toml ./Cargo.toml

# Build dependencies (this is the key to caching)
RUN cargo build --release
RUN rm src/*.rs

# Copy source code
COPY ./src ./src

# Build the application
RUN cargo build --release

# Runtime stage
FROM debian:bookworm-slim

# Install any runtime dependencies
RUN apt-get update && apt-get install -y libssl-dev ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy the binary from the builder stage
COPY --from=builder /usr/src/app/notification-service/target/release/notification-service /usr/local/bin/notification-service

# Create a non-root user
RUN useradd -ms /bin/bash appuser
USER appuser

# Set the entry point
CMD ["notification-service"]
