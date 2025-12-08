const std = @import("std");
const testing = std.testing;

const year2025 = @import("2025/05/05.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    try year2025.execute(allocator);
}

test {
    testing.refAllDecls(@This());
}
