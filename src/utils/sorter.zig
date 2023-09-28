const std = @import("std");

// TODO: try implementing sorting order
pub fn sortStrings(allocator: std.mem.Allocator, strings: []const []const u8) ![]const []const u8 {
    var sortedStrings = try allocator.alloc([]const u8, strings.len);
    std.mem.copy([]const u8, sortedStrings, strings);

    try quicksort(sortedStrings, 0, sortedStrings.len - 1);

    return sortedStrings;
}

fn quicksort(strings: [][]const u8, start: usize, end: usize) !void {
    if (start >= 0 and end >= 0 and start < end) {
        const pivot_index = try partition(strings, start, end);
        try quicksort(strings, start, pivot_index);
        try quicksort(strings, pivot_index + 1, end);
    }
}

fn partition(strings: [][]const u8, start: usize, end: usize) !usize {
    // TODO: use a better algorithm for picking the pivot
    // also, maybe use floats earlier...
    const f_start = @as(f32, @floatFromInt(start));
    const f_end = @as(f32, @floatFromInt(end));
    const floored_half = std.math.floor((f_end - f_start) / 2);
    const i_floored_half = @as(usize, @intFromFloat(floored_half));
    const pivot_index = i_floored_half + start;

    const pivot_value = strings[pivot_index];

    // TODO: uhhh... do not like
    var i: isize = @as(isize, @intCast(start)) - 1;
    var j = end + 1;

    while (true) {
        while (true) {
            i += 1;
            if (try compareStrings(strings[@as(usize, @intCast(i))], pivot_value) >= 0) {
                break;
            }
        }

        while (true) {
            j -= 1;
            if (try compareStrings(strings[j], pivot_value) <= 0) {
                break;
            }
        }

        if (i >= j) {
            return j;
        }

        if (i != j and try compareStrings(strings[@as(usize, @intCast(i))], strings[j]) != 0) {
            std.mem.swap([]const u8, &strings[@as(usize, @intCast(i))], &strings[j]);
        }
    }
}

fn compareStrings(first_string: []const u8, second_string: []const u8) !isize {
    const smaller_length = @min(first_string.len, second_string.len);

    for (0..smaller_length) |index| {
        const a = std.ascii.toLower(first_string[index]);
        const b = std.ascii.toLower(second_string[index]);

        if (a < b) {
            return -1;
        }
        if (a > b) {
            return 1;
        }
    }

    // TODO: I don't think this needs to be so verbose
    if (first_string.len == second_string.len) {
        return 0;
    } else if (first_string.len < second_string.len) {
        return -1;
    } else {
        return 1;
    }
}
