class_name Task extends Resource

@export var id: String = ""
@export_multiline var description: String = ""

@export_enum(
    "pickup", "use", "unlock", "search", "move",
    "look", "inspect", "drop", "enter", "exit")
var trigger_type: String = "pickup"

@export var target: String = "" 
@export var secondary_target: String = ""
@export_multiline var completion_message: String = ""
@export_multiline var hint_message: String = ""
@export var is_completed: bool = false


func complete() -> String:
    is_completed = true
    return completion_message


func matches_action(action: String, target_name: String, secondary_target_name: String = "") -> bool:
    if is_completed:
        return false
        
    if trigger_type.to_lower() != action.to_lower():
        return false
        
    if secondary_target.is_empty():
        if target.is_empty():
            return true
        return target.to_lower() == target_name.to_lower()
    
    var primary_match = target.is_empty() or target.to_lower() == target_name.to_lower()
    var secondary_match = secondary_target.to_lower() == secondary_target_name.to_lower()
    
    return primary_match and secondary_match


func get_hint() -> String:
    return hint_message
