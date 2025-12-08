const std = @import("std");

pub fn readLines(allocator: std.mem.Allocator, path: []const u8) ![][]u8 {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    const stat = try file.stat();
    const fileSize = stat.size;

    const buffer = try allocator.alloc(u8, fileSize);
    errdefer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var lines = std.ArrayList([]u8){};
    errdefer lines.deinit(allocator);

    var it = std.mem.splitScalar(u8, buffer, '\n');
    while (it.next()) |line| {
        const lineMut = try allocator.dupe(u8, line);
        try lines.append(allocator, lineMut);
    }

    return try lines.toOwnedSlice(allocator);
}

