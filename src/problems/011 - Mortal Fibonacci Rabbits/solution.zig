const std = @import("std");
const string = @import("string");

const RabbitPair = struct {
    age: usize,
};

pub fn solution(child_allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var arena = std.heap.ArenaAllocator.init(child_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const split_input = try string.split(allocator, input, ' ');

    const target_generation = try std.fmt.parseInt(usize, split_input[0], 10);
    const maximum_age = try std.fmt.parseInt(usize, split_input[1], 10);

    const rabbit_pairs = try countRabbitPairs(allocator, target_generation, maximum_age);
    return try std.fmt.allocPrint(child_allocator, "{d}", .{rabbit_pairs});
}

fn countRabbitPairs(allocator: std.mem.Allocator, target_gen: usize, maximum_age: usize) !u128 {
    var rabbit_pairs = std.ArrayList(u128).init(allocator);
    try rabbit_pairs.appendSlice(&[_]u128{ 1, 1 });

    for (2..target_gen) |i| {
        var tmp = rabbit_pairs.items[i - 1] + rabbit_pairs.items[i - 2];
        if (i == maximum_age) {
            tmp -= 1;
        }
        if (i > maximum_age) {
            tmp -= rabbit_pairs.items[i - maximum_age - 1];
        }
        try rabbit_pairs.append(tmp);
    }

    const last_index = rabbit_pairs.items.len - 1;
    return rabbit_pairs.items[last_index];
}
