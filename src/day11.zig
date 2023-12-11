const std = @import("std");

const ArrayList = std.ArrayList;

const Position = struct {
    x: i32 = 0,
    y: i32 = 0,
};

pub fn solve_part1() !void {
    var is_part_1 = true;

    var inputs = try std.fs.cwd().openFile("inputs/day11.txt", .{});
    var buffered_reader = std.io.bufferedReader(inputs.reader());
    var in_stream = buffered_reader.reader();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = arena.allocator();

    var has_in_column = ArrayList(bool).init(allocator);
    defer has_in_column.deinit();
    var has_in_row = ArrayList(bool).init(allocator);
    defer has_in_row.deinit();

    var galaxy_positions = ArrayList(Position).init(allocator);
    defer galaxy_positions.deinit();

    var line_i: i32 = 0;
    while (try in_stream.readUntilDelimiterOrEofAlloc(allocator, '\n', 100 * 1024)) |line| {
        if (has_in_column.capacity < line.len) {
            try has_in_column.ensureTotalCapacity(line.len);
        }

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

    var i = @as(i32, @intCast(has_in_row.items.len - 1));
    var empty_mult: i32 = if (is_part_1) 2 - 1 else 1_000_000 - 1;

    while (i >= 0) : (i -= 1) {
        var ii: usize = @intCast(i);
        if (!has_in_row.items[ii]) {
            for (galaxy_positions.items) |*position| {
                if (position.y > i) position.y += empty_mult;
            }
        }
    }

    i = @intCast(has_in_column.items.len - 1);

    while (i >= 0) : (i -= 1) {
        var ii: usize = @intCast(i);
        if (!has_in_column.items[ii]) {
            for (galaxy_positions.items) |*position| {
                if (position.x > i) position.x += empty_mult;
            }
        }
    }

    var result_part1: usize = 0;

    for (galaxy_positions.items, 0..) |g1, g_i| {
        for (galaxy_positions.items[g_i..]) |g2| {
            result_part1 += @intCast(try std.math.absInt(g2.x - g1.x) + try std.math.absInt(g1.y - g2.y));
        }
    }

    std.log.info("Part 1: {d}", .{result_part1});
}
