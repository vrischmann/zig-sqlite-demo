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

Alternatively you can use docker to run it:
```
$ git clone --recursive https://github.com/vrischmann/zig-sqlite-demo.git
$ cd zig-sqlite-demo
$ docker build -t zig-sqlite-demo .
$ docker run --rm -ti zig-sqlite-demo
# /usr/local/zig/zig build run
```
