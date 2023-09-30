const std = @import("std");
const mem = @import("mem");

const Allele = enum { dominant, recessive };

const OrganismType = enum { homozygous_dominant, heterozygous, homozygous_recessive };

const Organism = struct {
    alleles: [2]Allele,
    type: OrganismType,
};

pub fn solution(allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    // NOTE: these are all the same factors, but it doesn't matter here
    const homozygous_dominant: Organism = .{ .alleles = .{ .dominant, .dominant }, .type = .homozygous_dominant };
    const heterozygous: Organism = .{ .alleles = .{ .dominant, .recessive }, .type = .heterozygous };
    const homozygous_recessive: Organism = .{ .alleles = .{ .recessive, .recessive }, .type = .homozygous_recessive };

    var tokenizer = std.mem.tokenize(u8, input, " ");

    var totals = [_]usize{0} ** 3;

    var index: usize = 0;
    while (tokenizer.next()) |token| : (index += 1) {
        totals[index] = try std.fmt.parseInt(usize, token, 10);
    }

    var groups: [3][]Organism = .{
        try mem.allocateAndSet(allocator, Organism, totals[0], homozygous_dominant),
        try mem.allocateAndSet(allocator, Organism, totals[1], heterozygous),
        try mem.allocateAndSet(allocator, Organism, totals[2], homozygous_recessive),
    };
    defer {
        for (groups) |group| {
            allocator.free(group);
        }
    }

    var sum_of_probabilities: f64 = 0.0;

    for (groups, 0..) |left_group, i| {
        for (groups[i..]) |right_group| {
            const same_group_modifier: usize = if (left_group[0].type == right_group[0].type) 1 else 0;
            for (left_group, 0..) |left_organism, j| {
                const k = if (same_group_modifier == 1) j + same_group_modifier else 0;
                for (right_group[k..]) |right_organism| {
                    sum_of_probabilities += getProbabilityOfDominantAlleleInOffspring(left_organism.alleles, right_organism.alleles);
                }
            }
        }
    }

    const number_of_organisms = @as(f64, @floatFromInt(totals[0] + totals[1] + totals[2]));
    const number_of_pairs = ((number_of_organisms * (number_of_organisms - 1.0)) / 2.0);

    const result = sum_of_probabilities / number_of_pairs;

    return try std.fmt.allocPrint(allocator, "{d}", .{result});
}

fn getProbabilityOfDominantAlleleInOffspring(left_alleles: [2]Allele, right_alleles: [2]Allele) f64 {
    var dominant_allele_count: f64 = 0.0;

    for (left_alleles) |left_allele| {
        for (right_alleles) |right_allele| {
            if (left_allele == .dominant or right_allele == .dominant) {
                dominant_allele_count += 1;
                continue;
            }
        }
    }

    return dominant_allele_count / 4.0;
}
