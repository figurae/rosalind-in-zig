const std = @import("std");

pub fn split(allocator: std.mem.Allocator, string: []const u8, delimiter: u8) ![]const []const u8 {
    var split_chunks = std.ArrayList([]const u8).init(allocator);
    var chunk = std.ArrayList(u8).init(allocator);
    defer split_chunks.deinit();
    defer chunk.deinit();

    for (string) |char| {
        if (char == delimiter) {
            if (chunk.items.len > 0) {
                const chunk_text = try allocator.dupe(u8, chunk.items);
                try split_chunks.append(chunk_text);
                chunk.clearAndFree();
            }
        } else {
            try chunk.append(char);
        }
    }
    if (chunk.items.len > 0) {
        const chunk_text = try allocator.dupe(u8, chunk.items);
        try split_chunks.append(chunk_text);
    }

    return split_chunks.toOwnedSlice();
}

pub fn splitByLines(allocator: std.mem.Allocator, string: []const u8) ![]const []const u8 {
    const line_break = getLineBreak(string);
    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    var tokenizer = std.mem.tokenize(u8, string, line_break);

    while (tokenizer.next()) |token| {
        try lines.append(token);
    }

    return lines.toOwnedSlice();
}

fn getLineBreak(string: []const u8) []const u8 {
    const lf = std.ascii.indexOfIgnoreCase(string, "\n");
    const cr = std.ascii.indexOfIgnoreCase(string, "\r");

    if (lf != null and cr != null and cr.? == lf.? - 1) {
        return "\r\n";
    }

    // NOTE: this isn't very robust
    if (lf != null) {
        return "\n";
    } else {
        return "\r";
    }
}

pub fn isEqual(first_string: []const u8, second_string: []const u8) !bool {
    if (first_string.len != second_string.len) return false;

    for (0..first_string.len) |index| {
        const first_char = first_string[index];
        const second_char = second_string[index];

        if (first_char != second_char) return false;
    }

    return true;
}

pub fn padLeft(allocator: std.mem.Allocator, string: []const u8, target_length: usize, char: u8) ![]const u8 {
    if (string.len >= target_length) return string;

    var padded_string = try allocator.alloc(u8, target_length);
    @memset(padded_string, char);

    var reverse_iterator = std.mem.reverseIterator(string);
    var index = target_length - 1;

    while (reverse_iterator.next()) |source_char| : (index -= 1) {
        padded_string[index] = source_char;
    }

    return padded_string;
}
