class_name SignalBus

# Game flow signals
@warning_ignore("unused_signal")
signal start_game()

@warning_ignore("unused_signal")
signal pass_time(amount: int)

# UI and messaging signals
@warning_ignore("unused_signal")
signal message(msg: String)

# Command system signals
@warning_ignore("unused_signal")
signal command(cmd: Command)

# Player movement signals
@warning_ignore("unused_signal")
signal player_moved(player: Player, from_room: RoomNode, to_room: RoomNode)
@warning_ignore("unused_signal")
signal player_entered_room(player: Player, room: RoomNode)
@warning_ignore("unused_signal")
signal player_exited_room(player: Player, room: RoomNode)
@warning_ignore("unused_signal")
signal player_exited_map(player: Player, map: MapNode)

# Item interaction signals
@warning_ignore("unused_signal")
signal item_picked_up(player: Player, item: ItemNode)
@warning_ignore("unused_signal")
signal item_dropped(player: Player, item: ItemNode, room: RoomNode)
@warning_ignore("unused_signal")
signal item_used(player: Player, item: ItemNode, target: Node)

# Door interaction signals
@warning_ignore("unused_signal")
signal door_unlocked(door: DoorNode, key_used: ItemNode, player: Player)
@warning_ignore("unused_signal")
signal door_used(door: DoorNode, player: Player)

# Map management signals
@warning_ignore("unused_signal")
signal map_loaded(map: MapNode)
@warning_ignore("unused_signal")
signal map_unloaded(map: MapNode)

# Objective system signals
@warning_ignore("unused_signal")
signal objective_progress(action: String, target: String)
@warning_ignore("unused_signal")
signal objective_started(objective: Objective)
@warning_ignore("unused_signal")
signal objective_completed(objective: Objective)
@warning_ignore("unused_signal")
signal task_completed(task: Task)

# Room state signals
@warning_ignore("unused_signal")
signal room_searched(room: RoomNode, player: Player)
@warning_ignore("unused_signal")
signal room_inspected(room: RoomNode, player: Player)

# Inventory signals
@warning_ignore("unused_signal")
signal inventory_changed(player: Player)
