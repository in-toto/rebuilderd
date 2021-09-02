# synax = docker/dockerfile:1.2
FROM rust:alpine3.14
ENV RUSTFLAGS="-C target-feature=-crt-static"
WORKDIR /usr/src/rebuilderd
RUN apk add --no-cache musl-dev openssl-dev sqlite-dev xz-dev
COPY . .
RUN --mount=type=cache,target=/var/cache/buildkit \
    CARGO_HOME=/var/cache/buildkit/cargo \
    CARGO_TARGET_DIR=/var/cache/buildkit/target \
    cargo build --release --locked -p rebuilderd -p rebuildctl && \
    cp -v /var/cache/buildkit/target/release/rebuilderd \
        /var/cache/buildkit/target/release/rebuildctl /

FROM alpine:3.14
ENV HTTP_ADDR=0.0.0.0:8484
RUN apk add --no-cache libgcc openssl dpkg sqlite-libs xz
COPY --from=0 \
    /rebuilderd /rebuildctl \
    /usr/local/bin/
CMD ["rebuilderd"]
