const std = @import("std");
const string = @import("string");
// const heredity = @import("heredity");

pub fn solution(child_allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var arena = std.heap.ArenaAllocator.init(child_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const split_input = try string.split(allocator, input, ' ');
    const final_generation = try std.fmt.parseInt(usize, split_input[0], 10);
    const target_organism_count = try std.fmt.parseInt(usize, split_input[1], 10);
    _ = target_organism_count;

    std.debug.print("{d}\n", .{final_generation});

    return try child_allocator.dupe(u8, "not implemented");
}
