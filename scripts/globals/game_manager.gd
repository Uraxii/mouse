class_name GameManager extends Node

@onready var signals := Global.signals

var map: Map = preload("res://resources/maps/m1/m1.tres")
var remaining_time := map.time

var player_scene := preload("res://scenes/player.tscn")
var local_player: Player = null
var players: Array[Player] = []


#region Actions
func move(player: Player, destination: Room) -> void:
    var last_room = player.current_room
    print_debug("Moved %s from %s to %s" % [player, last_room, destination])
    player.current_room = destination
    
    if player == local_player:
        var msg = player.current_room.description
        signals.message.emit(msg)
#endregion


#region Godot Callback functions
func _ready() -> void:
    signals.start_game.connect(_on_start_game)
#endregion


#region Private Functions
func _on_start_game() -> void:
    Global.signals.message.emit("Hello from the Game Manager :p")
    
    Global.objectives.load_map_objectives(map.objectives)
    
    local_player = _create_player()
    
    for player in players:
        _spawn_player(player)
        

func _create_player() -> Player:
    var player: Player = player_scene.instantiate()
    players.append(player)
    add_child.call_deferred(player)
    return players[-1]
    

func _spawn_player(player: Player) -> void:
    if not player.spawn_room:
        player.spawn_room = map.get_spawn_rooms().pick_random()
        
    move(player, player.spawn_room)
#endregion
