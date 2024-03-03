const std = @import("std");


var stringBuf: [32]u8 = undefined;
const DynObjValue = union(enum) {
    const Self = @This();

    Int: i64,
    Float: f64,
    Array: std.ArrayListUnmanaged(DynObjValue),
    Function: fn(*DynObject, DynObjValue) DynObjValue,
    Object: ?*DynObject,


    pub fn get_type(self: Self) ![]const u8 {
        switch (self) {
            .Int => return try std.fmt.bufPrint(&stringBuf, "Int", .{}),
            .Float => return try std.fmt.bufPrint(&stringBuf, "Float", .{}),
            .Array => return try std.fmt.bufPrint(&stringBuf, "Array", .{}),
            .Function => return try std.fmt.bufPrint(&stringBuf, "Function", .{}),
            .Object => return try std.fmt.bufPrint(&stringBuf, "Object", .{}),
        }
    }


    pub fn to_string(self: Self) ![]const u8 {
        switch (self) {
            .Int => return try std.fmt.bufPrint(&stringBuf, "Int: {}", .{self.Int}),
            .Float => return try std.fmt.bufPrint(&stringBuf, "Float: {}", .{self.Float}),
            .Array => return try std.fmt.bufPrint(&stringBuf, "Array: {}", .{@intFromPtr(self.Array.items.ptr)}),
            .Function => return try std.fmt.bufPrint(&stringBuf, "Function: {}", .{@intFromPtr(self.Function)}),
            .Object => return try std.fmt.bufPrint(&stringBuf, "Object: {}", .{@intFromPtr(self.Object)}),
        }
    }
};

const DynObject = struct {
    const Self = @This();

    type_name: []const u8,
    fields: std.StringHashMapUnmanaged(DynObjValue),

    pub fn new(allocator: std.mem.Allocator, name: []const u8) Self {
        return Self {
            .name = name,
            .fields = std.StringHashMapUnmanaged(DynObjValue).init(allocator),
        };
    }

    pub fn set_value(self: *Self, allocator: std.mem.Allocator, field: []const u8, value: DynObjValue) !void {
        try self.fields.put(allocator, field, value);
    }

    pub fn get_value(self: *const Self, field: []const u8) !DynObjValue {
        return self.fields.get(field);
    }

};