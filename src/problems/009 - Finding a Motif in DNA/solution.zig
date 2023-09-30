const std = @import("std");
const string = @import("string");

pub fn solution(child_allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var arena = std.heap.ArenaAllocator.init(child_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const lines = try string.splitByLines(allocator, input);
    const haystack = lines[0];
    const needle = lines[1];

    var positions = std.ArrayList([]const u8).init(allocator);

    var index: usize = 0;
    const max_index = haystack.len - needle.len;

    while (index <= max_index) : (index += 1) {
        // const needle_index = std.ascii.indexOfIgnoreCasePos(haystack, index, needle);
        // NOTE: oh hey, there's indexOf at home
        const needle_index = try myIndexOf(haystack, index, needle);

        if (needle_index) |i| {
            try positions.append(try std.fmt.allocPrint(allocator, "{d}", .{i + 1}));
            index = i;
        } else {
            break;
        }
    }

    const result = try std.mem.join(child_allocator, " ", positions.items);

    return result;
}

fn myIndexOf(haystack: []const u8, index: usize, needle: []const u8) !?usize {
    const max_index = haystack.len - needle.len;

    if (index < 0 or index > max_index) return null;

    // NOTE: I guess std.mem.window would be fine too
    for (index..max_index + 1) |i| {
        if (try string.isEqual(haystack[i .. i + needle.len], needle)) return i;
    }

    return null;
}
