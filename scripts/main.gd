class_name Main extends Node


func _ready() -> void:
    Global.signals.start_game.emit()
