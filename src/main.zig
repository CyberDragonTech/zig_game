const Engine = @import("engine.zig");
const std = @import("std");


pub fn main() !void {
    var game_state = Engine.GameState.init() catch {
        Engine.IO.print_err("Error occured during program initialization", .{});
        _ = Engine.IO.readln();
        return;
    };
    game_state.run() catch {
        Engine.IO.print_err("Error occured during program execution", .{});
    };
    game_state.deinit();
}