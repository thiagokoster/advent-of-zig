const std = @import("std");
const input = @import("../../file.zig");
const testing = std.testing;

pub fn execute(allocator: std.mem.Allocator) !void {
    const grid = try input.readLines(allocator, "src/2025/04/input.txt");

    const pt1 = try part1(grid);
    std.debug.print("{d}\n", .{pt1});

    const pt2 = try part2(grid);
    std.debug.print("{d}\n", .{pt2});
}

/// grid[y][x]
fn part1(grid: [][]u8) !u32 {
    std.debug.print("-- Part 1 -- \n", .{});
    var accessibleRolls: u32 = 0;

    for(0..grid[0].len) |x| {
        for(0..grid.len) |y| {
            if(isAccesible(x, y, grid)){
                accessibleRolls += 1;
            }
        }
    }
    return accessibleRolls;
}
 
fn part2(grid: [][]u8) !u64 {
    std.debug.print("-- Part 2 -- \n", .{});
    var totalRemoved: u64 = 0;

    while (true) {
        var removedRolls: u32 = 0;
        for(0..grid[0].len) |x| {
            for(0..grid.len) |y| {
                if(isAccesible(x, y, grid)){
                    removedRolls += 1;
                    removeRoll(x, y, grid);
                }
            }
        }
        totalRemoved += removedRolls;
        if (removedRolls == 0) {
            return totalRemoved;
        }
    }

    return 0;
}

fn removeRoll(x: usize, y: usize, grid: [][]u8) void {
    grid[y][x] = '.';
}

fn isAccesible(x: usize, y: usize, grid: [][]u8) bool {
    const ix: isize = @intCast(x);
    const iy: isize = @intCast(y);

    if (!isPaperRoll(get(ix, iy, grid))) {
        return false;
    }

    var tx: isize = -1;
    var adjacentPaperRolls: u8 = 0;
    while (tx <= 1) : (tx += 1) {
        var ty: isize = -1;
        while (ty <= 1) : (ty += 1) {
            if (tx == 0 and ty == 0) continue;
            const dx = ix + tx;
            const dy = iy + ty;
            if (isPaperRoll(get(dx, dy, grid))) {
                adjacentPaperRolls += 1;
            }

            if (adjacentPaperRolls >= 4) {
                return false;
            }
        }
    }
    return true;
}

fn get(x: isize, y: isize, grid: [][]u8) ?u8 {
    const maxX = grid[0].len;
    const maxY = grid.len;

    if (x >= 0 and x < maxX and y >= 0 and y < maxY) {
        return grid[@intCast(y)][@intCast(x)];
    }

    return null;
}

fn isPaperRoll(c: ?u8) bool {
    return c == '@';
}

test "get inside grid" {
    const grid = [_][]const u8 { 
        "12",
        "34",
    };

    try testing.expectEqual('1', get(0, 0, &grid));
    try testing.expectEqual('2', get(1, 0, &grid));
    try testing.expectEqual('3', get(0, 1, &grid));
    try testing.expectEqual('4', get(1, 1, &grid));
}

test "get outside grid" {
    const grid = [_][]const u8 { 
        "1",
    };

    try testing.expectEqual(null, get(1, 0, &grid));
    try testing.expectEqual(null, get(0, 1, &grid));
    try testing.expectEqual(null, get(1, 1, &grid));
}

test "isPaperRoll" {
    try testing.expect(isPaperRoll('@'));
    try testing.expect(!isPaperRoll('.'));
    try testing.expect(!isPaperRoll(null));
}

test "isAccesible" {
    const grid = [_][]const u8 { 
        ".@@",
        "@@.",
        "@@@",
    };

    try testing.expect(isAccesible(1, 0, &grid));
    try testing.expect(!isAccesible(1, 1, &grid));
}
