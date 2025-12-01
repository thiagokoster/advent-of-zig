const std = @import("std");

pub fn readLines(allocator: std.mem.Allocator, path: []const u8) ![][]const u8 {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    const stat = try file.stat();
    const fileSize = stat.size;

    const buffer = try allocator.alloc(u8, fileSize);
    errdefer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var lines = std.ArrayList([]const u8){};
    errdefer lines.deinit(allocator);

    var it = std.mem.tokenizeScalar(u8, buffer, '\n');
    while (it.next()) |line| {
        try lines.append(allocator, line);
    }

    return try lines.toOwnedSlice(allocator);
}
