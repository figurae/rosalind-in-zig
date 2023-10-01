const std = @import("std");
const string = @import("string");
const heredity = @import("heredity");

const OrganismType = heredity.OrganismType;

const Pairing = struct {
    left: OrganismType,
    right: OrganismType,
};

pub fn solution(child_allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var arena = std.heap.ArenaAllocator.init(child_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const number_of_offspring: f64 = 2.0;

    const split_input = try string.split(allocator, input, ' ');
    var couples = [_]f64{undefined} ** 6;
    for (&couples, 0..) |*c, i| {
        c.* = try std.fmt.parseFloat(f64, split_input[i]);
    }

    // NOTE: this should be possible to initialize with the same order using a loop
    const pairings: [6]Pairing = .{
        .{ .left = .homozygous_dominant, .right = .homozygous_dominant },
        .{ .left = .homozygous_dominant, .right = .heterozygous },
        .{ .left = .homozygous_dominant, .right = .homozygous_recessive },
        .{ .left = .heterozygous, .right = .heterozygous },
        .{ .left = .heterozygous, .right = .homozygous_recessive },
        .{ .left = .homozygous_recessive, .right = .homozygous_recessive },
    };

    const getOrganism = heredity.organismFromOrganismType;
    var total_dominant_offspring: f64 = 0.0;

    for (pairings, couples) |pairing, number_of_couples| {
        const left_alleles = getOrganism(pairing.left).alleles;
        const right_alleles = getOrganism(pairing.right).alleles;

        const dominant_offspring = heredity.getProbabilityOfDominantAlleleInOffspring(left_alleles, right_alleles) * number_of_offspring * number_of_couples;
        total_dominant_offspring += dominant_offspring;
    }

    return try std.fmt.allocPrint(child_allocator, "{d}", .{total_dominant_offspring});
}
