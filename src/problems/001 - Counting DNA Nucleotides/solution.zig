const std = @import("std");

pub fn solution(allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var a_count: usize = 0;
    var c_count: usize = 0;
    var g_count: usize = 0;
    var t_count: usize = 0;

    for (input) |char| {
        switch (char) {
            'A' => a_count += 1,
            'C' => c_count += 1,
            'G' => g_count += 1,
            'T' => t_count += 1,
            else => unreachable,
        }
    }

    const result = std.fmt.allocPrint(allocator, "{d} {d} {d} {d}", .{ a_count, c_count, g_count, t_count });

    return result;
}
