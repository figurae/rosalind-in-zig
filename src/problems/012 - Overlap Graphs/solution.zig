const std = @import("std");
const data = @import("data");

const Adjacency = struct {
    left: []const u8,
    right: []const u8,
};

pub fn solution(child_allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var arena = std.heap.ArenaAllocator.init(child_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const length = 3;
    const strings = try data.getStringsFromFasta(allocator, input);
    var adjacencies = std.ArrayList(u8).init(child_allocator);

    for (strings, 0..) |left_string, i| {
        for (strings[i + 1 ..]) |right_string| {
            const lhs = left_string.string;
            const rhs = right_string.string;

            const lhs_head = lhs[0..length];
            const lhs_tail = lhs[lhs.len - length ..];
            const rhs_head = rhs[0..length];
            const rhs_tail = rhs[rhs.len - length ..];

            const fmt = "{s} {s}\n";

            // NOTE: this could use something like switch (true)...
            const adjacency: ?Adjacency = if (std.mem.eql(u8, rhs_tail, lhs_head))
                .{ .left = right_string.label, .right = left_string.label }
            else if (std.mem.eql(u8, lhs_tail, rhs_head))
                .{ .left = left_string.label, .right = right_string.label }
            else
                null;

            if (adjacency) |a| {
                const adjacency_string = try std.fmt.allocPrint(allocator, fmt, a);
                try adjacencies.appendSlice(adjacency_string);
            }
        }
    }

    _ = adjacencies.swapRemove(adjacencies.items.len - 1);

    return adjacencies.toOwnedSlice();
}
