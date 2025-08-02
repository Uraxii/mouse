class_name Player extends Node


var display_name := "Mouse"
var inventory := Inventory.new()
var spawn_room: Room
var current_room: Room
# TODO: Focusing other stuff. For now, focus will always be the current room.
var current_focus:
    get: return current_room

var hp := 100
var speed := 100


func check_inventory() -> String:
    return "===> %s's  Inventory <===\n%s\n" % [display_name, inventory.text]
