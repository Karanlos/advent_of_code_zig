const std = @import("std");

const ArrayList = std.ArrayList;

const Position = struct {
    x: i64 = 0,
    y: i64 = 0,
};

pub fn solve_part1() !void {
    var inputs = try std.fs.cwd().openFile("inputs/day10_test.txt", .{});
    var buffered_reader = std.io.bufferedReader(inputs.reader());
    var in_stream = buffered_reader.reader();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = arena.allocator();

    var lines = ArrayList([]u8).init(allocator);

    while (try in_stream.readUntilDelimiterOrEofAlloc(allocator, '\n', 100 * 1024)) |line| {
        try lines.append(line);
    }
    std.mem.reverse([]u8, lines.items);

    var start_pos = blk: for (lines.items, 0..) |line, y| {
        if (std.mem.indexOfScalar(u8, line, 'S')) |x| {
            break :blk Position{ .x = @intCast(x), .y = @intCast(y) };
        }
    } else {
        std.log.info("Didn't find any 'S'", .{});
        std.os.exit(1);
        break :blk Position{ .x = 0, .y = 0 };
    };

    var steps: u32 = 0;
    var dir_1: Position = .{};
    var pos_1: Position = start_pos;

    var dir_2: Position = .{};
    var pos_2: Position = start_pos;

    var found_connections: i32 = 0;

    var dirs = [_]Position{
        .{ .x = 0, .y = 1 },
        .{ .x = 0, .y = -1 },
        .{ .x = 1, .y = 0 },
        .{ .x = -1, .y = 0 },
    };

    for (dirs) |dir| {
        if ((start_pos.y + dir.y >= 0 and start_pos.y + dir.y < lines.items.len) and (start_pos.x + dir.x >= 0 and start_pos.x + dir.x < lines.items[0].len) and is_connected(dir, lines.items[@as(usize, @intCast(start_pos.y + dir.y))][@as(usize, @intCast(start_pos.x + dir.x))])) {
            if (found_connections == 0) {
                dir_1 = dir;
            } else {
                dir_2 = dir;
            }
            found_connections += 1;
        }
    }

    while ((pos_1.x == start_pos.x and pos_1.y == start_pos.y) or (pos_1.x != pos_2.x or pos_1.y != pos_2.y)) : (steps += 1) {
        var c = &lines.items[@as(usize, @intCast(pos_1.y))][@as(usize, @intCast(pos_1.x))];

        if (c.* == 'L' or c.* == 'J' or c.* == '|') {
            c.* = 'x';
        } else {
            c.* = ',';
        }

        c = &lines.items[@as(usize, @intCast(pos_2.y))][@as(usize, @intCast(pos_2.x))];

        if (c.* == 'L' or c.* == 'J' or c.* == '|') {
            c.* = 'x';
        } else {
            c.* = ',';
        }

        pos_1.x += dir_1.x;
        pos_1.y += dir_1.y;
        pos_2.x += dir_2.x;
        pos_2.y += dir_2.y;

        if (next_dir(dir_1, lines.items[@as(usize, @intCast(pos_1.y))][@as(usize, @intCast(pos_1.x))])) |n_dir| {
            dir_1 = n_dir;
        } else {
            std.log.info("Failed to get next dir on {d}, {d}", .{ pos_1.x, pos_1.y });
            std.os.exit(1);
        }
        if (next_dir(dir_2, lines.items[@as(usize, @intCast(pos_2.y))][@as(usize, @intCast(pos_2.x))])) |n_dir| {
            dir_2 = n_dir;
        } else {
            std.log.info("Failed to get next dir on {d}, {d}", .{ pos_2.x, pos_2.y });
            std.os.exit(1);
        }
    }

    // Update the farthest character to x or ,.
    var c1 = &lines.items[@as(usize, @intCast(pos_1.y))][@as(usize, @intCast(pos_1.x))];
    if (c1.* == 'L' or c1.* == 'J' or c1.* == '|') {
        c1.* = 'x';
    } else {
        c1.* = ',';
    }

    var inside: u32 = 0;
    var outside: u32 = 0;

    for (lines.items) |line| {
        for (0..line.len) |x| {
            if (line[x] == ',' or line[x] == 'x') {
                continue;
            }

            var borders: u32 = 0;
            for (x..line.len) |c| {
                if (line[c] == 'x') {
                    borders += 1;
                }
            }

            if (borders % 2 == 1) {
                line[x] = 'I';
                inside += 1;
            } else {
                line[x] = 'O';
                outside += 1;
            }
        }
    }

    std.mem.reverse([]u8, lines.items);

    for (lines.items) |line| {
        std.log.info("{s}", .{line});
    }

    std.log.info("Part 1 result: {d}", .{steps});
    std.log.info("Part 2 result: Inside: {d}, Outside: {d}", .{ inside, outside });
}

fn is_connected(dir: Position, c: u8) bool {
    std.log.info("{c}", .{c});
    if (dir.y == 1) {
        return c == '|' or c == 'F' or c == '7';
    } else if (dir.y == -1) {
        return c == '|' or c == 'J' or c == 'L';
    } else if (dir.x == 1) {
        return c == '-' or c == 'J' or c == '7';
    } else if (dir.x == -1) {
        return c == '-' or c == 'F' or c == 'L';
    }
    return false;
}

fn next_dir(dir: Position, c: u8) ?Position {
    if (dir.x == 1) {
        switch (c) {
            'J' => return .{ .x = 0, .y = 1 },
            '7' => return .{ .x = 0, .y = -1 },
            '-' => return .{ .x = 1, .y = 0 },
            else => return null,
        }
    } else if (dir.x == -1) {
        switch (c) {
            'L' => return .{ .x = 0, .y = 1 },
            'F' => return .{ .x = 0, .y = -1 },
            '-' => return .{ .x = -1, .y = 0 },
            else => return null,
        }
    } else if (dir.y == 1) {
        switch (c) {
            'F' => return .{ .x = 1, .y = 0 },
            '7' => return .{ .x = -1, .y = 0 },
            '|' => return .{ .x = 0, .y = 1 },
            else => return null,
        }
    } else if (dir.y == -1) {
        switch (c) {
            'L' => return .{ .x = 1, .y = 0 },
            'J' => return .{ .x = -1, .y = 0 },
            '|' => return .{ .x = 0, .y = -1 },
            else => return null,
        }
    }

    return null;
}
