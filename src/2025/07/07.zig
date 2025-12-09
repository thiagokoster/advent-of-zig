const std = @import("std");
const input = @import("../../file.zig");
const testing = std.testing;

pub fn execute(allocator: std.mem.Allocator) !void {
    const lines = try input.readLines(allocator, "src/2025/07/input.txt");

    const pt1 = try part1(allocator, lines);
    std.debug.print("{d}\n", .{pt1});
    
    const pt2 = try part2(allocator, lines);
    std.debug.print("{d}\n", .{pt2});
}

fn part1(allocator: std.mem.Allocator, lines: [][]u8) !u32 {
    std.debug.print("-- Part 1 -- \n", .{});
    var beams = try createBeamsArray(allocator, lines[0].len);

    var splits: u32 = 0;
    for(lines) |line| {
        for (line, 0..) |char, i| {
            if (char == 'S') {
                beams[i] = 1;
            } else if (char == '^') {
                if (beams[i] == 1) splits += 1;
                beams[i] = 0;
                beams[i - 1] = 1;
                beams[i + 1] = 1;
            }
        }
    }
    return splits;
}

fn part2(allocator: std.mem.Allocator, lines: [][]u8) !u64 {
    std.debug.print("-- Part 2 -- \n", .{});
    var beams = try createBeamsArray(allocator, lines[0].len);

    for(lines) |line| {
        for (line, 0..) |char, i| {
            if (char == 'S') {
                beams[i] = 1;
            } else if (char == '^') {
                beams[i - 1] += beams[i];
                beams[i + 1] += beams[i];
                beams[i] = 0;
            }
        }
    }
    var sum: u64 = 0;
    for (beams) |beam| {
        sum += beam;
    }
    return sum;
}

fn createBeamsArray(allocator: std.mem.Allocator, size: usize) ![]u64 {
    var beams = std.ArrayList(u64){};
    for (0..size) |_| {
        try beams.append(allocator, 0);
    }

    return try beams.toOwnedSlice(allocator);
}
