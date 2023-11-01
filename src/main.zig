const std = @import("std");
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator;
const Allocator = std.mem.Allocator;
const Uri = std.Uri;
const http = std.http;
const math = std.math;
const json = std.json;
const process = std.process;
const print = std.debug.print;
const eql = std.mem.eql;
const trim = std.mem.trim;
const ResponseData = @import("./struct/response.zig").ResponseData;

pub fn main() !void {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try process.argsAlloc(allocator);
    defer process.argsFree(allocator, args);

    const options = args[1..];

    const is_empty_options: bool = options.len == 0;
    if (is_empty_options) {
        try sapientia_fn(allocator);
        return;
    }

    const is_help_first_option: bool = eql(u8, options[0], "-h") or eql(u8, options[0], "--help");
    if (is_help_first_option) {
        help_displayer();
        return;
    }
}

fn help_displayer() void {
    print("\n", .{});
    print(">>> Name: Sapientia CLI\n", .{});
    print(">>> Description: Sapientia CLI is a command-line tool which display daily gospel.\n", .{});
    print("Sapientia is written in ziglang (https://ziglang.org)\n", .{});
    print("\n", .{});
    print(">>> Supported Options:\n", .{});
    print("- `-h` or `--help`: Displays help on how to use the CLI.\n", .{});
    print("- `-d [date]` or `--date [date]`: Displays gospel for specific date, by default today.\n", .{});
    print("- `-l [MG|AN|FR]` or `--lang [MG|AN|FR]`: Displays gospel for specific date, by default MG\n.", .{});
    print("\n", .{});
}

fn sapientia_fn(allocator: Allocator, lang: []u8, date: []u8) !void {
    _ = date;
    _ = lang;
    const uri = Uri.parse("https://feed.evangelizo.org/FR/days/2023-11-01/readings") catch unreachable;

    var client = http.Client{ .allocator = allocator };
    defer client.deinit();

    var headers = http.Headers{ .allocator = allocator };
    defer headers.deinit();
    try headers.append("accept", "application/json");

    var request = try client.request(.GET, uri, headers, .{});
    defer request.deinit();

    try request.start();
    try request.wait();

    var response_body = try request.reader().readAllAlloc(allocator, math.maxInt(usize));
    defer allocator.free(response_body);

    const response_data = try json.parseFromSlice(ResponseData, allocator, response_body, .{});
    defer response_data.deinit();

    const readings_len = response_data.value.data.len;
    const gospel = response_data.value.data[readings_len - 1];

    print("\n", .{});
    print(">>> {s}\n\n", .{gospel.book.full_title});
    print("{s}\n", .{gospel.text});
    print("\n", .{});
}
