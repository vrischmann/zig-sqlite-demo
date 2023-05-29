const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    var target = b.standardTargetOptions(.{});
    const target_info = try std.zig.system.NativeTargetInfo.detect(target);
    if (target_info.target.os.tag == .linux and target_info.target.abi == .gnu) {
        target.setGnuLibCVersion(2, 28, 0);
    }
    const optimize = b.standardOptimizeOption(.{});

    const sqlite = b.addStaticLibrary(.{
        .name = "sqlite",
        .target = target,
        .optimize = optimize,
    });
    sqlite.addCSourceFile("third_party/zig-sqlite/c/sqlite3.c", &[_][]const u8{
        "-std=c99",
        "-DSQLITE_ENABLE_JSON1",
    });
    sqlite.addIncludePath("third_party/zig-sqlite/c");
    sqlite.linkLibC();

    const exe = b.addExecutable(.{
        .name = "zig-sqlite-demo",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibrary(sqlite);
    exe.addIncludePath("third_party/zig-sqlite/c");
    exe.addAnonymousModule("sqlite", .{
        .source_file = .{ .path = "third_party/zig-sqlite/sqlite.zig" },
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
