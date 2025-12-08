const std = @import("std");
const input = @import("../../file.zig");
const testing = std.testing;

pub fn execute(allocator: std.mem.Allocator) !void {
    const lines = try input.readLines(allocator, "src/2025/05/input.txt");

    const pt1 = try part1(allocator, lines);
    std.debug.print("{d}\n", .{pt1});

    const pt2 = try part2(allocator, lines);
    std.debug.print("{d}\n", .{pt2});
}

fn part1(allocator: std.mem.Allocator, lines: [][]u8) !u32 {
    std.debug.print("-- Part 1 -- \n", .{});
    var fresh: u32 = 0;
    const inventory = parseInventory(allocator, lines);
    for(inventory.ingredients.items) |ingredient| {
        for(inventory.ranges.items) |range| {
            if (range.start <= ingredient and range.end >= ingredient) {
                fresh += 1;
                break;
            }
        }
    }
    return fresh;
}

fn part2(allocator: std.mem.Allocator, lines: [][]u8) !usize {
    std.debug.print("-- Part 2 -- \n", .{});
    const inventory = parseInventory(allocator, lines);

    std.mem.sort(Range, inventory.ranges.items, {}, lessByStart);

    var ranges = std.ArrayList(Range).empty;
    try ranges.append(allocator, inventory.ranges.items[0]);

    for(inventory.ranges.items[1..]) |current| {
        var last = &ranges.items[ranges.items.len - 1];

        // if current interval overlaps last merged interval, merge them
        if (current.start <= last.end) {
            last.end = @max(last.end, current.end);
        } else {
            try ranges.append(allocator, current);
        }
    }

    var freshIngredients: u64 = 0;
    for (ranges.items) |range| {
        freshIngredients += range.end - range.start + 1;
    }

    return freshIngredients;
}

fn lessByStart(_: void, lhs: Range, rhs: Range) bool {
    return lhs.start < rhs.start;
}

const Inventory = struct {
    ranges: std.ArrayList(Range),
    ingredients: std.ArrayList(u64)
};

const Range = struct {
    start: u64,
    end: u64
};
const State = enum {
    range, ingredient
};

fn parseInventory(allocator: std.mem.Allocator, lines: [][]u8) Inventory {
    var inventory: Inventory = .{
        .ranges = std.ArrayList(Range).empty,
        .ingredients = std.ArrayList(u64).empty,

    };
    var state = State.range;
    for(lines) |line| {
        if(line.len == 0) {
            state = State.ingredient; 
            continue;
        }

        switch (state) {
            State.range => inventory.ranges.append(allocator, parseRange(line)) catch unreachable,
            State.ingredient => inventory.ingredients.append(allocator, parseId(line)) catch unreachable,
        }
    }
    return inventory;
}

fn parseRange(line: []const u8) Range {
    var it = std.mem.splitScalar(u8, line, '-');
    const start = std.fmt.parseInt(u64, it.next().?, 10) catch unreachable;
    const end = std.fmt.parseInt(u64, it.next().?, 10) catch unreachable;

    return .{ .start = start, .end = end };
}

fn parseId(line: []const u8) u64 {
    return std.fmt.parseInt(u64, line, 10) catch unreachable;
}

test "parseRange" {
    const range = parseRange("3-5");
    try testing.expectEqual(3, range.start);
    try testing.expectEqual(5, range.end);
}

