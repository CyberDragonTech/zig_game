const Engine = @import("engine.zig");



pub fn main() !void {
    Engine.Logger.init();
    var game_state = Engine.GameState.init() catch {
        Engine.Logger.log_error("Core", "Error occured during program initialization", .{});
        return;
    };
    Engine.Logger.log_info("Core", "GameState initialized", .{});
    game_state.run() catch {
        Engine.Logger.log_error("Core", "Error occured during program execution", .{});
    };
    game_state.deinit();
    Engine.Logger.deinit();
}