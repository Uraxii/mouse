class_name Task extends Resource


@export var id: String = ""
@export_multiline var description: String = ""
@export_enum("pickup", "use", "search", "move", "look", "inspect", "drop")
var trigger_type: String = "pickup"
@export var target: String = "" 
@export_multiline var completion_message: String = ""
@export_multiline var hint_message: String = ""
@export var is_completed: bool = false


func complete() -> String:
    is_completed = true
    return completion_message


func matches_action(action: String, target_name: String) -> bool:
    if is_completed:
        return false
        
    if trigger_type.to_lower() != action.to_lower():
        return false
        
    if target.is_empty():
        return true
        
    return target.to_lower() == target_name.to_lower()


func get_hint() -> String:
    return hint_message
