class_name CommandInput extends TextEdit


@onready var submit_button: Button = %Submit
@onready var signals := Global.signals


func _ready() -> void:
    submit_button.pressed.connect(_on_submit)
    
    
func _on_submit() -> void:
    if not text:
        return
        
    var commands: Array[Command] = []
    var command_sequence = text.split(";")
    
    for command in command_sequence:
        var stripped_action = command.strip_edges()
        var parts = stripped_action.split(" ", false, 1)
        var action = parts[0]
        var target = parts[1] if parts.size() > 1 else ""
        commands.append(Command.new(action, target))
    
    for command in commands:
        signals.command.emit(command)
        
    clear()
