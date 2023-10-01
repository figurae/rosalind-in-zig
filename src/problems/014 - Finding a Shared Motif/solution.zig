const std = @import("std");
const data = @import("data");

pub fn solution(child_allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var arena = std.heap.ArenaAllocator.init(child_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const strings = try data.getStringsFromFasta(allocator, input);
    const pure_strings = try data.getPureStrings(allocator, strings);
    const longest_common_substring = data.getLongestCommonSubstring(pure_strings);

    return try child_allocator.dupe(u8, longest_common_substring.?);
}
