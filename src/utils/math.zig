const std = @import("std");

pub fn smallestUsize(input: []usize) usize {
    var smallest: usize = std.math.maxInt(usize);

    for (input) |n| {
        if (n < smallest) smallest = n;
    }

    return smallest;
}
