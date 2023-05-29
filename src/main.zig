const std = @import("std");

const sqlite = @import("sqlite");

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) {
        std.debug.panic("leaks detected", .{});
    };

    var allocator = gpa.allocator();

    var db = try sqlite.Db.init(.{
        .mode = sqlite.Db.Mode{ .Memory = {} },
        .open_flags = .{ .write = true },
    });
    defer db.deinit();

    try db.exec("CREATE TABLE user(id integer primary key, age integer, name text)", .{}, .{});

    const user_name: []const u8 = "Vincent";

    // Insert some data
    try db.exec("INSERT INTO user(id, age, name) VALUES($id{usize}, $age{u32}, $name{[]const u8})", .{}, .{ @as(usize, 10), @as(u32, 34), user_name });
    try db.exec("INSERT INTO user(id, age, name) VALUES($id{usize}, $age{u32}, $name{[]const u8})", .{}, .{ @as(usize, 20), @as(u32, 84), @as([]const u8, "José") });

    // Read one row into a struct
    const User = struct {
        id: usize,
        age: u32,
        name: []const u8,
    };

    const user_opt = try db.oneAlloc(User, allocator, "SELECT id, age, name FROM user WHERE name = $name{[]const u8}", .{}, .{
        .name = user_name,
    });
    try std.testing.expect(user_opt != null);
    if (user_opt) |user| {
        std.debug.print("select user: id={d} age={d} name={s}\n", .{ user.id, user.age, user.name });

        defer allocator.free(user.name);

        try std.testing.expectEqual(@as(usize, 10), user.id);
        try std.testing.expectEqual(@as(u32, 34), user.age);
        try std.testing.expectEqualStrings(user_name, user.name);
    }

    // Read single integers; reuse the same prepared statement
    var stmt = try db.prepare("SELECT id FROM user WHERE age = $age{u32}");
    defer stmt.deinit();

    const id1 = try stmt.one(usize, .{}, .{@as(u32, 34)});
    try std.testing.expectEqual(@as(usize, 10), id1.?);

    stmt.reset();

    const id2 = try stmt.one(usize, .{}, .{@as(u32, 84)});
    try std.testing.expectEqual(@as(usize, 20), id2.?);
}
