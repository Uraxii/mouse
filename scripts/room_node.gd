class_name RoomNode extends Node

@export var room_data := Room.new()

@onready var inventory_container: Node = %Inventory
@onready var doors_container: Node = %Doors
@onready var npcs_container: Node = %NPCs

signal player_entered(player: Player)
signal player_exited(player: Player)

var players_in_room: Array[Player] = []

#region Public Interface
func get_id() -> int:
    return room_data.id if room_data else -1

func get_display_name() -> String:
    return room_data.display_name if room_data else "Unknown Room"

func look() -> String:
    if not room_data:
        return "You can't make out anything in this strange void."
    return room_data.look()

func search() -> String:
    var items = get_items()
    if items.is_empty():
        return room_data.empty_room_text if room_data else "There's nothing here."
    
    if items.size() == 1:
        return "You found a [color=yellow]%s[/color]!" % [items[0].get_display_name()]
    
    var out_str = "There are a few things in here...\n"
    for item in items:
        out_str += "- [color=yellow]%s[/color]\n" % item.get_display_name()
    
    return out_str

func pickup_item(item_name: String) -> ItemNode:
    for child in inventory_container.get_children():
        if child is ItemNode and child.get_display_name().to_lower() == item_name.to_lower():
            if child.can_be_picked_up():
                # Remove from parent instead of reparenting to null
                child.get_parent().remove_child(child)
                return child
    return null

func drop_item(item_node: ItemNode) -> void:
    if item_node and inventory_container:
        # Only add as child if it doesn't already have this as a parent
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
        player_entered.emit(player)

func remove_player(player: Player) -> void:
    if player in players_in_room:
        players_in_room.erase(player)
        player_exited.emit(player)
#endregion

#region Godot Callbacks
func _ready() -> void:
    if not room_data:
        push_warning("RoomNode has no room_data assigned!")
        return
    
    _populate_from_resource()

func _populate_from_resource() -> void:
    if not room_data or not room_data.inventory:
        return
    
    # Convert resource items to item nodes
    for item_resource in room_data.inventory.items:
        var item_node = ItemNode.new()
        item_node.item_data = item_resource
        inventory_container.add_child(item_node)
#endregion
