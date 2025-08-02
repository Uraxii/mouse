class_name RoomNode extends Node

# Room properties - directly editable in inspector
@export var room_id: int = -1
@export var display_name: String = "Room"
@export_multiline var description: String = ""
@export_multiline var entrance_text: String = "You enter an unassuming room."
@export_multiline var empty_room_text: String = "There's nothing here besides dust and an uneasy feeling."
@export_multiline var search_text: String = "Nothing important is here."
@export var tags: Array[String] = []

# Node containers - automatically found by unique names
@onready var inventory_container: Node = $Inventory
@onready var doors_container: Node = $Doors
@onready var npcs_container: Node = $NPCs
@onready var signals := Global.signals

var players_in_room: Array[Player] = []

#region Public Interface
func get_id() -> int:
    return room_id

func get_display_name() -> String:
    return display_name

func look() -> String:
    var result = "You observe the room.\n" + description
    
    # Add door information
    var doors = get_doors()
    if doors.size() > 0:
        result += "\n\nYou can see:"
        for door in doors:
            var door_desc = "- A [color=cyan]%s[/color]" % door.get_display_name().to_lower()
            if door.is_locked:
                door_desc += " (locked)"
            result += "\n" + door_desc
    
    return result

func inspect() -> String:
    signals.room_inspected.emit(self, Game.local_player)
    return description

func search() -> String:
    var items = get_items()
    if items.is_empty():
        signals.room_searched.emit(self, Game.local_player)
        return "You search the room.\n" + empty_room_text
    
    if items.size() == 1:
        signals.room_searched.emit(self, Game.local_player)
        return "You found a [color=yellow]%s[/color]!" % [items[0].get_display_name()]
    
    var out_str = "There are a few things in here...\n"
    for item in items:
        out_str += "- [color=yellow]%s[/color]\n" % item.get_display_name()
    
    signals.room_searched.emit(self, Game.local_player)
    return out_str

func pickup_item(item_name: String) -> ItemNode:
    for child in inventory_container.get_children():
        if child is ItemNode and child.get_display_name().to_lower() == item_name.to_lower():
            if child.can_be_picked_up():
                child.get_parent().remove_child(child)
                return child
    return null

func drop_item(item_node: ItemNode) -> void:
    if item_node and inventory_container:
        if item_node.get_parent() != inventory_container:
            inventory_container.add_child(item_node)

func get_items() -> Array[ItemNode]:
    var items: Array[ItemNode] = []
    for child in inventory_container.get_children():
        if child is ItemNode:
            items.append(child)
    return items

func get_doors() -> Array[DoorNode]:
    var doors: Array[DoorNode] = []
    for child in doors_container.get_children():
        if child is DoorNode:
            doors.append(child)
    return doors

func get_door_by_name(door_name: String) -> DoorNode:
    for door in get_doors():
        if door.get_display_name().to_lower() == door_name.to_lower():
            return door
    return null

func find_entity_by_name(entity_name: String) -> Node:
    # Search items
    for item in get_items():
        if item.get_display_name().to_lower() == entity_name.to_lower():
            return item
    
    # Search doors
    for door in get_doors():
        if door.get_display_name().to_lower() == entity_name.to_lower():
            return door
    
    # Search NPCs
    for child in npcs_container.get_children():
        if child.has_method("get_display_name"):
            if child.get_display_name().to_lower() == entity_name.to_lower():
                return child
    
    return null

func add_player(player: Player) -> void:
    if player not in players_in_room:
        players_in_room.append(player)
        signals.player_entered_room.emit(player, self)

func remove_player(player: Player) -> void:
    if player in players_in_room:
        players_in_room.erase(player)
        signals.player_exited_room.emit(player, self)
#endregion

#region Godot Callbacks
func _ready() -> void:
    if room_id < 0:
        push_warning("Room %s has invalid id!" % name)
    
    # Remove direct door signal connections - everything goes through signal bus now
#endregion
