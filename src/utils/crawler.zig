const std = @import("std");

pub fn getFiles(allocator: std.mem.Allocator, dir: *const std.fs.Dir) ![]const []const u8 {
    var files = std.ArrayList([]const u8).init(allocator);
    defer files.deinit();

    var iterable_dir = try dir.openDir(".", .{});
    defer iterable_dir.close();

    var iterator = iterable_dir.iterate();

    while (try iterator.next()) |item| {
        switch (item.kind) {
            .file => {
                const file_name = try allocator.dupe(u8, item.name);
                try files.append(file_name);
            },
            else => {},
        }
    }

    return files.toOwnedSlice();
}

pub fn getSubDirectories(allocator: std.mem.Allocator, dir: *const std.fs.Dir) ![]const []const u8 {
    var directories = std.ArrayList([]const u8).init(allocator);
    defer directories.deinit();

    var iterable_dir = try dir.openDir(".", .{});
    defer iterable_dir.close();

    var iterator = iterable_dir.iterate();

    while (try iterator.next()) |item| {
        switch (item.kind) {
            .directory => {
                const directory_name = try allocator.dupe(u8, item.name);
                try directories.append(directory_name);
            },
            else => {},
        }
    }

    return try directories.toOwnedSlice();
}
