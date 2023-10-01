const std = @import("std");
const string = @import("string");

pub const String = struct {
    label: []const u8,
    string: []const u8,
};

pub fn getStringsFromFasta(allocator: std.mem.Allocator, input: []const u8) ![]String {
    const line_break = string.getLineBreak(input);

    // NOTE: I don't think this is necessary
    const doctored_input = try std.fmt.allocPrint(allocator, "{s}{s}>", .{ input, line_break });
    defer allocator.free(doctored_input);

    var tokenizer = std.mem.tokenize(u8, doctored_input, line_break);

    var all_strings = std.ArrayList(String).init(allocator);

    var current_label: []const u8 = undefined;
    var current_string = std.ArrayList(u8).init(allocator);

    while (tokenizer.next()) |token| {
        if (token[0] == '>') {
            if (current_string.items.len > 0) {
                const new_string: String = .{
                    .label = try allocator.dupe(u8, current_label[1..]),
                    .string = try current_string.toOwnedSlice(),
                };

                try all_strings.append(new_string);
            }
            current_label = token;
        } else {
            try current_string.appendSlice(token);
        }
    }

    return all_strings.toOwnedSlice();
}
