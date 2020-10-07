const std = @import("std");
const trait = std.meta.trait;
const testing = std.testing;

pub fn Copy(comptime T: comptime type) bool {
    switch (@typeInfo(T)) {
        .Bool => return true,

        .Int => return true,

        .ComptimeInt => return true,

        .Float => return true,

        .ComptimeFloat => return true,

        .Void => return true,

        .Struct => |s| {
            inline for (s.fields) |field| {
                if (!Copy(field.field_type)) {
                    return false;
                }

                return true;
            }
        },

        .Union => |u| {
            inline for (u.fields) |field| {
                if (!Copy(field.field_type)) {
                    return false;
                }

                return true;
            }
        },

        .Enum => return true,

        .Optional => |o| {
            return Copy(o.child);
        },

        .Array => |a| {
            return Copy(a.child);
        },

        .Vector => |v| {
            return Copy(v.child);
        },

        .ErrorUnion => |u| {
            return Copy(u.payload);
        },

        .Pointer => |p| {
            return Copy(p.child);
        },

        // undefined is assumed not copy
        // EnumLiteral I'm not sure about
        else => return false,
    }
}

test "copy trait" {
    testing.expect(Copy(u8));
    testing.expect(Copy(f32));
    testing.expect(Copy(i64));
    testing.expect(Copy(struct { x: i32, y: i32 }));
    testing.expect(Copy(union(enum) { x: i32, y: i32 }));
    testing.expect(Copy(enum { x, y }));
    testing.expect(Copy(bool));
    testing.expect(Copy([10]u8));
    testing.expect(Copy([]u8));
    testing.expect(Copy(*u8));
    testing.expect(Copy(?u8));
}
