const std = @import("std");
const globals = @import("globals.zig");
const runSolution = @import("runSolution.zig").runSolution;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    const result = try runSolution(allocator, 15, .sample);
    // TODO: can we check whether result is heap- or stack-allocated?
    defer allocator.free(result);

    std.debug.print("{s}\n", .{result});
}
