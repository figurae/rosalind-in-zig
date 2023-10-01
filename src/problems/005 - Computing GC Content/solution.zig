const std = @import("std");
const data = @import("data");

pub fn solution(child_allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var arena = std.heap.ArenaAllocator.init(child_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const strings = try data.getStringsFromFasta(allocator, input);

    var result_label: []const u8 = undefined;
    var highest_percentage: f64 = 0.0;

    for (strings) |string| {
        const percentage = computeGCContent(string.string);
        if (percentage > highest_percentage) {
            highest_percentage = percentage;
            result_label = string.label;
        }
    }

    return try std.fmt.allocPrint(child_allocator, "{s}\n{d}", .{ result_label, highest_percentage });
}

fn computeGCContent(input: []const u8) f64 {
    var count: u32 = 0;

    for (input) |char| {
        switch (char) {
            'G', 'C' => count += 1,
            else => {},
        }
    }

    return @as(f64, @floatFromInt(count)) / @as(f64, @floatFromInt(input.len)) * 100.0;
}
