# scripts/globals/game_manager.gd - Updated for node-based maps
class_name GameManager extends Node

@onready var signals := Global.signals

var autoload_map_scene: PackedScene = preload("res://scenes/map_000.tscn")
@export var autoload_map_id: String = "main"

var current_map: MapNode
var maps: Dictionary = {}  # map_id -> MapNode

var player_scene := preload("res://scenes/player.tscn")
var local_player: Player = null
var players: Array[Player] = []

#region Public Interface
func load_map_scene(map_scene_path: String, map_id: String = "main") -> MapNode:
    # Unload current map if exists
    if current_map:
        unload_map()
    
    # Load the map scene
    var map_scene = load(map_scene_path)
    if not map_scene:
        push_error("Failed to load map scene: %s" % map_scene_path)
        return null
    
    var map_node: MapNode = map_scene.instantiate()
    map_node.name = "Map_%s" % map_id
    
    # Add to scene and track
    add_child(map_node)
    maps[map_id] = map_node
    current_map = map_node
    
    # Connect map signals
    map_node.map_loaded.connect(_on_map_loaded)
    
    print_debug("Loaded map: %s" % map_id)
    return map_node

func load_map_scene_resource(map_scene_resource: PackedScene, map_id: String = "main") -> MapNode:
    # Unload current map if exists
    if current_map:
        unload_map()
    
    if not map_scene_resource:
        push_error("Map scene resource is null!")
        return null
    
    var map_node: MapNode = map_scene_resource.instantiate()
    map_node.name = "Map_%s" % map_id
    
    # Add to scene and track
    add_child(map_node)
    maps[map_id] = map_node
    current_map = map_node
    
    # Connect map signals
    map_node.map_loaded.connect(_on_map_loaded)
    
    print_debug("Loaded map from resource: %s" % map_id)
    return map_node

func unload_map(map_id: String = "") -> void:
    var map_to_unload = current_map
    
    if map_id and map_id in maps:
        map_to_unload = maps[map_id]
        maps.erase(map_id)
    
    if map_to_unload:
        # Move all players out of rooms
        for player in players:
            if player.current_room and is_instance_valid(player.current_room):
                player.current_room.remove_player(player)
                player.current_room = null
        
        map_to_unload.queue_free()
        if map_to_unload == current_map:
            current_map = null
        
        print_debug("Unloaded map")

func get_room_by_id(room_id: int) -> RoomNode:
    if current_map:
        return current_map.get_room_by_id(room_id)
    return null

func get_spawn_rooms() -> Array[RoomNode]:
    if current_map:
        return current_map.get_spawn_rooms()
    return []

func switch_to_map(map_id: String) -> bool:
    if map_id in maps:
        current_map = maps[map_id]
        return true
    return false
#endregion

#region Actions
func move_player(player: Player, destination: RoomNode) -> void:
    var last_room = player.current_room
    print_debug("Moved %s from %s to %s" % [player, last_room, destination])
    
    player.move_to_room(destination)
    
    if player == local_player:
        var msg = destination.entrance_text if not destination.entrance_text.is_empty() else "You enter %s." % destination.get_display_name()
        signals.message.emit(msg)

func move_player_through_door(player: Player, door: DoorNode) -> bool:
    if not door.can_pass_through():
        signals.message.emit(door.locked_message)
        return false
    
    var destination_room = get_room_by_id(door.get_destination_id())
    if not destination_room:
        signals.message.emit("The door leads nowhere...")
        return false
    
    move_player(player, destination_room)
    return true
#endregion

#region Godot Callback functions
func _ready() -> void:
    signals.start_game.connect(_on_start_game)
#endregion

#region Private Functions
func _on_start_game() -> void:
    # Check if autoload map is set
    if autoload_map_scene:
        load_map_scene_resource(autoload_map_scene, autoload_map_id)
    else:
        # Fallback to hardcoded map
        load_map_scene("res://scenes/maps/tutorial_map.tscn", "tutorial")
    
    local_player = _create_player()
    
    for player in players:
        _spawn_player(player)

func _create_player() -> Player:
    var player: Player = player_scene.instantiate()
    players.append(player)
    add_child.call_deferred(player)
    return players[-1]

func _spawn_player(player: Player) -> void:
    if not current_map:
        push_error("No current map to spawn player in!")
        return
    
    if not player.spawn_room:
        var spawn_rooms = get_spawn_rooms()
        if spawn_rooms.size() > 0:
            player.spawn_room = spawn_rooms.pick_random()
        else:
            push_error("No spawn rooms found!")
            return
    
    move_player(player, player.spawn_room)

func _on_map_loaded() -> void:
    print_debug("Map loaded signal received")
    
    # Print map statistics
    if current_map:
        var stats = current_map.get_map_stats()
        print_debug("Map Stats: %s" % str(stats))
#endregion
