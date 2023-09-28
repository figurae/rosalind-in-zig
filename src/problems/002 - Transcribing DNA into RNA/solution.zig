const std = @import("std");

pub fn solution(allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var output = std.ArrayList(u8).init(allocator);
    defer output.deinit();

    for (input) |char| {
        try switch (char) {
            'T' => output.append('U'),
            else => output.append(char),
        };
    }

    return try output.toOwnedSlice();
}
