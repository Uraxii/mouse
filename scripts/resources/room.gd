class_name Room extends Resource

#region Resource Data
@export var id := -1
@export var display_name := "Room"

@export_multiline var description := ""
@export_multiline var entrance_text := "You enter an unassuming room."
@export_multiline var empty_room_text := "There's nothing here besides dust and an uneasy feeling."
@export_multiline  var search_text := "Nothing important is here."

@export var connections: Array[int] 
@export var inventory: Inventory = Inventory.new()
@export var tags: Array[String]
#endregion


#region Public Functions
func look() -> String:
    var out_str = "You observe the room.\n"
    out_str += description
    return out_str
    
    
func pickup(item_name: String) -> Item:
    return inventory.remove_item_by_name(item_name)
    

func search() -> String:
    if inventory.is_empty:
        return "You search the room.\n" + empty_room_text
    
    if inventory.items.size() == 1:
        # TODO: a/an logic
        return "You found a [%s]!" % [inventory.items[0].display_name]
        
    var out_str = "There are a few things in here...\n"
    
    for item in inventory.items:
        out_str += "- [%s]\n" + item.display_name
    
    return out_str
#endregion


#region Godot Callback Functions
func _ready() -> void:
    _validate()
    
#endregion


#region Private functions
func _validate() -> void:
    if id < 0:
        push_warning("Room has invalid id!")
#endregion
