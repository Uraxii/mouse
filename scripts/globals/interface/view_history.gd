class_name ViewHistory extends Control

@onready var events := Global.events
@onready var event_log := %EventLog

#region Godot Callback Fucntions
func _ready() -> void:
    _connect_signals()
    _on_message()
#endregion


#region Private Functions
func _connect_signals() -> void:
    Global.signals.message.connect(_on_message)


@warning_ignore("unused_parameter")
func _on_message(msg: String = "") -> void:
    # print_debug(events.history)
    
    event_log.clear()
    event_log.append_text("=== END OF HISTORY ===\n")
    
    for message in events.history:
        event_log.append_text("%s\n=====\n" % [message])
#endregion
