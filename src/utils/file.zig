const std = @import("std");

pub fn readToString(allocator: *const std.mem.Allocator, filename: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const text = try file.reader().readAllAlloc(allocator.*, std.math.maxInt(usize));

    return text;
}
