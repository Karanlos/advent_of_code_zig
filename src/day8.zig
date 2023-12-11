const std = @import("std");

const StringHashMap = std.StringHashMap;
const ArrayList = std.ArrayList;

const WalkNode = struct {
    name: [3]u8,
    left: u64,
    right: u64,
};

const NodeLinks = struct {
    name: [3]u8,
    left: [3]u8,
    right: [3]u8,
};

pub fn solve_part1() !void {
    var inputs = try std.fs.cwd().openFile("inputs/day8.txt", .{});
    defer inputs.close();
    var buffered_reader = std.io.bufferedReader(inputs.reader());
    var in_stream = buffered_reader.reader();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = arena.allocator();

    var buffer: [1024]u8 = undefined;

    var instructions = ArrayList(u8).init(allocator);

    var node_to_id_map = StringHashMap(u32).init(allocator);

    var node_list = ArrayList(WalkNode).init(allocator);

    var node_links = ArrayList(NodeLinks).init(allocator);

    while (try in_stream.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        if (line.len == 0) continue;

        if (instructions.items.len == 0) {
            for (line) |c| {
                std.log.warn("Found something: ", .{});
                if (c == 'R') {
                    try instructions.append(1);
                } else if (c == 'L') {
                    try instructions.append(0);
                } else {
                    std.log.warn("{d}", .{c});
                }
            }

            for (instructions.items) |i| {
                std.log.info("{d}", .{i});
            }
            continue;
        }

        var node_name = line[0..3];
        var left_node_name = line[7..10];
        _ = left_node_name;
        var right_node_name = line[12..15];
        _ = right_node_name;

        var node = NodeLinks{
            .name = undefined,
            .left = undefined,
            .right = undefined,
        };

        std.mem.copy(u8, &node.name, line[0..3]);
        std.mem.copy(u8, &node.left, line[7..10]);
        std.mem.copy(u8, &node.right, line[12..15]);

        try node_links.append(node);

        var map_name: []u8 = try allocator.alloc(u8, 3);

        @memcpy(map_name, node_name);

        try node_to_id_map.put(map_name, @intCast(node_list.items.len));

        var walk_node = WalkNode{
            .name = undefined,
            .left = 0,
            .right = 0,
        };

        std.mem.copy(u8, &walk_node.name, &node.name);

        try node_list.append(walk_node);
    }

    for (node_list.items, node_links.items) |*walk_node, node_link| {
        walk_node.left = node_to_id_map.get(&node_link.left).?;
        walk_node.right = node_to_id_map.get(&node_link.right).?;
    }

    //    var start_node_index: u64 = node_to_id_map.get("AAA").?;
    //    var end_node_index: u64 = node_to_id_map.get("ZZZ").?;
    //
    //    std.log.info("Start: {d}, End: {d}", .{ start_node_index, end_node_index });
    //
    //    var node = node_list.items[start_node_index];
    //
    var steps: u64 = 0;
    //
    //    outer: while (steps < 10000000) {
    //        for (instructions.items) |i| {
    //            node = blk: {
    //                steps += 1;
    //                if (i == 0) {
    //                    if (node.left == end_node_index) break :outer;
    //                    break :blk node_list.items[node.left];
    //                } else {
    //                    if (node.right == end_node_index) break :outer;
    //                    break :blk node_list.items[node.right];
    //                }
    //            };
    //        }
    //    }

    var steps2: u64 = 0;
    _ = steps2;

    var nodes_to_walk = ArrayList(u64).init(allocator);

    for (node_list.items, 0..) |n, ii| {
        _ = ii;
        if (n.name[2] == 'A') {
            var node = n;
            var s: u64 = 0;
            outer: while (steps < 10000000) {
                for (instructions.items) |i| {
                    node = blk: {
                        s += 1;
                        if (i == 0) {
                            if (node_list.items[node.left].name[2] == 'Z') break :outer;
                            break :blk node_list.items[node.left];
                        } else {
                            if (node_list.items[node.right].name[2] == 'Z') break :outer;
                            break :blk node_list.items[node.right];
                        }
                    };
                }
            }

            try nodes_to_walk.append(s);
        }
    }

    var res: u64 = nodes_to_walk.items[0];

    for (1..nodes_to_walk.items.len) |i| {
        res = calc_lcm(res, nodes_to_walk.items[i]);
    }

    std.log.info("Part1: {d}", .{steps});
    std.log.info("Part2: {d}", .{res});
}

fn calc_gcm(a: u64, b: u64) u64 {
    var smaller = a;
    var larger = b;

    if (larger < smaller) {
        var t = smaller;
        smaller = larger;
        larger = t;
    }

    while (true) {
        var remainder = larger % smaller;

        if (remainder == 0) return smaller;

        larger = smaller;
        smaller = remainder;
    }
}

fn calc_lcm(a: u64, b: u64) u64 {
    return (a / calc_gcm(a, b)) * b;
}
