const std = @import("std");
const string = @import("string");

pub fn solution(child_allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var arena = std.heap.ArenaAllocator.init(child_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const strings = try string.splitByLines(allocator, input);

    const result = getHammingDistance(strings[0], strings[1]);

    return try std.fmt.allocPrint(child_allocator, "{d}", .{result});
}

fn getHammingDistance(left_string: []const u8, right_string: []const u8) usize {
    std.debug.assert(left_string.len == right_string.len);
    var distance: usize = 0;

    for (0..left_string.len) |index| {
        if (left_string[index] != right_string[index]) distance += 1;
    }

    return distance;
}
