const std = @import("std");

pub fn solution(child_allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    _ = input;
    var arena = std.heap.ArenaAllocator.init(child_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    _ = allocator;

    return try child_allocator.dupe(u8, "not implemented");
}
