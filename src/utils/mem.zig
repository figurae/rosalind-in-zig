const std = @import("std");

pub fn allocateAndSet(allocator: std.mem.Allocator, comptime T: type, length: usize, element: T) ![]T {
    const array = try allocator.alloc(T, length);
    @memset(array, element);

    return array;
}
