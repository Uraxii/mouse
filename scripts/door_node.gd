class_name DoorNode extends Node

@export var display_name: String = "Door"
@export var description: String = "A sturdy wooden door."
@export var destination_room_id: int = -1
@export var is_locked: bool = false
@export var required_key_tags: Array[String] = []
@export var required_key_name: String = ""
@export var unlock_message: String = "The door unlocks with a satisfying click."
@export var already_unlocked_message: String = "The door is already unlocked."
@export var wrong_key_message: String = "The key doesn't fit this door."
@export var locked_message: String = "The door is locked."

signal door_unlocked(door: DoorNode, key_used: ItemNode)
signal door_used(door: DoorNode, user: Player)

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
    door_unlocked.emit(self, key_item)
    return unlock_message

func use_door(user: Player) -> String:
    if is_locked:
        return locked_message
    
    door_used.emit(self, user)
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
#endregion
