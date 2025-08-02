class_name Map extends Resource


@export var time := 100
@export var layout: Array[Room] = []


#region Public Functions
func get_spawn_rooms() -> Array[Room]:
    print_debug("Number of rooms in layout: %d" % [layout.size()])
    
    var spawn_rooms: Array[Room] = []
    
    for i in range(layout.size()):
        var room = layout[i]
        if room.tags.has("spawn_point"):
            spawn_rooms.append(room)
            
    print_debug("Spawn rooms: %s" % [str(spawn_rooms)])
    return spawn_rooms
            
#endregion
