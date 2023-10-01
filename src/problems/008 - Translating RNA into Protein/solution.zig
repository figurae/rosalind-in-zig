const std = @import("std");
const string = @import("string");
const encoding = @import("encoding");

pub fn solution(allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var protein_string = std.ArrayList(u8).init(allocator);
    defer protein_string.deinit();

    var codon_iterator = std.mem.window(u8, input, 3, 3);

    while (codon_iterator.next()) |slice| {
        const translation_result = encoding.translateCodonToAminoAcid(slice);
        if (translation_result == .stop) break;
        try protein_string.append(translation_result.amino_acid);
    }

    return try protein_string.toOwnedSlice();
}
