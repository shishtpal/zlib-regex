const std = @import("std");
const print = std.debug.print;
const Regex = @import("regex").Regex;

pub fn main() !void {
    var re1 = try Regex.compile(std.heap.page_allocator, "ab");
    print("{}\n", .{try re1.match("ab")}); // true, ok
    print("{}\n", .{try re1.match("abc")}); // Expected: false, Actual: true
    var re2 = try Regex.compile(std.heap.page_allocator, "^ab$");
    print("{}\n", .{try re2.match("ab")}); // true, ok
    print("{}\n", .{try re2.match("abc")}); // Expected: false, Actual: true
}
