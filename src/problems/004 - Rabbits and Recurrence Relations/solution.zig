const std = @import("std");
const string = @import("string");

const RabbitAge = enum {
    young,
    adult,
};

const Rabbit = struct {
    age: RabbitAge,
};

pub fn solution(allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    const split_input = try string.split(allocator, input, ' ');
    defer {
        for (split_input) |chunk| {
            allocator.free(chunk);
        }
        allocator.free(split_input);
    }

    const target_generation = try std.fmt.parseInt(usize, split_input[0], 10);
    const litter_size = try std.fmt.parseInt(usize, split_input[1], 10);

    var rabbits = std.ArrayList(Rabbit).init(allocator);
    defer rabbits.deinit();

    const first_rabbit: Rabbit = .{ .age = .young };
    try rabbits.append(first_rabbit);

    try countRabbitPairs(allocator, 1, target_generation, litter_size, &rabbits);
    const rabbitPairs = std.fmt.allocPrint(allocator, "{d}", .{rabbits.items.len});

    return rabbitPairs;
}

fn countRabbitPairs(allocator: std.mem.Allocator, current_gen: usize, target_gen: usize, litter_size: usize, rabbits: *std.ArrayList(Rabbit)) !void {
    if (current_gen < target_gen) {
        var new_rabbits = std.ArrayList(Rabbit).init(allocator);
        defer new_rabbits.deinit();

        for (rabbits.*.items) |*rabbit| {
            if (rabbit.age == .adult) {
                for (0..litter_size) |_| {
                    const new_rabbit = .{ .age = .young };
                    try new_rabbits.append(new_rabbit);
                }
            } else {
                rabbit.age = .adult;
            }
        }

        if (new_rabbits.items.len > 0) try rabbits.appendSlice(new_rabbits.items);

        try countRabbitPairs(allocator, current_gen + 1, target_gen, litter_size, rabbits);
    }
}
