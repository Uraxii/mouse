class_name SignalBus

@warning_ignore("unused_signal")
signal start_game()

@warning_ignore("unused_signal")
signal message(msg: String)

@warning_ignore("unused_signal")
signal command(cmd: Command)
@warning_ignore("unused_signal")
signal move_player(room: Room)

@warning_ignore("unused_signal")
signal objective_progress(action: String, target: String)

@warning_ignore("unused_signal")
signal update_room(room: Room)
