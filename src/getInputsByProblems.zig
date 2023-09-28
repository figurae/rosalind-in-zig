const std = @import("std");

const crawler = @import("utils/crawler.zig");
const sorter = @import("utils/sorter.zig");
const string = @import("utils/buildString.zig");

const globals = @import("globals.zig");

pub fn getInputsByProblems(cwd: *const std.fs.Dir, allocator: std.mem.Allocator, problems_path: []const u8) !std.StringArrayHashMap([]const u8) {
    var problems_directory = try cwd.openDir(problems_path, .{});
    defer problems_directory.close();

    const problem_directories = try crawler.getSubDirectories(allocator, &problems_directory);
    defer {
        for (problem_directories) |dir| {
            allocator.free(dir);
        }
        allocator.free(problem_directories);
    }

    var inputsByProblems = std.StringArrayHashMap([]const u8).init(allocator);

    const sorted_problem_directories = try sorter.sortStrings(allocator, problem_directories);
    defer allocator.free(sorted_problem_directories);

    for (sorted_problem_directories) |dir| {
        const problem_directory_path = try std.fs.path.join(allocator, &[_][]const u8{ problems_path, dir });
        defer allocator.free(problem_directory_path);

        var problem_directory = try cwd.openDir(problem_directory_path, .{});
        defer problem_directory.close();

        const files = try crawler.getFiles(allocator, &problem_directory);
        defer {
            for (files) |file| {
                allocator.free(file);
            }
            allocator.free(files);
        }

        for (files) |file| {
            const split_file = try string.split(allocator, file, '.');
            defer {
                for (split_file) |item| {
                    allocator.free(item);
                }
                allocator.free(split_file);
            }

            // TODO: handle the case without final input!
            if (split_file.len > 1) {
                if (try string.isEqual(split_file[1], globals.input_extension)) {
                    if (!(try string.isEqual(split_file[0], globals.sample_file_basename))) {
                        const dir_dupe = try allocator.dupe(u8, dir);
                        const file_dupe = try allocator.dupe(u8, file);
                        try inputsByProblems.put(dir_dupe, file_dupe);
                    }
                }
            }
        }
    }

    return inputsByProblems;
}
