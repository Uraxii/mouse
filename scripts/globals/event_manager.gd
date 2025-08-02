# scripts/globals/event_manager.gd
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
        _:
            signals.message.emit("You don't know how to %s" % [cmd])

func drop(item_name: String) -> void:
    var item = player.remove_item_by_name(item_name)
    
    if not item:
        signals.message.emit("Could not drop %s." % item_name)
        return
    
    player.current_room.drop_item(item)
    signals.message.emit("You put the %s down." % item.get_display_name())

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
    [b]Help[/b]
    \tShow this menu[/left]"""
    
    signals.message.emit(help_message)

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
        # Put it back if we couldn't add it
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

func _on_message(msg: String) -> void:
    if history.size() >= max_history_size:
        history.pop_back()
    
    history.append(msg)

func _on_update_room(room: RoomNode) -> void:
    if Game.local_player.current_room == room:
        _on_message("Something happened in your room.")
#endregion
