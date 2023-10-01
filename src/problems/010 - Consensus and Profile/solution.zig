const std = @import("std");
const data = @import("data");
const mem = @import("mem");

pub fn solution(child_allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var arena = std.heap.ArenaAllocator.init(child_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const strings = try data.getStringsFromFasta(allocator, input);
    const profile_matrix = try getDnaProfileMatrix(allocator, strings);
    const consensus_string = try getConsensusString(child_allocator, profile_matrix);

    return consensus_string;
}

// NOTE: maybe struct isn't the way to go here?
const DnaProfileMatrix = struct {
    adenine: []usize,
    cytosine: []usize,
    guanine: []usize,
    thymine: []usize,
};

// NOTE: this should be aware of the fact that there can be multiple consensus strings
fn getConsensusString(allocator: std.mem.Allocator, profile_matrix: DnaProfileMatrix) ![]const u8 {
    const length = profile_matrix.adenine.len;
    var consensus_string = std.ArrayList(u8).init(allocator);

    for (0..length) |i| {
        // NOTE: this could use a better data structure
        const max: usize = @max(@max(@max(profile_matrix.adenine[i], profile_matrix.cytosine[i]), profile_matrix.guanine[i]), profile_matrix.thymine[i]);
        const consensus_nucleobase: u8 = if (profile_matrix.adenine[i] == max) 'A' else if (profile_matrix.cytosine[i] == max) 'C' else if (profile_matrix.guanine[i] == max) 'G' else 'T';
        try consensus_string.append(consensus_nucleobase);
    }

    return consensus_string.toOwnedSlice();
}

fn getDnaProfileMatrix(allocator: std.mem.Allocator, strings: []const data.String) !DnaProfileMatrix {
    std.debug.assert(strings.len > 1);

    const length = strings[0].string.len;
    std.debug.assert(length > 0);

    for (strings[1..]) |s| {
        std.debug.assert(s.string.len == length);
    }

    var nucleobases = [_][]usize{undefined} ** 4;
    for (&nucleobases) |*n| {
        n.* = try mem.allocateAndSet(allocator, usize, length, 0);
    }

    for (0..length) |i| {
        for (strings) |s| {
            switch (s.string[i]) {
                'A' => nucleobases[0][i] += 1,
                'C' => nucleobases[1][i] += 1,
                'G' => nucleobases[2][i] += 1,
                'T' => nucleobases[3][i] += 1,
                else => unreachable,
            }
        }
    }

    return .{
        .adenine = nucleobases[0],
        .cytosine = nucleobases[1],
        .guanine = nucleobases[2],
        .thymine = nucleobases[3],
    };
}
