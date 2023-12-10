const std = @import("std");

const ArrayList = std.ArrayList;

const Position = struct {
    x: i64 = 0,
    y: i64 = 0,
};

const LineSegment = struct {
    start: Position,
    end: Position,
};

pub fn solve_part1() !void {
    var inputs = try std.fs.cwd().openFile("inputs/day10.txt", .{});
    var buffered_reader = std.io.bufferedReader(inputs.reader());
    var in_stream = buffered_reader.reader();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = arena.allocator();

    var lines = ArrayList([]u8).init(allocator);

    var positions = ArrayList(Position).init(allocator);
    _ = positions;

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
    var dir_1_pos: Position = start_pos;

    var dir_2: Position = .{};
    var dir_2_pos: Position = start_pos;

    var found_connections: i32 = 0;

    if (start_pos.y < lines.items.len - 1 and is_connected(.{ .x = 0, .y = 1 }, lines.items[@as(usize, @intCast(start_pos.y + 1))][@as(usize, @intCast(start_pos.x))])) {
        if (found_connections == 0) {
            dir_1.y = 1;
        } else {
            dir_2.y = 1;
        }
        found_connections += 1;
    }
    if (start_pos.y != 0 and is_connected(.{ .x = 0, .y = -1 }, lines.items[@as(usize, @intCast(start_pos.y - 1))][@as(usize, @intCast(start_pos.x))])) {
        if (found_connections == 0) {
            dir_1.y = -1;
        } else {
            dir_2.y = -1;
        }
        found_connections += 1;
    }
    if (start_pos.x < lines.items[0].len - 1 and is_connected(.{ .x = 1, .y = 0 }, lines.items[@as(usize, @intCast(start_pos.y))][@as(usize, @intCast(start_pos.x + 1))])) {
        if (found_connections == 0) {
            dir_1.x = 1;
        } else {
            dir_2.x = 1;
        }
        found_connections += 1;
    }
    if (start_pos.x != 0 and is_connected(.{ .x = -1, .y = 0 }, lines.items[@as(usize, @intCast(start_pos.y))][@as(usize, @intCast(start_pos.x - 1))])) {
        if (found_connections == 0) {
            dir_1.x = -1;
        } else {
            dir_2.x = -1;
        }
        found_connections += 1;
    }

    if (found_connections > 2) {
        std.log.err("Found too many connections! Found: {d}", .{found_connections});
    } else if (found_connections < 2) {
        std.log.err("Found too few connections! Found: {d}", .{found_connections});
    }

    var found = false;

    while ((dir_1_pos.x == start_pos.x and dir_1_pos.y == start_pos.y) or (dir_1_pos.x != dir_2_pos.x or dir_1_pos.y != dir_2_pos.y)) : (steps += 1) {
        var c = lines.items[@as(usize, @intCast(dir_1_pos.y))][@as(usize, @intCast(dir_1_pos.x))];

        if (dir_1_pos.x == 8 and dir_1_pos.y == 5) {
            found = true;
            std.log.info("Pipe? {c}", .{c});
        }

        if (c == 'L' or c == 'J' or c == '|') {
            lines.items[@as(usize, @intCast(dir_1_pos.y))][@as(usize, @intCast(dir_1_pos.x))] = 'x';
        } else {
            lines.items[@as(usize, @intCast(dir_1_pos.y))][@as(usize, @intCast(dir_1_pos.x))] = ',';
        }

        c = lines.items[@as(usize, @intCast(dir_2_pos.y))][@as(usize, @intCast(dir_2_pos.x))];
        if (dir_2_pos.x == 8 and dir_2_pos.y == 5) {
            found = true;
            std.log.info("Pipe? {c}", .{c});
        }

        if (c == 'L' or c == 'J' or c == '|') {
            lines.items[@as(usize, @intCast(dir_2_pos.y))][@as(usize, @intCast(dir_2_pos.x))] = 'x';
        } else {
            lines.items[@as(usize, @intCast(dir_2_pos.y))][@as(usize, @intCast(dir_2_pos.x))] = ',';
        }

        dir_1_pos.x += dir_1.x;
        dir_1_pos.y += dir_1.y;
        dir_2_pos.x += dir_2.x;
        dir_2_pos.y += dir_2.y;

        if (next_dir(dir_1, lines.items[@as(usize, @intCast(dir_1_pos.y))][@as(usize, @intCast(dir_1_pos.x))])) |n_dir| {
            dir_1 = n_dir;
        } else {
            std.log.info("Failed to get next dir on {d}, {d}", .{ dir_1_pos.x, dir_1_pos.y });
            std.os.exit(1);
        }
        if (next_dir(dir_2, lines.items[@as(usize, @intCast(dir_2_pos.y))][@as(usize, @intCast(dir_2_pos.x))])) |n_dir| {
            dir_2 = n_dir;
        } else {
            std.log.info("Failed to get next dir on {d}, {d}", .{ dir_1_pos.x, dir_1_pos.y });
            std.os.exit(1);
        }
    }

    var c1 = lines.items[@as(usize, @intCast(dir_1_pos.y))][@as(usize, @intCast(dir_1_pos.x))];
    if (c1 == 'L' or c1 == 'J' or c1 == '|') {
        lines.items[@as(usize, @intCast(dir_1_pos.y))][@as(usize, @intCast(dir_1_pos.x))] = 'x';
    } else {
        lines.items[@as(usize, @intCast(dir_1_pos.y))][@as(usize, @intCast(dir_1_pos.x))] = ',';
    }

    var inside: u32 = 0;
    var outside: u32 = 0;

    for (lines.items, 0..) |line, y| {
        for (0..line.len) |x| {
            var yy = y;
            _ = yy;
            var xx = x;
            _ = xx;

            //if (line[x] == '-' or line[x] == 'F' or line[x] == '7' or line[x] == 'J' or line[x] == 'L' or line[x] == '|') {
            //    line[x] = ' ';
            //    continue;
            // }

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
    std.log.info("Part 2 result: {d}, {d}", .{ inside, outside });
}

fn is_connected(dir: Position, c: u8) bool {
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
