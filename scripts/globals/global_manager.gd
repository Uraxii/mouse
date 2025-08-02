class_name GlobalManager extends Node

var signals := SignalBus.new()
var events := EventManager.new()
var objectives := ObjectiveManager.new()


func _ready() -> void:
    add_child(objectives)
    events.setup()
