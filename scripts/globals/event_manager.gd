class_name EventManager

var max_history_size := 100
var history: Array[String] = []

var signals: SignalBus
# TODO: Cache local player value
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
        "help":
            help()
        _:
            signals.message.emit("You don't know how to %s" % [cmd])


func drop(item_name: String) -> void:
    var item = player.inventory.remove_item_by_name(item_name)
    
    if not item:
        signals.message.emit("Could not drop %s." % item_name)
    
    player.current_room.inventory.add_item(item)
    signals.message.emit("You put the %s down." % item.display_name)


func inspect(target_str) -> void:
    var function: Callable
        
    match target_str:
        "inventory":
            function = player.inventory.inspect
        "room":
            function = player.current_room.inspect
        _:
            function = player.current_focus.get_method("inspect")

    if not function:
        signals.message.emit("There's nothing like that here.")
        return
        
    signals.message.emit(function.call())


func look(target_str: String) -> void:
    var function: Callable
        
    match target_str:
        "inventory":
            function = player.inventory.look
        "room":
            function = player.current_room.look
        _:
            function = player.current_focus.get_method("look")

    if not function:
        signals.message.emit("There's nothing like that here.")
        return
        
    signals.message.emit(function.call())


func pickup(target_str: String) -> void:
    var item = player.current_room.pickup(target_str)
    
    if player.inventory.is_full:
        signals.message.emit(
            "You're carrying too much to pick up anything else!")
        return
    
    if not item:
        signals.message.emit("Hrm... No [color=yellow]%s[/color] here." % [target_str])
        return
        
    player.inventory.add_item(item)
    signals.message.emit(
        "The [color=yello]%s[/color] was placed into your bag." % item.display_name)


func search(target_str: String) -> void:
    var target
    
    if not target_str:
        target = player.current_focus
    if target_str.to_lower() == "room":
        target = player.current_room

    if not target or not target.has_method("search"):
        signals.message.emit("Cannot Search that!")
        return
    
    signals.message.emit(target.search())
    

func help() -> void:
    var help_message = """[center][b]HELP[/b][/center]
    [left][u]Available Actions[/u]
    
    [b]Drop [item_name][/b]
    \tRemove an item from your inventory and place it in the current room.
    \tExample: "drop star key"
    
    [b]Inspect [target][/b]
    \tExamine something closely to get detailed information.
    \tTargets: inventory, room, or any item/object
    \tExample: "inspect inventory" or "inspect room"
    
    [b]Look [target][/b]
    \tObserve your surroundings or examine something.
    \tTargets: inventory, room, or any item/object
    \tExample: "look room" or "look inventory"
    
    [b]Pickup [item_name][/b]
    \tTake an item from the current room and add it to your inventory.
    \tExample: "pickup star key"
    
    [b]Search [target][/b]
    \tSearch the room or a specific area for items or clues.
    \tExample: "search" or "search room"
    
    [b]Help[/b]
    \tShow this help menu with all available commands.
    
    [u]Tips:[/u]
    • You can chain commands with semicolons: "look room; search; pickup key"
    • Commands are case-insensitive
    • Use specific item names when picking up or dropping items[/left]"""
    
    signals.message.emit(help_message)
#endregion


#region Private Functions
func _connect_signals() -> void:
    signals.command.connect(_on_command)
    signals.message.connect(_on_message)


func _on_message(msg: String) -> void:
    if history.size() >= max_history_size:
        history.pop_back()
        
    history.append(msg)
    

func _on_update_room(room: Room) -> void:
    if Game.local_player.current_room == room:
        _on_message("Something happened in your room.")
#endregion
