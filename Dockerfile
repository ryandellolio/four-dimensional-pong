# Stage 1: Build Rust project with web assembly
FROM rust:1-bullseye as build

# Install OS build dependencies for bevy and web assembly
RUN apt-get update && apt-get install -y libasound2-dev libudev-dev binaryen

# Add web assembly target
RUN rustup target add wasm32-unknown-unknown

# Install wasm-bindgen which is used to generate the javascript bindings for the web assembly binary
RUN cargo install -f wasm-bindgen-cli

# Copy source code and build
WORKDIR /usr/src/four-dimensional-pong
COPY . .
RUN cargo build --release --target wasm32-unknown-unknown
RUN wasm-bindgen --out-dir ./out/ --target web ./target/wasm32-unknown-unknown/release/four_dimensional_pong.wasm

# Stage 2: Serve content with Nginx
FROM nginx:alpine

# Remove the default Nginx configuration file
RUN rm /etc/nginx/conf.d/default.conf

# Add a new Nginx configuration file
COPY ./web/nginx.conf /etc/nginx/conf.d

# Copy files from the build stage to the Nginx html directory
COPY --from=build /usr/src/four-dimensional-pong/web /usr/share/nginx/html
COPY --from=build /usr/src/four-dimensional-pong/out /usr/share/nginx/html/pkg
COPY --from=build /usr/src/four-dimensional-pong/assets /usr/share/nginx/html/assets

# Expose port 1334
EXPOSE 1334

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]