const std = @import("std");
const sdl = @import("sdl2");

const Engine = @import("engine.zig");


const Self = @This();

prev_state: Engine.sdl.KeyboardState,
curr_state: Engine.sdl.KeyboardState,

pub fn is_pressed(self: *Self, scancode: sdl.Scancode) bool {
    return self.curr_state.isPressed(scancode);
}

pub fn is_just_pressed(self: *Self, scancode: sdl.Scancode) bool {
    return self.curr_state.isPressed(scancode) and !self.prev_state.isPressed(scancode);
}

pub fn is_just_released(self: *Self, scancode: sdl.Scancode) bool {
    return !self.curr_state.isPressed(scancode) and self.prev_state.isPressed(scancode);
}

pub fn get_key_modifier_state(self: *Self) sdl.KeyModifierSet {
    _ = self;
    return Engine.sdl.getKeyboardModifierState();
}

pub fn update(self: *Self) void {
    self.prev_state = self.curr_state;
    self.curr_state = Engine.sdl.getKeyboardState();
}

pub fn init() Self {
    const state = Engine.sdl.getKeyboardState();
    return Self {
        .prev_state = state,
        .curr_state = state,
    };
}