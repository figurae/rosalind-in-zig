const std = @import("std");
const string = @import("string");

const problems = @import("problems.zig");
const globals = @import("globals.zig");

// NOTE: this got a bit long
const getInputsByProblems = @import("getInputsByProblems.zig").getInputsByProblems;

const InputType = enum { sample, final };

pub fn runSolution(child_allocator: std.mem.Allocator, number: usize, input_type: InputType) ![]const u8 {
    var arena = std.heap.ArenaAllocator.init(child_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const input = try getInput(allocator, number, input_type);

    const problems_total = @typeInfo(problems).Struct.decls.len;
    var problem_functions = [_]*const fn (allocator: std.mem.Allocator, input: []const u8) anyerror![]const u8{undefined} ** problems_total;

    // NOTE: is the order here guaranteed?
    inline for (@typeInfo(problems).Struct.decls, 0..) |decl, index| {
        problem_functions[index] = @field(problems, decl.name).solution;
    }

    const result = try problem_functions[number - 1](child_allocator, input);

    return result;
}

fn getInput(allocator: std.mem.Allocator, number: usize, input_type: InputType) ![]const u8 {
    const cwd = std.fs.cwd();

    const inputsByProblems = try getInputsByProblems(&cwd, allocator, globals.problems_dir_name);
    const input_file_names = inputsByProblems.values();
    const problem_names = inputsByProblems.keys();

    const problem_name = problem_names[number - 1];
    const input_file_name = switch (input_type) {
        .final => input_file_names[number - 1],
        .sample => globals.sample_file_basename ++ "." ++ globals.input_extension,
    };

    const input_path = try std.fs.path.join(allocator, &[_][]const u8{ globals.problems_dir_name, problem_name, input_file_name });
    const input_file = try cwd.openFile(input_path, .{});
    const input = input_file.reader().readAllAlloc(allocator, std.math.maxInt(usize));

    return input;
}
