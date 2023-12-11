const std = @import("std");

const ArrayList = std.ArrayList;

pub fn solve_part1() !void {
    const stdout = std.io.getStdOut().writer();
    var inputs = try std.fs.cwd().openFile("inputs/day9.txt", .{});
    defer inputs.close();
    var buffered_reader = std.io.bufferedReader(inputs.reader());
    var in_stream = buffered_reader.reader();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = arena.allocator();

    var buffer: [1024]u8 = undefined;

    var number_list: [1024]i64 = undefined;
    var part1_result: i64 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        var iter = std.mem.tokenizeScalar(u8, line, ' ');

        var start: usize = 0;
        var offset: usize = 0;

        while (iter.next()) |token| {
            number_list[offset] = try std.fmt.parseInt(i64, token, 10);
            std.log.info("Found: {d}", .{number_list[offset]});
            offset += 1;
        }

        std.mem.reverse(i64, number_list[0..offset]);

        std.log.info("----", .{});

        var ending_numbers = ArrayList(i64).init(allocator);

        try ending_numbers.append(number_list[offset - 1]);

        while (offset > 0) {
            for (start..offset) |i| {
                try stdout.print("{d}, ", .{number_list[i]});
            }
            try stdout.print("\n", .{});
            var s = start;
            var amount = offset - start - 1;
            start = offset;

            for (s..s + amount) |n| {
                number_list[offset] = number_list[n + 1] - number_list[n];
                offset += 1;
            }

            try ending_numbers.append(number_list[offset - 1]);

            var first = number_list[start];

            var all_equal = blk: for (start + 1..offset) |n| {
                if (first != number_list[n]) break :blk false;
            } else true;

            if (!all_equal) continue;

            var previous: i64 = 0;

            std.mem.reverse(i64, ending_numbers.items);

            std.log.info("------------------- d", .{});

            for (ending_numbers.items) |n| {
                previous += n;
                std.log.info("E number: {d}, previous: {d}", .{ n, previous });
            }
            std.log.info("Result: {d}\n----------", .{previous});
            part1_result += previous;
            break;
        }
    }

    std.log.info("Part 1: {d}", .{part1_result});
}
