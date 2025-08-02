# scripts/nodes/map_node.gd - Updated to load room scenes
class_name MapNode extends Node2D

@export var map_data: Map
@export var time_remaining: int = 100

# Preload the room scene
var room_scene := preload("res://scenes/room.tscn")

signal map_loaded()
signal time_changed(new_time: int)

var room_nodes: Array[RoomNode] = []
var room_lookup: Dictionary = {}  # id -> RoomNode for fast lookup

#region Public Interface
func get_room_by_id(room_id: int) -> RoomNode:
    return room_lookup.get(room_id, null)

func get_spawn_rooms() -> Array[RoomNode]:
    var spawn_rooms: Array[RoomNode] = []
    for room in room_nodes:
        if room.room_data and room.room_data.tags.has("spawn_point"):
            spawn_rooms.append(room)
    return spawn_rooms

func get_all_rooms() -> Array[RoomNode]:
    return room_nodes.duplicate()

func add_room_node(room_node: RoomNode) -> void:
    if room_node.get_id() in room_lookup:
        push_warning("Room with ID %d already exists in map!" % room_node.get_id())
        return
    
    add_child(room_node)
    room_nodes.append(room_node)
    room_lookup[room_node.get_id()] = room_node
    
    # Connect room signals
    room_node.player_entered.connect(_on_room_player_entered)
    room_node.player_exited.connect(_on_room_player_exited)

func remove_room_node(room_node: RoomNode) -> void:
    if room_node in room_nodes:
        room_nodes.erase(room_node)
        room_lookup.erase(room_node.get_id())
        room_node.queue_free()

func validate_connections() -> bool:
    var valid = true
    
    for room in room_nodes:
        if not room.room_data:
            continue
            
        # Check door destinations
        for door in room.get_doors():
            var dest_id = door.get_destination_id()
            if dest_id >= 0 and not get_room_by_id(dest_id):
                push_error("Room %d has door pointing to non-existent room %d" % [room.get_id(), dest_id])
                valid = false
        
        # Check legacy connections array
        for connection_id in room.room_data.connections:
            if not get_room_by_id(connection_id):
                push_error("Room %d has connection to non-existent room %d" % [room.get_id(), connection_id])
                valid = false
    
    return valid

func get_map_stats() -> Dictionary:
    return {
        "total_rooms": room_nodes.size(),
        "spawn_rooms": get_spawn_rooms().size(),
        "total_items": _count_total_items(),
        "total_doors": _count_total_doors(),
        "time_remaining": time_remaining
    }
#endregion

#region Godot Callbacks
func _ready() -> void:
    if map_data:
        time_remaining = map_data.time
        _load_from_resource()
    else:
        push_warning("MapNode has no map_data assigned!")

func _load_from_resource() -> void:
    if not map_data or map_data.layout.is_empty():
        push_warning("Map data is empty or invalid!")
        return
    
    print_debug("Loading map with %d rooms..." % map_data.layout.size())
    
    # Create RoomNode instances from Room resources using the scene
    for room_resource in map_data.layout:
        # Instantiate the room scene instead of creating new RoomNode
        var room_node: RoomNode = room_scene.instantiate()
        room_node.room_data = room_resource  # Assign the data after instantiation
        room_node.name = "Room_%d_%s" % [room_resource.id, room_resource.display_name.replace(" ", "_")]
        
        add_room_node(room_node)
        print_debug("Created room: %s (ID: %d)" % [room_node.name, room_resource.id])
    
    # Validate all connections after rooms are created
    call_deferred("_post_load_validation")

func _post_load_validation() -> void:
    if validate_connections():
        print_debug("Map loaded successfully with %d rooms" % room_nodes.size())
        map_loaded.emit()
    else:
        push_error("Map validation failed!")
#endregion

#region Private Functions
func _count_total_items() -> int:
    var total = 0
    for room in room_nodes:
        total += room.get_items().size()
    return total

func _count_total_doors() -> int:
    var total = 0
    for room in room_nodes:
        total += room.get_doors().size()
    return total

func _on_room_player_entered(player: Player) -> void:
    print_debug("Player %s entered room %s" % [player.display_name, player.current_room.get_display_name()])

func _on_room_player_exited(player: Player) -> void:
    print_debug("Player %s exited room" % [player.display_name])

func _on_time_tick() -> void:
    if time_remaining > 0:
        time_remaining -= 1
        time_changed.emit(time_remaining)
        
        if time_remaining <= 0:
            _on_time_expired()

func _on_time_expired() -> void:
    print_debug("Time expired on map!")
    # Handle time expiration logic here
#endregion
