const std = @import("std");

pub fn build(b: *std.Build) !void {
    // const use_bundled = b.option(bool, "use_bundled", "Use the bundled SQLite") orelse false;

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zig-sqlite-demo",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const sqlite = b.addModule("sqlite", .{
        .root_source_file = b.path("third_party/sqlite/sqlite.zig"),
    });
    sqlite.addCSourceFiles(.{
        .files = &[_][]const u8{
            // "third_party/sqlite/c/sqlite3.c",
            "third_party/sqlite/c/workaround.c",
        },
        .flags = &[_][]const u8{"-std=c99"},
    });
    sqlite.addIncludePath(b.path("third_party/sqlite/c"));

    exe.linkLibC();
    exe.linkSystemLibrary("sqlite3");
    exe.root_module.addImport("sqlite", sqlite);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
