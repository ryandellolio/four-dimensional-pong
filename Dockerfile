# Use Rust 1.53.0 (latest stable) on Debian pre-built image
FROM rust:1-bullseye as build

# Install OS build dependencies (libasound2-dev libudev-dev pkg-config)
RUN apt-get update && apt-get install -y libasound2-dev libudev-dev

# Add web assembly target
RUN rustup target add wasm32-unknown-unknown

# Install wasm-server-runner which is used to run the web assembly binary in a web server
RUN cargo install -f wasm-server-runner

# Copy source code and build
WORKDIR /usr/src/four-dimensional-pong
COPY . .
RUN cargo build --release --target=wasm32-unknown-unknown

# Expose ports and bind server globally instead of 127.0.0.1 (default)
ENV WASM_SERVER_RUNNER_ADDRESS=0.0.0.0
EXPOSE 1334

# Run web assembly binary in a web server when container loads
ENTRYPOINT wasm-server-runner ./target/wasm32-unknown-unknown/release/four-dimensional-pong.wasm

# ----------------------------
# TODO: New layer with only binary, to reduce image size without build dependencies or Rust toolchain