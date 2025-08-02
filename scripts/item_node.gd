class_name ItemNode extends Node

# Item properties - directly editable in inspector
@export var display_name: String = "Item"
@export_multiline var short_desc: String = ""
@export_multiline var inspect_text: String = ""
@export var charges: int = -1  # -1 = infinite
@export var tags: Array[String] = []

@onready var signals := Global.signals

#region Public Interface
func get_display_name() -> String:
    return display_name

func get_short_desc() -> String:
    return short_desc

func inspect() -> String:
    return inspect_text if not inspect_text.is_empty() else "There's nothing special about this."

func can_be_picked_up() -> bool:
    return not tags.has("cannot_pickup")

func has_tag(tag: String) -> bool:
    return tags.has(tag)

func can_use_on(target: Node) -> bool:
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
        
    signals.item_used.emit(user, self, target)
    return result

func get_charges() -> int:
    return charges

func consume_charge() -> bool:
    if charges == -1:  # Infinite
        return true
    
    if charges > 0:
        charges -= 1
        return true
    
    return false
#endregion

#region Godot Callbacks
func _ready() -> void:
    # Set the node name to match the item for easier debugging
    if not display_name.is_empty():
        name = display_name.replace(" ", "_")
#endregion
