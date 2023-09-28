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

    var result: []const u8 = undefined;

    // NOTE: such galaxy brain solution, such wow
    // how to even approach this problem seriosuly?
    // is this a case for shared libraries?
    // this always loops through all modules...
    // I can't find out how to make this indexable
    // at runtime with elegant code.
    inline for (@typeInfo(problems).Struct.decls) |decl| {
        if (number == try std.fmt.parseInt(usize, decl.name[8..11], 10)) {
            const module = @field(problems, decl.name);
            result = try module.solution(child_allocator, input);
        }
    }

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

// NOTE: this cannot be indexed into at runtime
// fn getModules() []type {
//     const decls = @typeInfo(problems).Struct.decls;

//     var modules: [decls.len]type = undefined;

//     inline for (0..decls.len) |index| {
//         modules[index] = @field(problems, decls[index].name);
//     }

//     return &modules;
// }
