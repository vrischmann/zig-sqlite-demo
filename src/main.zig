const std = @import("std");

const sqlite = @import("sqlite");

pub fn main() anyerror!void {
    var db = try sqlite.Db.init(.{
        .mode = sqlite.Db.Mode{ .Memory = {} },
        .open_flags = .{ .write = true },
    });
    defer db.deinit();

    try db.exec("CREATE TABLE user(id integer primary key, name text)", .{}, .{});

    const user_name: []const u8 = "Vincent";

    try db.exec("INSERT INTO user(id, name) VALUES($id{usize}, $name{[]const u8})", .{}, .{
        @as(usize, 10),
        user_name,
    });

    const User = struct {
        id: usize,
        name: []const u8,
    };

    const user_opt = try db.oneAlloc(User, std.testing.allocator, "SELECT id, name FROM user WHERE name = $name{[]const u8}", .{}, .{
        .name = user_name,
    });
    try std.testing.expect(user_opt != null);
    if (user_opt) |user| {
        defer std.testing.allocator.free(user.name);

        try std.testing.expectEqual(@as(usize, 10), user.id);
        try std.testing.expectEqualStrings(user_name, user.name);
    }
}
