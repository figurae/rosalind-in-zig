const std = @import("std");

pub fn solution(allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var output = std.ArrayList(u8).init(allocator);
    defer output.deinit();

    var iterator = std.mem.reverseIterator(input);
    while (iterator.next()) |char| {
        try switch (char) {
            'A' => output.append('T'),
            'T' => output.append('A'),
            'C' => output.append('G'),
            'G' => output.append('C'),
            else => unreachable,
        };
    }

    return try output.toOwnedSlice();
}
