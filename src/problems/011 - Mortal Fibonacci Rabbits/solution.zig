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
    const litter_size = 1;

    var rabbits = std.ArrayList(RabbitPair).init(allocator);

    var first_rabbit_pair: RabbitPair = .{ .age = 0 };
    try rabbits.append(first_rabbit_pair);

    try countRabbitPairs(allocator, 1, target_generation, litter_size, maximum_age, &rabbits);
    const rabbitPairs = try std.fmt.allocPrint(child_allocator, "{d}", .{rabbits.items.len});

    return rabbitPairs;
}

fn countRabbitPairs(allocator: std.mem.Allocator, current_gen: usize, target_gen: usize, litter_size: usize, maximum_age: usize, rabbits: *std.ArrayList(RabbitPair)) !void {
    if (current_gen < target_gen) {
        var new_rabbits = std.ArrayList(RabbitPair).init(allocator);
        defer new_rabbits.deinit();

        for (rabbits.*.items) |*rabbit_pair| {
            if (rabbit_pair.age > 0 and rabbit_pair.age < maximum_age - 1) {
                for (0..litter_size) |_| {
                    var new_rabbit_pair = .{ .age = 0 };
                    try new_rabbits.append(new_rabbit_pair);
                }
            }

            rabbit_pair.age += 1;

            // NOTE: it's more of a reincarnation but hey, it works!
            if (rabbit_pair.age >= maximum_age) {
                rabbit_pair.age = 0;
            }
        }

        if (new_rabbits.items.len > 0) try rabbits.appendSlice(new_rabbits.items);

        try countRabbitPairs(allocator, current_gen + 1, target_gen, litter_size, maximum_age, rabbits);
    }
}
