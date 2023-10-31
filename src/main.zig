const std = @import("std");
const http = std.http;
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator;
const Uri = std.Uri;
const math = std.math;
const json = std.json;

pub fn main() !void {
    std.debug.print("I wish the wisdom...\n", .{});

    var gpa = GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const uri = Uri.parse("https://feed.evangelizo.org/MG/days") catch unreachable;

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

    const Link = struct { rel: []const u8, uri: []const u8 };

    const Book = struct { code: []const u8, short_title: []const u8, full_title: []const u8 };

    const Readings = struct { id: []const u8, reading_code: []const u8, before_reading: ?[]const u8, chorus: ?[]const u8, type: []const u8, audio_url: ?[]const u8, reference_displayed: []const u8, text: []const u8, href: ?[]const u8, source: ?[]const u8, book_type: []const u8, title: []const u8, book: Book };

    const ImageLinks = struct { large: ?[]const u8, ico: ?[]const u8 };

    const Liturgy = struct { id: []const u8, title: []const u8, description: ?[]const u8, source: ?[]const u8, href: []const u8, image_links: ImageLinks };

    const Data = struct { date: []const u8, date_displayed: []const u8, liturgic_title: []const u8, has_liturgic_description: bool, links: []Link, readings: []Readings, liturgy: Liturgy, special_liturgy: ?[]const u8, commentary: ?[]const u8, saints: [][]const u8 };

    const ResponseBodyStruct = struct { data: Data, href: []const u8 };

    const response_data = try json.parseFromSlice(ResponseBodyStruct, allocator, response_body, .{});
    defer response_data.deinit();

    const readings_len = response_data.value.data.readings.len;
    const gospel = response_data.value.data.readings[readings_len - 1];

    std.debug.print("{s}\n", .{gospel.text});
}
