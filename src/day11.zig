const std = @import("std");

const ArrayList = std.ArrayList;

const Position = struct {
    x: i32 = 0,
    y: i32 = 0,
};

pub fn solve_part1() !void {
    var inputs = try std.fs.cwd().openFile("inputs/day11.txt", .{});
    var buffered_reader = std.io.bufferedReader(inputs.reader());
    var in_stream = buffered_reader.reader();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = arena.allocator();

    var lines = ArrayList(ArrayList(u8)).init(allocator);

    var has_in_column = ArrayList(bool).init(allocator);
    var has_in_row = ArrayList(bool).init(allocator);

    var galaxy_positions = ArrayList(Position).init(allocator);

    var line_i: i32 = 0;
    while (try in_stream.readUntilDelimiterOrEofAlloc(allocator, '\n', 100 * 1024)) |line| {
        if (has_in_column.capacity < line.len) {
            try has_in_column.ensureTotalCapacity(line.len);
        }
        var line_list = try ArrayList(u8).initCapacity(allocator, line.len);
        try line_list.appendSlice(line);
        try lines.append(line_list);

        var found_galaxy = false;

        for (line, 0..) |c, i| {
            if (i >= has_in_column.items.len) {
                try has_in_column.append(c == '#');
            } else {
                has_in_column.items[i] = has_in_column.items[i] or c == '#';
            }
            if (c == '#') {
                try galaxy_positions.append(.{
                    .x = @intCast(i),
                    .y = @intCast(line_i),
                });
            }

            found_galaxy = found_galaxy or c == '#';
        }
        try has_in_row.append(found_galaxy);

        allocator.free(line);
        line_i += 1;
    }
    for (lines.items) |l| {
        std.log.info("{s}", .{l.items});
    }

    var i = @as(i32, @intCast(has_in_row.items.len - 1));
    var empty_mult: i32 = 1_000_000 - 1;

    while (i >= 0) : (i -= 1) {
        var ii: usize = @intCast(i);
        std.log.info("Has in row {d}: {}", .{ i, has_in_row.items[ii] });
        if (!has_in_row.items[ii]) {
            var new_line = try ArrayList(u8).initCapacity(allocator, lines.items[0].items.len);
            try new_line.appendSlice(lines.items[ii].items);

            try lines.insert(ii, new_line);
            for (galaxy_positions.items) |*position| {
                if (position.y > i) position.y += empty_mult;
            }
        }
    }

    i = @intCast(has_in_column.items.len - 1);

    while (i >= 0) : (i -= 1) {
        var ii: usize = @intCast(i);
        std.log.info("Has in column {d}: {}", .{ i, has_in_column.items[ii] });
        if (!has_in_column.items[ii]) {
            for (lines.items) |*line| {
                try line.insert(ii, '.');
            }

            for (galaxy_positions.items) |*position| {
                if (position.x > i) position.x += empty_mult;
            }
        }
    }

    for (lines.items) |l| {
        std.log.info("{s}", .{l.items});
    }

    var result_part1: usize = 0;

    for (galaxy_positions.items, 0..) |g1, g_i| {
        for (galaxy_positions.items[g_i..]) |g2| {
            result_part1 += @abs(g2.x - g1.x) + @abs(g1.y - g2.y);
        }
    }

    std.log.info("Part 1: {d}", .{result_part1});
}
