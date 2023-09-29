const std = @import("std");

const String = struct {
    label: []const u8,
    string: []const u8,
};

pub fn solution(child_allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var arena = std.heap.ArenaAllocator.init(child_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const doctored_input = try std.fmt.allocPrint(allocator, "{s}\n>", .{input});
    // TODO: make this OS-agnostic
    var tokenizer = std.mem.tokenize(u8, doctored_input, "\r\n");

    var all_strings = std.ArrayList(String).init(allocator);

    var current_label: []const u8 = undefined;
    var current_string = std.ArrayList(u8).init(allocator);

    while (tokenizer.next()) |token| {
        if (token[0] == '>') {
            if (current_string.items.len > 0) {
                const new_string: String = .{
                    .label = try allocator.dupe(u8, current_label),
                    .string = try current_string.toOwnedSlice(),
                };

                try all_strings.append(new_string);
            }
            current_label = token;
        } else {
            try current_string.appendSlice(token);
        }
    }

    var result: *const String = undefined;
    var highest_percentage: f64 = 0.0;

    for (all_strings.items) |item| {
        const percentage = try computeGCContent(item.string);
        if (percentage > highest_percentage) {
            highest_percentage = percentage;
            result = &item;
        }
    }
    return try std.fmt.allocPrint(child_allocator, "{s}\n{d}", .{ result.label, highest_percentage });
}

fn computeGCContent(input: []const u8) !f64 {
    var count: u32 = 0;

    for (input) |char| {
        switch (char) {
            'G', 'C' => count += 1,
            else => {},
        }
    }

    return @as(f64, @floatFromInt(count)) / @as(f64, @floatFromInt(input.len)) * 100;
}
