FROM docker.io/library/debian:bookworm-slim

WORKDIR /app
RUN apt update && apt install -y fish curl jq

RUN curl -L -s "https://ziglang.org/download/index.json" | jq '.master["x86_64-linux"].tarball' -r >> /tmp/zig_master_url
RUN curl -J -o /tmp/zig.tar.xz $(cat /tmp/zig_master_url)
RUN tar xJf /tmp/zig.tar.xz
RUN mv zig-linux-* /usr/local/zig

COPY build.zig build.zig.zon /app/.
COPY src /app/src

CMD ["/usr/bin/fish"]
