class_name EventManager

var max_history_size := 100
var history: Array[String] = []

var signals: SignalBus
var player: Player:
    get: return Game.local_player

#region Public functions
func setup() -> void:
    signals = Global.signals
    _connect_signals()

func get_tail(entries := max_history_size) -> Array[String]:
    return history.slice(
        history.size() - entries,
        history.size()
    )
#endregion

#region Command Functions
func _on_command(cmd: Command) -> void:
    print_debug(str(cmd))
    signals.message.emit("[color=cyan][i]CMD: %s[/i][/color]" % [str(cmd)])
    signals.message.emit("─ ".repeat(20))
    
    match cmd.action.to_lower():
        "drop":
            drop(cmd.target)
        "exit":
            exit()
        "inspect":
            inspect(cmd.target)
        "look":
            look(cmd.target)
        "pickup":
            pickup(cmd.target)
        "search":
            search(cmd.target)
        "use":
            use_item(cmd.target)
        "go", "move", "enter":
            go_through(cmd.target)
        "help":
            help()
        "objectives":
            Global.objectives.show_current_objectives()
        _:
            signals.message.emit("You don't know how to %s" % [cmd])
        
    signals.pass_time.emit(1)


func drop(item_name: String) -> void:
    var item = player.remove_item_by_name(item_name)
    
    if not item:
        signals.message.emit("Could not drop %s." % item_name)
        return
    
    player.current_room.drop_item(item)
    signals.message.emit("You put the %s down." % item.get_display_name())
    signals.item_dropped.emit(player, item, player.current_room)


func exit() -> void:
    # Check if player is in a room with an exit door
    if not player.current_room:
        signals.message.emit("You can't exit from here.")
        return
    
    var exit_doors = []
    for door in player.current_room.get_doors():
        if door.has_method("has_tag") and door.has_tag("exit"):
            exit_doors.append(door)
    
    if exit_doors.is_empty():
        signals.message.emit("There's no way to exit from here.")
        return
    
    var exit_door = exit_doors[0]
    go_through(exit_door.get_display_name())


func inspect(target_str: String) -> void:
    if not target_str:
        signals.message.emit("Inspect what?")
        return
    
    match target_str.to_lower():
        "inventory":
            signals.message.emit("Your belongings.")
        "room":
            if player.current_room:
                signals.message.emit(player.current_room.inspect() if player.current_room.has_method("inspect") else player.current_room.look())
        _:
            var target = _find_target(target_str)
            if target and target.has_method("inspect"):
                signals.message.emit(target.inspect())
            else:
                signals.message.emit("There's nothing like that here.")


func look(target_str: String) -> void:
    if not target_str:
        # Look around the room
        if player.current_room:
            signals.message.emit(player.current_room.look())
        return
    
    match target_str.to_lower():
        "inventory":
            signals.message.emit(player.get_inventory_display())
        "room":
            if player.current_room:
                signals.message.emit(player.current_room.look())
        _:
            var target = _find_target(target_str)
            if target and target.has_method("inspect"):
                signals.message.emit(target.inspect())
            else:
                signals.message.emit("There's nothing like that here.")


func pickup(target_str: String) -> void:
    if not target_str:
        signals.message.emit("Pick up what?")
        return
    
    if not player.can_add_item():
        signals.message.emit("You're carrying too much to pick up anything else.")
        return
    
    var item = player.current_room.pickup_item(target_str)
    
    if not item:
        signals.message.emit("Hrm... No %s here" % [target_str])
        return
    
    if player.add_item(item):
        signals.message.emit("The [color=yellow]%s[/color] was placed into your bag." % item.get_display_name())
    else:
        player.current_room.drop_item(item)
        signals.message.emit("You couldn't pick up the %s." % item.get_display_name())


func search(target_str: String = "") -> void:
    if not target_str or target_str.to_lower() == "room":
        if player.current_room:
            signals.message.emit(player.current_room.search())
        return
    
    var target = _find_target(target_str)
    if target and target.has_method("search"):
        signals.message.emit(target.search())
        _emit_objective_progress("search", target_str)
    else:
        signals.message.emit("Cannot search that!")


func use_item(command_str: String) -> void:
    # Parse "item on target" or just "item"
    var parts = command_str.split(" on ", false, 1)
    if parts.size() < 2:
        signals.message.emit("Use what on what? Try: use [item] on [target]")
        return
    
    var item_name = parts[0].strip_edges()
    var target_name = parts[1].strip_edges()
    
    # Find the item in player's inventory
    var item = player.find_item_by_name(item_name)
    if not item:
        signals.message.emit("You don't have a %s." % item_name)
        return
    
    # Find the target
    var target = _find_target(target_name)
    if not target:
        signals.message.emit("There's no %s here." % target_name)
        return
    
    # Try to use the item on the target
    var result = item.use_on(target, player)
    signals.message.emit(result)


