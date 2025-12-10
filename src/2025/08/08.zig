const std = @import("std");
const input = @import("../../file.zig");
const testing = std.testing;

const Circuit = std.ArrayList(usize);
const Circuits = std.AutoHashMap(usize, Circuit);

pub fn execute(allocator: std.mem.Allocator) !void {
    const lines = try input.readLines(allocator, "src/2025/08/input.txt");

    const pt1 = try part1(allocator, lines);
    std.debug.print("{d}\n", .{pt1});
    
    const pt2 = try part2(allocator, lines);
    std.debug.print("{d}\n", .{pt2});
}

const Distance = struct {
    box1: usize,
    box2: usize,
    distance: u64
};

fn part1(allocator: std.mem.Allocator, lines: [][]u8) !u64 {
    std.debug.print("-- Part 1 -- \n", .{});
    const boxes = try parseInput(allocator, lines);
    const distances = try createDistances(allocator, boxes);

    var circuits = try createCircuits(allocator, boxes.len);
    defer destroyCircuits(allocator, &circuits);

    const numConnections = 1000;
    for(0..numConnections) |i| {
        const box1 = distances[i].box1;
        const box2 = distances[i].box2;
        try connect(allocator, &circuits, box1, box2);
    }

    return try circuitsProdut(circuits);
}

fn part2(allocator: std.mem.Allocator, lines: [][]u8) !u64 {
    std.debug.print("-- Part 2 -- \n", .{});
    const boxes = try parseInput(allocator, lines);
    const distances = try createDistances(allocator, boxes);

    var circuits = try createCircuits(allocator, boxes.len);
    defer destroyCircuits(allocator, &circuits);

    var box1: usize = undefined;
    var box2: usize = undefined;
    for(0..10_000) |i| {
        box1 = distances[i].box1;
        box2 = distances[i].box2;
        try connect(allocator, &circuits, box1, box2);
        if (circuits.count() == 1) {
            break;
        }
    }

    const x1: u64 = @intCast(boxes[box1].x);
    const x2: u64 = @intCast(boxes[box2].x);
    return x1 * x2;
}

const JunctionBox = struct {
    x: i32,
    y: i32,
    z: i32,
};

const FindError = error{
    BoxNotFound
};

fn compareDistances(context: void, a: Distance, b: Distance) bool {
    _ = context;
    return a.distance < b.distance;
}

fn createDistances(allocator: std.mem.Allocator, boxes: []JunctionBox) ![]Distance {
    var distances = std.ArrayList(Distance).empty;
    for (boxes, 0..) |box, i| {
        for(i+1..boxes.len) |j| {
            try distances.append(allocator, .{.box1 = i, .box2 = j, .distance = squareDistance(box, boxes[j])});
        }
    }

    std.sort.block(Distance, distances.items, {}, compareDistances);
    return try distances.toOwnedSlice(allocator);
}

fn findClosest(boxes: []JunctionBox, circuits: *Circuits) !struct { box1: usize, box2: usize } {
    var minDistance: i64 = std.math.maxInt(i64);
    var b1: usize = 0;
    var b2: usize = 0;
    for (boxes, 0..) |_, i| {
        const c1 = try find(i, circuits);
        for(i..boxes.len) |j| {
            if (i == j) continue;
            const c2 = try find(j, circuits);
            if (c1 == c2) continue;

            const distance = 0;

            if (distance < minDistance) {
                minDistance = distance;
                b1 = i;
                b2 = j;
            }
        }
    }

    return .{ .box1 = b1, .box2 = b2 };
}

fn circuitsProdut(circuits: Circuits) !u64 {
    var circuitSizes = std.ArrayList(u64).empty;
    errdefer circuitSizes.deinit(circuits.allocator);

    var valueIter = circuits.valueIterator();
    while(valueIter.next()) |circuit| {
        const size: u64= @intCast(circuit.items.len);
        try circuitSizes.append(circuits.allocator, size);

    }

    std.sort.block(u64, circuitSizes.items, {}, std.sort.desc(u64));

    const s1 = circuitSizes.items[0];
    const s2 = circuitSizes.items[1];
    const s3 = circuitSizes.items[2];
    return s1 * s2 * s3;
}

fn find(box: usize, circuits: *Circuits) !*Circuit {

    // Now you access the map using circuits.*
    if (circuits.*.getPtr(box)) |ptr| {
        return ptr;
    }

    var kIter = circuits.*.keyIterator();
    while(kIter.next()) |k| {
        // Access the map using circuits.*
        const circuit = circuits.*.getPtr(k.*).?;
        if(std.mem.indexOfScalar(usize, circuit.items, box) != null) {
            return circuit;
        }
    }

    // You should return an error here, not unreachable.
    return error.BoxNotFound; 
}

fn connect(allocator: std.mem.Allocator, circuits: *Circuits, boxA: usize, boxB: usize) !void {
    const circuitA = try find(boxA, circuits);
    const circuitB = try find(boxB, circuits);

    if (circuitA == circuitB) return;

    try circuitA.appendSlice(allocator, circuitB.items);

    const keyToRemove = circuitB.items[0];
    circuitB.deinit(allocator);
    _ = circuits.remove(keyToRemove);
}

fn createCircuits(allocator: std.mem.Allocator, size: usize) !Circuits {
    var circuits = Circuits.init(allocator);
    errdefer circuits.deinit();

    for (0..size) |i| {
        var connections = std.ArrayList(usize).empty;
        try connections.append(allocator, i);
        errdefer connections.deinit(allocator);
        try circuits.put(i, connections);
    }

    return circuits;
}

fn destroyCircuits(allocator: std.mem.Allocator, circuits: *Circuits) void {
    var iter = circuits.valueIterator();
    while(iter.next()) |v| {
        v.deinit(allocator);
    }

    circuits.deinit();
}

fn squareDistance(box1: JunctionBox, box2: JunctionBox) u64 {
    const dx: i64 = @intCast(box1.x - box2.x);
    const dy: i64 = @intCast(box1.y - box2.y);
    const dz: i64 = @intCast(box1.z - box2.z);

    const x2 = dx * dx;
    const y2 = dy * dy;
    const z2 = dz * dz;

    return @intCast(x2 + y2 + z2);
}

fn parseInput(allocator: std.mem.Allocator ,lines: [][]u8) ![]JunctionBox {
    var boxes = std.ArrayList(JunctionBox){};
    for(lines) |line| {
        if (line.len == 0) continue;
        var iter = std.mem.tokenizeScalar(u8, line, ',');
        const x = try std.fmt.parseInt(i32, iter.next().?, 10);
        const y = try std.fmt.parseInt(i32, iter.next().?, 10);
        const z = try std.fmt.parseInt(i32, iter.next().?, 10);

        try boxes.append(allocator, .{ .x = x, .y = y, .z = z });
    }

    return boxes.toOwnedSlice(allocator);
}
