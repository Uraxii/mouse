class_name MapNode extends Node

@export var time_remaining: int = 100
@export var map_title: String = "Untitled Map"
@export_multiline var map_description: String = ""
@export var objectives: Array[Objective] = []

@onready var signals := Global.signals

# id -> RoomNode for fast lookup
var room_lookup: Dictionary = {}

#region Public Interface
func get_room_by_id(room_id: int) -> RoomNode:
    return room_lookup.get(room_id, null)

func get_spawn_rooms() -> Array[RoomNode]:
    var spawn_rooms: Array[RoomNode] = []
    for room in get_all_rooms():
        if room.tags.has("spawn_point"):
            spawn_rooms.append(room)
    return spawn_rooms

func get_all_rooms() -> Array[RoomNode]:
    var rooms: Array[RoomNode] = []
    for child in get_children():
        if child is RoomNode:
            rooms.append(child)
    return rooms

func add_room_node(room_node: RoomNode) -> void:
    if room_node.get_id() in room_lookup:
        push_warning("Room with ID %d already exists in map!" % room_node.get_id())
        return
    
    add_child(room_node)
    room_lookup[room_node.get_id()] = room_node

func remove_room_node(room_node: RoomNode) -> void:
    if room_node.get_id() in room_lookup:
        room_lookup.erase(room_node.get_id())
    room_node.queue_free()

func validate_connections() -> bool:
    var valid = true
    
    for room in get_all_rooms():
        # Check door destinations
        for door in room.get_doors():
            var dest_id = door.get_destination_id()
            if dest_id >= 0 and not get_room_by_id(dest_id):
                push_error("Room %d has door pointing to non-existent room %d" % [room.get_id(), dest_id])
                valid = false
    
    return valid

func get_map_stats() -> Dictionary:
    var rooms = get_all_rooms()
    return {
        "total_rooms": rooms.size(),
        "spawn_rooms": get_spawn_rooms().size(),
        "total_items": _count_total_items(),
        "total_doors": _count_total_doors(),
        "time_remaining": time_remaining,
        "objectives": objectives.size()
    }

func get_objectives() -> Array[Objective]:
    return objectives
#endregion

#region Godot Callbacks
func _ready() -> void:
    # Build room lookup
    for room in get_all_rooms():
        room_lookup[room.get_id()] = room
    
    # Load objectives into the objective manager
    if objectives.size() > 0:
        Global.objectives.load_map_objectives(objectives)
    
    # Validate connections after a frame
    call_deferred("_post_load_validation")

func _post_load_validation() -> void:
    if validate_connections():
        print_debug("Map '%s' loaded successfully with %d rooms and %d objectives" % [map_title, get_all_rooms().size(), objectives.size()])
        signals.map_loaded.emit(self)
    else:
        push_error("Map validation failed!")
#endregion

#region Private Functions
func _count_total_items() -> int:
    var total = 0
    for room in get_all_rooms():
        total += room.get_items().size()
    return total

func _count_total_doors() -> int:
    var total = 0
    for room in get_all_rooms():
        total += room.get_doors().size()
    return total

func _on_room_player_entered(player: Player) -> void:
    print_debug("Player %s entered room %s" % [player.display_name, player.current_room.get_display_name()])

func _on_room_player_exited(player: Player) -> void:
    print_debug("Player %s exited room" % [player.display_name])

func _on_time_tick() -> void:
    if time_remaining > 0:
        time_remaining -= 1
        
        if time_remaining <= 0:
            _on_time_expired()

func _on_time_expired() -> void:
    print_debug("Time expired on map!")
#endregion