func go_through(target_str: String) -> void:
    if not target_str:
        signals.message.emit("Go through what?")
        return
    
    var door = player.current_room.get_door_by_name(target_str)
    if not door:
        signals.message.emit("There's no %s here." % target_str)
        return
    
    var result = door.use_door(player)
    signals.message.emit(result)
    
    if door.can_pass_through():
        Game.move_player_through_door(player, door)
        

func help() -> void:
    var help_message = """[center][b]HELP[/b][/center]
    [left][u]Actions[/u]
    [b]Drop [item][/b]
    \tDrop an item from your inventory
    [b]Inspect [target][/b]
    \tExamine something closely
    [b]Look [target][/b]
    \tLook at something or around the room
    [b]Pickup [item][/b]
    \tPick up an item
    [b]Search[/b]
    \tSearch the current room for items
    [b]Use [item] on [target][/b]
    \tUse an item on something
    [b]Go [door/direction][/b]
    \tMove through a door or passage
    [b]Objectives[/b]
    \tShow current objectives
    [b]Help[/b]
    \tShow this menu[/left]"""
    
    signals.message.emit(help_message)


func _find_target(target_name: String) -> Node:
    # First check player inventory
    var item = player.find_item_by_name(target_name)
    if item:
        return item
    
    # Then check current room
    if player.current_room:
        return player.current_room.find_entity_by_name(target_name)
    
    return null
#endregion

#region Private Functions
func _connect_signals() -> void:
    signals.command.connect(_on_command)
    signals.message.connect(_on_message)
    
    # Connect all signal bus events for objective tracking
    signals.door_unlocked.connect(_on_door_unlocked)
    signals.door_used.connect(_on_door_used)
    signals.item_picked_up.connect(_on_item_picked_up)
    signals.item_dropped.connect(_on_item_dropped)
    signals.item_used.connect(_on_item_used)
    signals.player_moved.connect(_on_player_moved)
    signals.player_entered_room.connect(_on_player_entered_room)
    signals.player_exited_room.connect(_on_player_exited_room)
    signals.room_searched.connect(_on_room_searched)
    signals.room_inspected.connect(_on_room_inspected)

func _on_message(msg: String) -> void:
    if history.size() >= max_history_size:
        history.pop_back()
    
    history.append(msg)

func _on_door_unlocked(door: DoorNode, key_used: ItemNode, player: Player) -> void:
    # Emit both unlock and use signals for task flexibility
    _emit_objective_progress("unlock", door.get_display_name(), key_used.get_display_name())
    _emit_objective_progress("use", key_used.get_display_name(), door.get_display_name())

func _on_door_used(door: DoorNode, player: Player) -> void:
    _emit_objective_progress("use", door.get_display_name())

func _on_item_picked_up(player: Player, item: ItemNode) -> void:
    _emit_objective_progress("pickup", item.get_display_name())

func _on_item_dropped(player: Player, item: ItemNode, room: RoomNode) -> void:
    _emit_objective_progress("drop", item.get_display_name())

func _on_item_used(player: Player, item: ItemNode, target: Node) -> void:
    var target_name = target.get_display_name() if target.has_method("get_display_name") else str(target)
    _emit_objective_progress("use", item.get_display_name(), target_name)

func _on_player_moved(player: Player, from_room: RoomNode, to_room: RoomNode) -> void:
    _emit_objective_progress("move", to_room.get_display_name())

func _on_player_entered_room(player: Player, room: RoomNode) -> void:
    _emit_objective_progress("enter", room.get_display_name())

func _on_player_exited_room(player: Player, room: RoomNode) -> void:
    _emit_objective_progress("exit", room.get_display_name())

func _on_room_searched(room: RoomNode, player: Player) -> void:
    _emit_objective_progress("search", room.get_display_name())

func _on_room_inspected(room: RoomNode, player: Player) -> void:
    _emit_objective_progress("inspect", room.get_display_name())

func _emit_objective_progress(action: String, target: String, secondary_target: String = "") -> void:
    for objective in Global.objectives.active_objectives:
        var completion_msg = objective.try_progress(action, target, secondary_target)
        
        if not completion_msg.is_empty():
            signals.message.emit(completion_msg)
            
            var hint = objective.get_current_hint()
            if not hint.is_empty():
                signals.message.emit("[color=yellow][i]%s[/i][/color]" % hint)
            
            if objective.is_objective_complete():
                Global.objectives.complete_objective(objective)

func _on_update_room(room: RoomNode) -> void:
    if Game.local_player.current_room == room:
        _on_message("Something happened in your room.")
#endregion
