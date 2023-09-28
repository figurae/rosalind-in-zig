const std = @import("std");

const string = @import("utils/string.zig");

const globals = @import("globals.zig");

pub fn buildProblems(cwd: *const std.fs.Dir, child_allocator: std.mem.Allocator, problems: []const []const u8, target_file: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(child_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const keywords = "pub const";
    const import_placeholder = "@import(\"{s}\")";

    var problems_file = std.ArrayList(u8).init(allocator);

    for (problems, 1..) |problem_name, problem_idx| {
        // NOTE: this should be possible without all this try try try...
        const problem_idx_string = try std.fmt.allocPrint(allocator, "{d}", .{problem_idx});
        const padded_problem_idx = try string.padLeft(allocator, problem_idx_string, 3, '0');
        const problem_var_name = try std.fmt.allocPrint(allocator, "{s}{s}", .{ globals.problem_var_prefix, padded_problem_idx });

        const solution_path = try std.mem.join(allocator, "/", &[_][]const u8{ globals.problems_dir_name, problem_name, globals.solution_file_name });
        const import_call = try std.fmt.allocPrint(allocator, import_placeholder, .{solution_path});

        const solution_line = try std.fmt.allocPrint(allocator, "{s} {s} = {s};\n", .{ keywords, problem_var_name, import_call });

        try problems_file.appendSlice(solution_line);
    }

    var file = try cwd.createFile(target_file, .{});
    defer file.close();

    try file.writeAll(problems_file.items);
}
