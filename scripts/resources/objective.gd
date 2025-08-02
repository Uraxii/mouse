class_name Objective extends Resource


@export var title: String = ""
@export_multiline var description: String = ""
@export var tasks: Array[Task] = []
@export var auto_start: bool = false
@export var is_active: bool = false
@export var is_completed: bool = false


func start() -> void:
    is_active = true


func get_current_task() -> Task:
    for task in tasks:
        if not task.is_completed:
            return task
    return null


func is_objective_complete() -> bool:
    for task in tasks:
        if not task.is_completed:
            return false
    return true


func try_progress(action: String, target: String) -> String:
    if not is_active or is_completed:
        return ""
        
    var current_task = get_current_task()
    if not current_task:
        return ""
        
    if current_task.matches_action(action, target):
        var completion_msg = current_task.complete()
        
        # Check if objective is now complete
        if is_objective_complete():
            is_completed = true
            
        return completion_msg
        
    return ""


func get_current_hint() -> String:
    var current_task = get_current_task()
    if current_task:
        return current_task.get_hint()
    return ""
