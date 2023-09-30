const std = @import("std");
const string = @import("string");

// NOTE: can this be imported without .Codon?
const Codon = @import("Codon").Codon;

pub fn solution(allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var protein_string = std.ArrayList(u8).init(allocator);
    defer protein_string.deinit();

    var codon_iterator = std.mem.window(u8, input, 3, 3);

    while (codon_iterator.next()) |slice| {
        const translation_result = translateCodonToAminoAcid(slice);
        if (translation_result == .stop) break;
        try protein_string.append(translation_result.amino_acid);
    }

    return try protein_string.toOwnedSlice();
}

const TranslationResult = enum { stop, amino_acid };
const Result = union(TranslationResult) { stop: bool, amino_acid: u8 };

fn translateCodonToAminoAcid(codon: []const u8) Result {
    const codon_enum = std.meta.stringToEnum(Codon, codon).?;

    const result: Result = switch (codon_enum) {
        .UUU, .UUC => .{ .amino_acid = 'F' },
        .UUA, .UUG, .CUU, .CUC, .CUA, .CUG => .{ .amino_acid = 'L' },
        .UCU, .UCC, .UCA, .UCG, .AGU, .AGC => .{ .amino_acid = 'S' },
        .UAU, .UAC => .{ .amino_acid = 'Y' },
        .UAA, .UAG, .UGA => .{ .stop = true },
        .UGU, .UGC => .{ .amino_acid = 'C' },
        .UGG => .{ .amino_acid = 'W' },
        .CCU, .CCC, .CCA, .CCG => .{ .amino_acid = 'P' },
        .CAU, .CAC => .{ .amino_acid = 'H' },
        .CAA, .CAG => .{ .amino_acid = 'Q' },
        .CGU, .CGC, .CGA, .CGG, .AGA, .AGG => .{ .amino_acid = 'R' },
        .AUU, .AUC, .AUA => .{ .amino_acid = 'I' },
        .AUG => .{ .amino_acid = 'M' },
        .ACU, .ACC, .ACA, .ACG => .{ .amino_acid = 'T' },
        .AAU, .AAC => .{ .amino_acid = 'N' },
        .AAA, .AAG => .{ .amino_acid = 'K' },
        .GUU, .GUC, .GUA, .GUG => .{ .amino_acid = 'V' },
        .GCU, .GCC, .GCA, .GCG => .{ .amino_acid = 'A' },
        .GAU, .GAC => .{ .amino_acid = 'D' },
        .GAA, .GAG => .{ .amino_acid = 'E' },
        .GGU, .GGC, .GGA, .GGG => .{ .amino_acid = 'G' },
    };

    return result;
}
