# scripts/player.gd
class_name Player extends Node

@export var display_name := "Mouse"
@export var inventory_capacity := 0  # 0 = infinite

var spawn_room: RoomNode
var current_room: RoomNode
var inventory_items: Array[ItemNode] = []

var hp := 100
var speed := 100

@onready var signals := Global.signals

#region Public Interface
func get_inventory_display() -> String:
    if inventory_items.is_empty():
        return "[center][b]%s's Inventory[/b][/center]\n┌────────────────────────────────────────────────┐\n│                  Empty                         │\n└────────────────────────────────────────────────┘" % display_name
    
    var text = ""
    var border_width = 50
    
    text += "[center][b]%s's Inventory[/b][/center]\n" % display_name
    text += "┌" + "─".repeat(border_width - 2) + "┐\n"    
    text += "[table=2][cell][b]    Item    [/b][/cell][cell][b]    Description    [/b][/cell]"
    
    for item in inventory_items:
        text += "[cell]    [u][color=yellow]%s[/color][/u]    [/cell][cell]    [i]%s[/i]    [/cell]" % [
            item.get_display_name(), 
            item.get_short_desc()
        ]
    
    text += "[/table]\n"
    text += "└" + "─".repeat(border_width - 2) + "┘"
    
    return text

func can_add_item() -> bool:
    if inventory_capacity == 0:  # Infinite capacity
        return true
    return inventory_items.size() < inventory_capacity

func add_item(item: ItemNode) -> bool:
    if not can_add_item():
        return false
    
    inventory_items.append(item)
    signals.item_picked_up.emit(self, item)
    signals.inventory_changed.emit(self)
    return true

func remove_item_by_name(item_name: String) -> ItemNode:
    for i in range(inventory_items.size()):
        var item = inventory_items[i]
        if item.get_display_name().to_lower() == item_name.to_lower():
            if item.can_be_picked_up():  # Can also be dropped
                inventory_items.remove_at(i)
                signals.inventory_changed.emit(self)
                return item
    return null

func find_item_by_name(item_name: String) -> ItemNode:
    for item in inventory_items:
        if item.get_display_name().to_lower() == item_name.to_lower():
            return item
    return null

func get_current_focus() -> Node:
    return current_room

func move_to_room(new_room: RoomNode) -> void:
    var old_room = current_room
    
    if current_room:
        current_room.remove_player(self)
    
    current_room = new_room
    
    if current_room:
        current_room.add_player(self)
    
    # Emit movement signals through signal bus
    if old_room and new_room:
        signals.player_moved.emit(self, old_room, new_room)
#endregion

#region Godot Callbacks
func _ready() -> void:
    # No longer need local inventory_changed signal
    pass
#endregion
