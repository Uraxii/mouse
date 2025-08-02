class_name GlobalManager extends Node

var signals := SignalBus.new()
var events := EventManager.new()


func _ready() -> void:
    events.setup()
