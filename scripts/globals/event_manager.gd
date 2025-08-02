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
        "help":
            help()
        "inspect":
            inspect(cmd.target)
        "look":
            look(cmd.target)
        "pickup":
            pickup(cmd.target)
        "search":
            search(cmd.target)
        _:
            signals.message.emit("You don't know how to %s" % [cmd])


func help() -> void:
    var help_message = """[center][b]HELP[/b][/center]
    [left][u]Actions[/u]
    
    [b]Inspect[/b]
    \t...
    [b]Look[/b]
    \t...
    [b]Pickup[/b]
    \t...
    [b]Search[/b]
    \t...
    [b]Help[/b]
    \tShow This menu.[/left]"""
    
    signals.message.emit(help_message)


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
            function = player.check_inventory
        "room":
            function = player.current_room.look
        _:
            if player.current_focus.has_method("look"):
                function = player.current_focus.look

    if not function:
        signals.message.emit("There's nothing like that here.")
        return
        
    signals.message.emit(function.call())


func pickup(target_str: String) -> void:
    var item = player.current_room.pickup(target_str)
    
    if player.inventory.is_full:
        signals.message.emit("You're carrying too much to pick up anything else.")
        return
    
    if not item:
        signals.message.emit("Hrm... No %s here" % [target_str])
        return
        
    player.inventory.add_item(item)
    signals.message.emit(
        "The [%s] was placed into your bag." % item.display_name)


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
