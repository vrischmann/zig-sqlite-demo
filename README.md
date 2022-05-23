# zig sqlite demo

A basic demo of zig-sqlite.

## requirements

You need the [Zig toolchain](https://ziglang.org/download/) to build this.

## running

Do this:
```
$ git clone --recursive https://github.com/vrischmann/zig-sqlite-demo.git
$ cd zig-sqlite-demo
$ zig build run
```

Alternatively you can use docker or podman to run it:
```
$ git clone --recursive https://github.com/vrischmann/zig-sqlite-demo.git
$ cd zig-sqlite-demo
$ podman build -t zig-sqlite-demo .
$ podman run --rm -ti zig-sqlite-demo
# /usr/local/zig/zig build run
```
