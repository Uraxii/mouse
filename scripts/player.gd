class_name Player extends Node


@export var display_name := "Mouse"
@export var inventory := Inventory.new()


var spawn_room: Room
var current_room: Room
# TODO: Focusing other stuff. For now, focus will always be the current room.
var current_focus:
    get: return current_room

var hp := 100
var speed := 100


func _ready() -> void:
    inventory.display_name = "%s's Inventory" % display_name
