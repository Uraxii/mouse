class_name ObjectiveManager extends Node

@onready var signals := Global.signals

var active_objectives: Array[Objective] = []
var completed_objectives: Array[Objective] = []


#region Godot Callback Functions
func _ready() -> void:
    signals.objective_progress.connect(_on_objective_progress)
#endregion


#region Public Functions
func load_map_objectives(map_objectives: Array[Objective]) -> void:
    clear_all_objectives()
    
    for objective in map_objectives:
        if objective.auto_start:
            start_objective(objective)


func clear_all_objectives() -> void:
    active_objectives.clear()
    completed_objectives.clear()


func start_objective(objective: Objective) -> void:
    if objective in active_objectives:
        return
        
    objective.start()
    active_objectives.append(objective)
    
    if not objective.description.is_empty():
        signals.message.emit(
            "[color=green][b]New Objective:[/b] %s[/color]" % objective.title)


func complete_objective(objective: Objective) -> void:
    if objective not in active_objectives:
        return
        
    active_objectives.erase(objective)
    completed_objectives.append(objective)
    
    signals.message.emit(
        "[color=gold][b]Objective Complete:[/b] %s[/color]" % objective.title)
        

func show_current_objectives() -> void:
    if active_objectives.is_empty():
        signals.message.emit("No active objectives.")
        return
        
    var text = ""
    var border_width = 60
    
    text += "[center][b]Current Objectives[/b][/center]\n"
    text += "┌" + "─".repeat(border_width - 2) + "┐\n"
    text += "[table=3][cell][b]    Objective    [/b][/cell][cell][b]    Task    [/b][/cell][cell][b]    Status    [/b][/cell]"
    
    for objective in active_objectives:
        var objective_name = objective.title
        var first_task = true
        
        for task in objective.tasks:
            if first_task:
                text += "[cell]    %s    [/cell]" % objective_name
                first_task = false
            else:
                text += "[cell]        [/cell]"
                
            var status = "✓" if task.is_completed else "○"
            var status_color = "green" if task.is_completed else "white"
            
            text += "[cell]    %s    [/cell]" % task.description
            text += "[cell]    [color=%s]%s[/color]    [/cell]" % [status_color, status]
    
    text += "[/table]\n"
    text += "└" + "─".repeat(border_width - 2) + "┘"
    
    signals.message.emit(text)
#endregion


#region Private Functions
func _on_objective_progress(action: String, target: String) -> void:
    for objective in active_objectives:
        var completion_msg = objective.try_progress(action, target)
        
        if not completion_msg.is_empty():
            signals.message.emit(completion_msg)
            
            var hint = objective.get_current_hint()
            if not hint.is_empty():
                signals.message.emit("[color=yellow][i]%s[/i][/color]" % hint)
            
            if objective.is_objective_complete():
                complete_objective(objective)
#endregionc
