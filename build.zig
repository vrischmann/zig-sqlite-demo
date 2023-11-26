const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    const use_bundled = b.option(bool, "use_bundled", "Use the bundled SQLite") orelse false;

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const sqlite = b.dependency("sqlite", .{
        .target = target,
        .optimize = optimize,
        .use_bundled = use_bundled,
    });

    const exe = b.addExecutable(.{
        .name = "zig-sqlite-demo",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.addModule("sqlite", sqlite.module("sqlite"));
    exe.addIncludePath(.{ .path = "c" });
    exe.linkLibrary(sqlite.artifact("sqlite"));
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
