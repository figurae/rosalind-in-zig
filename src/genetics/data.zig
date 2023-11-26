const std = @import("std");
const math = @import("math");
const string = @import("string");

pub const String = struct {
    label: []const u8,
    string: []const u8,
};

pub fn getStringsFromFasta(allocator: std.mem.Allocator, input: []const u8) ![]const String {
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

pub fn getPureStrings(allocator: std.mem.Allocator, strings: []const String) ![]const []const u8 {
    const pure_strings = try allocator.alloc([]const u8, strings.len);

    for (pure_strings, 0..) |*s, i| {
        s.* = strings[i].string;
    }

    return pure_strings;
}

// NOTE: there can be multiple longest common substrings
pub fn getLongestCommonSubstring(strings: []const []const u8) ?[]const u8 {
    var window_length: usize = std.math.maxInt(usize);
    var shortest_string: *const []const u8 = undefined;

    for (0..strings.len) |i| {
        if (strings[i].len < window_length) {
            window_length = strings[i].len;
            shortest_string = &strings[i];
        }
    }

    // NOTE: this could benefit from removing shortest_string from strings
    // I wonder if this is doable without an allocator
    while (window_length > 0) : (window_length -= 1) {
        var window = std.mem.window(u8, shortest_string.*, window_length, 1);

        while (window.next()) |slice| {
            if (isCommonSubstring(slice, strings)) return slice;
        }
    }

    return null;
}

fn isCommonSubstring(substring: []const u8, strings: []const []const u8) bool {
    var max_window_length: usize = std.math.maxInt(usize);
    for (strings) |s| {
        if (s.len < max_window_length) max_window_length = s.len;
    }
    std.debug.assert(substring.len <= max_window_length);

    for (strings) |s| {
        const len = substring.len;
        var window = std.mem.window(u8, s, len, 1);
        var found = false;

        while (window.next()) |slice| {
            if (std.mem.eql(u8, substring, slice)) {
                found = true;
                break;
            }
        }

        if (!found) return false;
    }

    return true;
}
