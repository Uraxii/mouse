class_name ItemNode extends Node

@export var item_data: Item

signal used_on_target(target: Node)
signal picked_up(player: Player)
signal dropped(room: RoomNode)

#region Public Interface
func get_display_name() -> String:
    return item_data.display_name if item_data else "Unknown Item"

func get_short_desc() -> String:
    return item_data.short_desc if item_data else ""

func inspect() -> String:
    return item_data.inspect_text if item_data else "There's nothing special about this."

func can_be_picked_up() -> bool:
    if not item_data:
        return false
    return not item_data.tags.has("cannot_drop")

func has_tag(tag: String) -> bool:
    if not item_data:
        return false
    return item_data.tags.has(tag)

func can_use_on(target: Node) -> bool:
    if not item_data:
        return false
    
    # Keys can be used on doors
    if has_tag("key") and target is DoorNode:
        return true
    
    # Add more usage rules here
    return false

func use_on(target: Node, user: Player) -> String:
    if not can_use_on(target):
        return "You can't use the %s on that." % get_display_name()
    
    var result = ""
    
    # Handle key usage on doors
    if has_tag("key") and target is DoorNode:
        result = target.try_unlock_with_key(self)
        
    used_on_target.emit(target)
    return result

func get_charges() -> int:
    return item_data.charges if item_data else -1

func consume_charge() -> bool:
    if not item_data or item_data.charges == Item.INFINITE:
        return true
    
    if item_data.charges > 0:
        item_data.charges -= 1
        return true
    
    return false
#endregion

#region Godot Callbacks
func _ready() -> void:
    if not item_data:
        push_warning("ItemNode has no item_data assigned!")
    
    # Set the node name to match the item for easier debugging
    if item_data:
        name = item_data.display_name.replace(" ", "_")
#endregion
