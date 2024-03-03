const std = @import("std");
const sdl = @import("sdl2");

const Engine = @import("engine.zig");


const Self = @This();

const KeyboardBuffer = [Engine.sdl.c.SDL_NUM_SCANCODES]u8;
const KeyboardBuffers = std.ArrayList(KeyboardBuffer);



const KEY_BUFFER_MAX: usize = 2;

prev_state: Engine.sdl.KeyboardState,
curr_state: Engine.sdl.KeyboardState,

key_buffers: KeyboardBuffers,

//----------------------------------------------------------------------------------------------
pub fn is_pressed(self: *Self, scancode: sdl.Scancode) bool {
    return self.get_current_state_key(scancode);
}

pub fn is_just_pressed(self: *Self, scancode: sdl.Scancode) bool {
    return self.get_current_state_key(scancode) and !self.get_previous_state_key(scancode);
}

pub fn is_just_released(self: *Self, scancode: sdl.Scancode) bool {
    return !self.get_current_state_key(scancode) and self.get_previous_state_key(scancode);
}
//----------------------------------------------------------------------------------------------

pub fn get_key_modifier_state(self: *Self) sdl.KeyModifierSet {
    _ = self;
    return Engine.sdl.getKeyboardModifierState();
}

//----------------------------------------------------------------------------------------------
pub fn get_current_state_key(self: *Self, scancode: sdl.Scancode) bool {
    return self.get_current_state()[@intFromEnum(scancode)] != 0;
}

pub fn get_previous_state_key(self: *Self, scancode: sdl.Scancode) bool {
    return self.get_previous_state()[@intFromEnum(scancode)] != 0;
}
//----------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------
pub fn get_current_state(self: *Self) []u8 {
    return &self.key_buffers.items[0];
}

pub fn get_previous_state(self: *Self) []u8 {
    return &self.key_buffers.items[1];
}
//----------------------------------------------------------------------------------------------

pub fn process_event(self: *Self, event: Engine.sdl.Event) void {
    switch (event) {
        .key_down => {
            const curr = self.get_current_state();
            const sc: usize = @intFromEnum(event.key_down.scancode);
            curr[sc] = 1;
        },
        .key_up => {
            const curr = self.get_current_state();
            const sc: usize = @intFromEnum(event.key_up.scancode);
            curr[sc] = 0;
        },
        else => {}
    }
}

pub fn update(self: *Self) void {
    const prev = self.get_previous_state();
    const curr = self.get_current_state();
    @memcpy(prev, curr);
}

pub fn init(allocator: std.mem.Allocator) !Self {
    const state = Engine.sdl.getKeyboardState();

    var key_buffers = try KeyboardBuffers.initCapacity(allocator, 2);
    try key_buffers.appendNTimes(std.mem.zeroes(KeyboardBuffer), 2);

    return Self {
        .prev_state = state,
        .curr_state = state,
        .key_buffers = key_buffers,
    };
}

pub fn deinit(self: *Self) void {
    self.key_buffers.deinit();
}