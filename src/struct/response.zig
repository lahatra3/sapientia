const Book = struct { code: []const u8, short_title: []const u8, full_title: []const u8 };
const Data = struct { id: []const u8, reading_code: []const u8, before_reading: ?[]const u8, chorus: ?[]const u8, type: []const u8, audio_url: ?[]const u8, reference_displayed: []const u8, text: []const u8, href: ?[]const u8, source: ?[]const u8, book_type: []const u8, title: []const u8, book: Book };
pub const ResponseData = struct { data: []Data, href: []const u8 };
