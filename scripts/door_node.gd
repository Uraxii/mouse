class_name DoorNode extends Node

# Door properties - directly editable in inspector
@export var display_name: String = "Door"
@export_multiline var description: String = "A sturdy wooden door."
@export var destination_room_id: int = -1
@export var is_locked: bool = false
@export var required_key_tags: Array[String] = []
@export var required_key_name: String = ""
@export_multiline var unlock_message: String = "The door unlocks with a satisfying click."
@export_multiline var already_unlocked_message: String = "The door is already unlocked."
@export_multiline var wrong_key_message: String = "The key doesn't fit this door."
@export_multiline var locked_message: String = "The door is locked."

@onready var signals := Global.signals

#region Public Interface
func get_display_name() -> String:
    return display_name

func inspect() -> String:
    var result = description
    if is_locked:
        result += "\nThe door appears to be locked."
        if required_key_name:
            result += " It looks like it needs a %s." % required_key_name
    else:
        result += "\nThe door is unlocked."
    return result

func can_pass_through() -> bool:
    return not is_locked

func try_unlock_with_key(key_item: ItemNode) -> String:
    if not is_locked:
        return already_unlocked_message
    
    if not _key_matches(key_item):
        return wrong_key_message
    
    is_locked = false
    # Door unlocked signal is emitted by the room that contains this door
    return unlock_message

func use_door(user: Player) -> String:
    if is_locked:
        return locked_message
    
    # Door used signal is emitted by the room that contains this door
    return "You pass through the %s." % display_name

func get_destination_id() -> int:
    return destination_room_id
#endregion

#region Private Functions
func _key_matches(key_item: ItemNode) -> bool:
    # Check by name first
    if required_key_name and key_item.get_display_name().to_lower() == required_key_name.to_lower():
        return true
    
    # Check by tags
    for required_tag in required_key_tags:
        if key_item.has_tag(required_tag):
            return true
    
    return false
#endregion

#region Godot Callbacks
func _ready() -> void:
    name = display_name.replace(" ", "_")
    
    if destination_room_id < 0:
        push_warning("Door %s has no destination room set!" % name)
#endregion
