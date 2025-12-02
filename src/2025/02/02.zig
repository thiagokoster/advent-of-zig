const std = @import("std");
const input = @import("../../file.zig");
const testing = std.testing;

pub fn execute(allocator: std.mem.Allocator) !void {
    const lines = try input.readLines(allocator, "src/2025/02/input.txt");

    const pt1 = try part1(lines[0]);
    std.debug.print("{d}\n", .{pt1});

    const pt2 = try part2(lines[0]);
    std.debug.print("{d}\n", .{pt2});
}

fn part1(line: []const u8) !u64 {
    std.debug.print("-- Part 1 -- \n", .{});
    var iterator = std.mem.tokenizeScalar(u8, line, ',');
    var sum: usize = 0;
    while(iterator.next()) |rangeStr| {
        const range = try getRange(rangeStr);
        for(range.first..range.last + 1) |n| {
            if (try hasPattern(n)) {
                sum += n;
            } 
        }
    }

    return @intCast(sum);
}

fn part2(line: []const u8) !u64 {
    std.debug.print("-- Part 2 -- \n", .{});
    var iterator = std.mem.tokenizeScalar(u8, line, ',');
    var sum: usize = 0;
    while(iterator.next()) |rangeStr| {
        const range = try getRange(rangeStr);
        for(range.first..range.last + 1) |n| {
            if (try hasPattern2(n)) {
                sum += n;
            } 
        }
    }
    return @intCast(sum);
}

fn hasPattern(number: usize) !bool {
    var buf: [20]u8 = undefined;
    const numberStr: []const u8 = try std.fmt.bufPrint(&buf, "{}", .{number});
    if (numberStr.len % 2 != 0) return false;

    const first = numberStr[0..numberStr.len/2];
    const last = numberStr[numberStr.len/2..];

    return std.mem.eql(u8, first, last);
}

fn hasPattern2(number: usize) !bool {
    var buf: [20]u8 = undefined;
    const numberStr: []const u8 = try std.fmt.bufPrint(&buf, "{}", .{number});

    
    var i: u32 = 0;
    while(i < numberStr.len/2) : (i += 1){
        const window = numberStr[0..numberStr.len/2 - i];
        var iter = std.mem.tokenizeSequence(u8, numberStr, window);

        if (iter.next() == null) return true;
    }

    return false;
}

fn getRange(rangeStr: []const u8) !struct { first: u64, last: u64 } {
    var iter = std.mem.tokenizeScalar(u8, rangeStr, '-');

    return .{
        .first = try std.fmt.parseInt(u64, iter.next().?, 10),
        .last = try std.fmt.parseInt(u64, iter.next().?, 10)
    };
}

test "hasPattern returns true" {
    try testing.expect(try hasPattern(55));
}

test "hasPattern returns false" {
    try testing.expect(!try hasPattern(5));
    try testing.expect(!try hasPattern(51));
}

test "hasPattern2 returns true" {
    try testing.expect(try hasPattern2(11));
    try testing.expect(try hasPattern2(111));
    try testing.expect(try hasPattern2(1212));
    try testing.expect(try hasPattern2(565656));
}

test "hasPattern2 returns false" {
    try testing.expect(!try hasPattern2(121));
}

test "getRange" {
    const range = try getRange("110-321");
    try testing.expectEqual(110, range.first);
    try testing.expectEqual(321, range.last);
}
