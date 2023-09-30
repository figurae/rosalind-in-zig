const std = @import("std");

const Allele = enum { dominant, recessive };

const Organism = [2]Allele;

pub fn solution(allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    // NOTE: these are all the same factors, but it doesn't matter here
    const heterozygous: Organism = .{ .dominant, .recessive };
    const homozygous_recessive: Organism = .{ .recessive, .recessive };
    const homozygous_dominant: Organism = .{ .dominant, .dominant };

    var tokenizer = std.mem.tokenize(u8, input, " ");

    var totals = [_]usize{0} ** 3;

    var index: usize = 0;
    while (tokenizer.next()) |token| : (index += 1) {
        totals[index] = try std.fmt.parseInt(usize, token, 10);
    }

    const total_homozygous_dominant = totals[0];
    const total_heterozygous = totals[1];
    const total_homozygous_recessive = totals[2];

    var sum_of_probabilities: f64 = 0.0;
    var number_of_pairs: f64 = 0.0;

    // NOTE: there should be a way to not write these by hand?
    for (0..total_homozygous_dominant) |_| {
        for (0..total_heterozygous) |_| {
            number_of_pairs += 1;
            sum_of_probabilities += getProbabilityOfDominantAlleleInOffspring(homozygous_dominant, heterozygous);
        }
    }

    for (0..total_homozygous_dominant) |_| {
        for (0..total_homozygous_recessive) |_| {
            number_of_pairs += 1;
            sum_of_probabilities += getProbabilityOfDominantAlleleInOffspring(homozygous_dominant, homozygous_recessive);
        }
    }

    for (0..total_heterozygous) |_| {
        for (0..total_homozygous_recessive) |_| {
            number_of_pairs += 1;
            sum_of_probabilities += getProbabilityOfDominantAlleleInOffspring(heterozygous, homozygous_recessive);
        }
    }

    for (0..total_homozygous_dominant) |i| {
        for (i + 1..total_homozygous_dominant) |_| {
            number_of_pairs += 1;
            sum_of_probabilities += getProbabilityOfDominantAlleleInOffspring(homozygous_dominant, homozygous_dominant);
        }
    }

    for (0..total_heterozygous) |i| {
        for (i + 1..total_heterozygous) |_| {
            number_of_pairs += 1;
            sum_of_probabilities += getProbabilityOfDominantAlleleInOffspring(heterozygous, heterozygous);
        }
    }

    for (0..total_homozygous_recessive) |i| {
        for (i + 1..total_homozygous_recessive) |_| {
            number_of_pairs += 1;
            sum_of_probabilities += getProbabilityOfDominantAlleleInOffspring(homozygous_recessive, homozygous_recessive);
        }
    }

    const result = sum_of_probabilities / number_of_pairs;

    return try std.fmt.allocPrint(allocator, "{d}", .{result});
}

fn getProbabilityOfDominantAlleleInOffspring(left_organism: Organism, right_organism: Organism) f64 {
    var dominant_allele_count: f64 = 0.0;

    for (left_organism) |left_allele| {
        for (right_organism) |right_allele| {
            if (left_allele == .dominant or right_allele == .dominant) {
                dominant_allele_count += 1;
                continue;
            }
        }
    }

    return dominant_allele_count / 4.0;
}
