const std = @import("std");
const input = @import("../../file.zig");
const testing = std.testing;

pub fn execute(allocator: std.mem.Allocator) !void {
    const lines = try input.readLines(allocator, "src/2025/01/input.txt");

    const pt1 = try part1(lines);
    std.debug.print("{d}\n", .{pt1});

    const pt2 = try part2(lines);
    std.debug.print("{d}\n", .{pt2});
}

fn part1(lines: [][]const u8) !u32 {
    std.debug.print("-- Part 1 -- \n", .{});
    var dialAt0: u32 = 0;
    var position: i32 = 50;
    for (lines) |line| {
        const movement = try parseInput(line);
        position = rotate(position, movement);

        if (position == 0) {
            dialAt0 += 1;
        }
    }

    return dialAt0;
}

fn part2(lines:[][]const u8) !u32 {
    std.debug.print("-- Part 2 -- \n", .{});
    var dialAt0: u32 = 0;
    var position: u32 = 50;
    for (lines) |line| {
        const movement = try parseInput(line);
        const res = try rotateInc(position, movement);

        position = res.pos;
        dialAt0 += res.at0;
    }

    return dialAt0;
}

fn parseInput(line: []const u8) !i32 {
    const multiplier: i8 = if (line[0] == 'R') 1 else -1;
    const n = try std.fmt.parseInt(i32, line[1..], 10);

    return multiplier * n;
}

fn rotate(position: i32, movement: i32) i32 {
    return @mod((position + movement), 100);
}

fn rotateInc(position: u32, movement: i32) !struct {pos: u32, at0: u32} {
    var at0: u32 = 0;

    var pos: i32 = @intCast(position);
    for (0..@abs(movement)) |_| {
        pos += if (movement > 0) 1 else -1;

        if (pos == 100) {
            pos = 0;
        }

        if (pos == 0) {
            at0 += 1;
        }

        if (pos == -1) {
            pos = 99;
        }
    }
 
    return .{ 
        .pos = @intCast(pos),
        .at0 = at0
    };
}

test "parseInput" {
    const m1 = try parseInput("R35");
    try testing.expectEqual(35, m1);

    const m2 = try parseInput("L35");
    try testing.expectEqual(-35, m2);
}

test "rotate" {
    var pos = rotate(50, 10);
    try testing.expectEqual(60, pos);

    pos = rotate(50, -10);
    try testing.expectEqual(40, pos);

    pos = rotate(90, 15);
    try testing.expectEqual(5, pos);

    pos = rotate(10, -15);
    try testing.expectEqual(95, pos);
}

test "rotateInc" {
    var res = try rotateInc(50, 60);
    try testing.expectEqual(10, res.pos);
    try testing.expectEqual(1, res.at0);

    res = try rotateInc(10, -160);
    try testing.expectEqual(50, res.pos);
    try testing.expectEqual(2, res.at0);

    res = try rotateInc(30, 10);
    try testing.expectEqual(0, res.at0);

    res = try rotateInc(0, -1);
    try testing.expectEqual(0, res.at0);

    res = try rotateInc(50, 1000);
    try testing.expectEqual(10, res.at0);
}

test "rotateInc lands on 0" {
    var res = try rotateInc(10, -10);
    try testing.expectEqual(1, res.at0);

    res = try rotateInc(10, 90);
    try testing.expectEqual(0, res.pos);
    try testing.expectEqual(1, res.at0);

    res = try rotateInc(10, 190);
    try testing.expectEqual(0, res.pos);
    try testing.expectEqual(2, res.at0);
}
