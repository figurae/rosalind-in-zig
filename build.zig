const std = @import("std");

const globals = @import("src/globals.zig");

const getInputsByProblems = @import("src/getInputsByProblems.zig").getInputsByProblems;
const buildProblems = @import("src/buildProblems.zig").buildProblems;

pub fn build(b: *std.Build) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const problems_dir_path = try std.fs.path.join(allocator, &[_][]const u8{ globals.src_dir_name, globals.problems_dir_name });
    defer allocator.free(problems_dir_path);

    const cwd = std.fs.cwd();

    var inputsByProblems = try getInputsByProblems(&cwd, allocator, problems_dir_path);
    defer {
        var iterator = inputsByProblems.iterator();
        while (iterator.next()) |item| {
            allocator.free(item.key_ptr.*);
            allocator.free(item.value_ptr.*);
        }
        inputsByProblems.deinit();
    }

    var problem_iterator = inputsByProblems.iterator();

    while (problem_iterator.next()) |entry| {
        const problem_name = entry.key_ptr.*;
        const input_file = entry.value_ptr.*;

        const src_problem_path = try std.fs.path.join(allocator, &[_][]const u8{ globals.src_dir_name, globals.problems_dir_name, problem_name });
        defer allocator.free(src_problem_path);

        const dst_problem_path = try std.fs.path.join(allocator, &[_][]const u8{ globals.bin_dir_name, globals.problems_dir_name, problem_name });
        defer allocator.free(dst_problem_path);

        const src_input_path = try std.fs.path.join(allocator, &[_][]const u8{ src_problem_path, input_file });
        defer allocator.free(src_input_path);

        const dst_input_path = try std.fs.path.join(allocator, &[_][]const u8{ dst_problem_path, input_file });
        defer allocator.free(dst_input_path);

        b.installFile(src_input_path, dst_input_path);

        const sample_file = globals.sample_file_basename ++ "." ++ globals.input_extension;

        // TODO: check if exists
        const src_sample_path = try std.fs.path.join(allocator, &[_][]const u8{ src_problem_path, sample_file });
        defer allocator.free(src_sample_path);

        const dst_sample_path = try std.fs.path.join(allocator, &[_][]const u8{ dst_problem_path, sample_file });
        defer allocator.free(dst_sample_path);

        b.installFile(src_sample_path, dst_sample_path);
    }

    const problems_file_path = try std.fs.path.join(allocator, &[_][]const u8{ globals.src_dir_name, globals.problems_file_name });
    defer allocator.free(problems_file_path);

    try buildProblems(&cwd, allocator, inputsByProblems.keys(), problems_file_path);

    const exe = b.addExecutable(.{
        .name = "Rosalind",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const string = b.addModule("string", .{ .source_file = .{ .path = "src/utils/string.zig" } });
    const mem = b.addModule("mem", .{ .source_file = .{ .path = "src/utils/mem.zig" } });
    const data = b.addModule("data", .{ .source_file = .{ .path = "src/genetics/data.zig" }, .dependencies = &.{.{ .name = "string", .module = string }} });
    const encoding = b.addModule("encoding", .{ .source_file = .{ .path = "src/genetics/encoding.zig" } });
    exe.addModule("string", string);
    exe.addModule("mem", mem);
    exe.addModule("data", data);
    exe.addModule("encoding", encoding);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    // NOTE: this doesn't seem like it should be necessary...
    run_cmd.cwd = "zig-out/bin/";
    // NOTE: as far as I understand, this is supposed to change cwd to bin by itself; why does it not?
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
