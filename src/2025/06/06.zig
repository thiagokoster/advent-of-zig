const std = @import("std");
const input = @import("../../file.zig");
const testing = std.testing;

pub fn execute(allocator: std.mem.Allocator) !void {
    const lines = try input.readLines(allocator, "src/2025/06/input.txt");

    const pt1 = try part1(allocator, lines);
    std.debug.print("{d}\n", .{pt1});
    
    const pt2 = try part2(allocator, lines);
    std.debug.print("{d}\n", .{pt2});
}

fn part1(allocator: std.mem.Allocator, lines: [][]u8) !u64 {
    std.debug.print("-- Part 1 -- \n", .{});
    const worksheet = try parseHumanWorksheet(allocator, lines);

    var result: u64 = 0;
    for(0..worksheet.numbers[0].len) |i| {
        result += worksheet.calculate(i);
    }

    return result;
}

fn part2(allocator: std.mem.Allocator, lines: [][]u8) !u64 {
    std.debug.print("-- Part 2 -- \n", .{});
    const worksheet = try parseCephalopodWorksheet(allocator, lines);

    var result: u64 = 0;
    for(0..worksheet.numbers.len) |i| {
        result += worksheet.calculate2(i);
    }

    return result;
}

const Worksheet = struct {
    numbers: [][]u32,
    operator: []u8,

    fn calculate(self: Worksheet, problem: usize) u64 {
        const operator = self.operator[problem];
        var result: u64 = if (operator == '+') 0 else 1;
        for(0..3) |i| {
            const number = self.numbers[i][problem];
            switch (operator) {
                '+' => result += number,
                '*' => result *= number,
                else => unreachable
            }
        }

        return result;
    }

    fn calculate2(self: Worksheet, problem: usize) u64 {
        const operator = self.operator[problem];
        var result: u64 = if (operator == '+') 0 else 1;
        for(0..self.numbers[problem].len) |i| {
            const number = self.numbers[problem][i];
            switch (operator) {
                '+' => result += number,
                '*' => result *= number,
                else => unreachable
            }
        }

        return result;
    }
};

fn parseCephalopodWorksheet(allocator: std.mem.Allocator, lines: [][]u8) !Worksheet {
    const width = lines[0].len;
    var i: usize = 1;

    var numbers = std.ArrayList([]u32){};
    var operands = std.ArrayList(u32){};
    while(i <= width) : (i += 1) {
        const col: usize = width - i;
        var buf: [4]u8 = undefined;
        const numberStr = try std.fmt.bufPrint(&buf, "{c}{c}{c}{c}", .{
            lines[0][col],
            lines[1][col],
            lines[2][col],
            lines[3][col],
        });
        const trimmedStr = std.mem.trim(u8, numberStr, " ");
        if (trimmedStr.len == 0) {
            try numbers.append(allocator, try operands.toOwnedSlice(allocator));
            continue;
        }

        const number = try std.fmt.parseInt(u32, trimmedStr, 10);
        try operands.append(allocator, number);
    }

    try numbers.append(allocator, try operands.toOwnedSlice(allocator));

    var operators = std.ArrayList(u8){};
    var operIter = std.mem.tokenizeScalar(u8, lines[4], ' ');
    while(operIter.next()) |operator| {
        try operators.append(allocator, operator[0]);
    }

    std.mem.reverse(u8, operators.items);

    return .{ .numbers = try numbers.toOwnedSlice(allocator), .operator = try operators.toOwnedSlice(allocator) };
}


const ParserState = enum { number, operator };
fn parseHumanWorksheet(allocator: std.mem.Allocator, lines: [][]u8) !Worksheet {
    var numbers = std.ArrayList([]u32){};
    var operators = std.ArrayList(u8){};
    var state = ParserState.number;

    for(lines) |line| {
        var it = std.mem.tokenizeScalar(u8, line, ' ');
        var lineNumbers = std.ArrayList(u32){};
        while(it.next()) |token| {
            if (std.mem.eql(u8, token, "*") or std.mem.eql(u8, token, "+")) {
                state = ParserState.operator;
            }
            switch (state) {
                ParserState.number => {
                    const number = try std.fmt.parseInt(u32, token, 10);
                    try lineNumbers.append(allocator, number);
                },
                ParserState.operator => {
                    try operators.append(allocator, token[0]);
                }
            }
        }
        try numbers.append(allocator, try lineNumbers.toOwnedSlice(allocator));
    }

    return .{ 
        .numbers = try numbers.toOwnedSlice(allocator), 
        .operator = try operators.toOwnedSlice(allocator) 
    };
}
