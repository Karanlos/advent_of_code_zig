const std = @import("std");
pub fn day1_part1() anyerror!void {
    var file = try std.fs.cwd().openFile("inputs/day1.txt", .{});
    defer file.close();

    var buffered_reader = std.io.bufferedReader(file.reader());
    var in_stream = buffered_reader.reader();

    var buf: [1024]u8 = undefined;

    var accum: u32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var first_digit: ?u32 = null;
        var last_digit: ?u32 = null;
        for (line) |c| {
            if (c >= '0' and c <= '9') {
                const digit = c - '0';

                if (first_digit == null) first_digit = digit;

                last_digit = digit;
            }
        }

        if (first_digit != null and last_digit != null) {
            accum = accum + first_digit.? * 10 + last_digit.?;
        } else {
            std.log.err("Didn't find any digits!", .{});
        }
    }

    std.log.info("Part 1 result: {d}", .{accum});
}

pub fn day1_part2() anyerror!void {
    var file = try std.fs.cwd().openFile("inputs/day1.txt", .{});
    defer file.close();

    var buffered_reader = std.io.bufferedReader(file.reader());
    var in_stream = buffered_reader.reader();

    var buf: [1024]u8 = undefined;

    var accum: u32 = 0;

    const numbers = [_][]const u8{
        "one",
        "two",
        "three",
        "four",
        "five",
        "six",
        "seven",
        "eight",
        "nine",
    };

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var first_digit: ?u8 = null;
        var last_digit: ?u8 = null;
        for (line, 0..) |c, i| {
            var digit: ?u8 = null;
            if (c >= '0' and c <= '9') {
                digit = c - '0';
            } else {
                for (numbers, 1..) |number, digit_value| {
                    if (std.mem.startsWith(u8, line[i..], number)) {
                        digit = @intCast(digit_value);
                    }
                }
            }

            if (digit) |val| {
                if (first_digit == null) {
                    first_digit = val;
                }

                last_digit = val;
            }
        }

        if (first_digit != null and last_digit != null) {
            accum = accum + first_digit.? * 10 + last_digit.?;
        } else {
            std.log.err("Didn't find any digits!", .{});
        }
    }

    std.log.info("Part 2 result: {d}", .{accum});
}
