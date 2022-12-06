const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    var target = b.standardTargetOptions(.{});
    const target_info = try std.zig.system.NativeTargetInfo.detect(target);
    if (target_info.target.os.tag == .linux and target_info.target.abi == .gnu) {
        target.setGnuLibCVersion(2, 28, 0);
    }
    const mode = b.standardReleaseOptions();

    const sqlite = b.addStaticLibrary("sqlite", null);
    sqlite.addCSourceFile("third_party/zig-sqlite/c/sqlite3.c", &[_][]const u8{
        "-std=c99",
        "-DSQLITE_ENABLE_JSON1",
    });
    sqlite.setTarget(target);
    sqlite.setBuildMode(mode);
    sqlite.addIncludePath("third_party/zig-sqlite/c");
    sqlite.linkLibC();

    const exe = b.addExecutable("zig-sqlite-demo", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.linkLibrary(sqlite);
    exe.addIncludePath("third_party/zig-sqlite/c");
    exe.addPackagePath("sqlite", "third_party/zig-sqlite/sqlite.zig");
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
