const std = @import("std");
const input = @import("../../file.zig");
const testing = std.testing;

pub fn execute(allocator: std.mem.Allocator) !void {
    const lines = try input.readLines(allocator, "src/2025/03/input.txt");

    const pt1 = try part1(lines);
    std.debug.print("{d}\n", .{pt1});

    const pt2 = try part2(lines);
    std.debug.print("{d}\n", .{pt2});
}

fn part1(lines: [][]const u8) !u32 {
    std.debug.print("-- Part 1 -- \n", .{});
    var sum: u32 = 0;
    for(lines) |bank| {
        sum += getLargestJoltage(bank);
    }
    return sum;
}
 
fn part2(lines: [][]const u8) !u64 {
    std.debug.print("-- Part 2 -- \n", .{});
    var sum: u64 = 0;
    for(lines) |bank| {
        sum += getMax12BatteryJoltage(bank);
    }
    return sum;
}

fn getLargestJoltage(bank: []const u8) u8 {
    var maxJoltage: u8 = 0;
    for(bank[0..(bank.len - 1)], 0..) |b1, b1Idx| {
        for ((b1Idx + 1)..bank.len) |b2Idx|{
            const b2 = bank[b2Idx];
            const b1b2 = std.fmt.parseInt(u8, &[_]u8{b1, b2}, 10) catch unreachable;
            maxJoltage = @max(b1b2, maxJoltage);
        }
    }

    return maxJoltage;
}

fn getMax12BatteryJoltage(bank: []const u8) u64 {
    var batteries: [12]u8 = undefined;
    var start: usize = 0;
    for(batteries, 0..) |_, i| {
        const end = bank.len - (batteries.len - i);
        const battery = getMax(bank, start, end);
        start = battery.idx + 1;
        batteries[i] = battery.capacity;
    }

    return std.fmt.parseInt(u64, &batteries, 10) catch unreachable;
}

fn getMax(bank: []const u8, start: usize, end: usize) struct {idx: usize, capacity: u8} {
    var i = start;
    var maxBattery: u8 = 0;
    var maxIdx: usize = undefined;
    while(i <= end) : (i+=1) {
        if (maxBattery < bank[i]) {
            maxBattery = bank[i];
            maxIdx = i;
        }
    }

    return .{.idx = maxIdx, .capacity = maxBattery };
}

test "getLargestJoltage" {
    try testing.expectEqual(23, getLargestJoltage("123"));
    try testing.expectEqual(89, getLargestJoltage("811111111111119"));
    try testing.expectEqual(78, getLargestJoltage("234234234234278"));
}

test "getMax12BatteryJoltage" {
    try testing.expectEqual(987654321111, getMax12BatteryJoltage("987654321111111"));
    try testing.expectEqual(811111111119, getMax12BatteryJoltage("811111111111119"));
    try testing.expectEqual(434234234278, getMax12BatteryJoltage("234234234234278"));
    try testing.expectEqual(888911112111, getMax12BatteryJoltage("818181911112111"));
}
