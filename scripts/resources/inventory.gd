class_name Inventory extends Resource

static var INFINITE := 0

#region Resource Data
@export var id := -1
@export var display_name := "Items"
@export var items: Array[Item]
@export var capacity := INFINITE

@export_multiline var inspect_text := "It can hold items."
@export_multiline var empty_text := "Sorry bud. Nothing but air here."
#endregion

#region State Data
var is_empty: bool:
    get: return items.size() == 0

var is_full: bool:
    get:
        if capacity == 0:
            return false
        return items.size() >= capacity
#endregion


#region Commands
func inspect() -> String:
    return inspect_text 


func look() -> String:
    return to_table()
#endregion


#region Inventory Management
func add_item(item_to_add: Item) -> Item:
    if capacity and items.size() >= capacity:
        return item_to_add

    items.append(item_to_add)
    
    return null
    

func remove_item_by_name(item_name: String) -> Item:
    var removed_item: Item = null

    for i in range(items.size()):
        if items[i].display_name.to_lower() == item_name.to_lower():
            if items[i].tags.has("cannot_drop"):
                # Using 'continue' here instead of 'break'.
                # This guards against bugs caused by item id collisions.
                continue

            removed_item = items[i]
            items.remove_at(i)
            break

    return removed_item


func remove_item_by_id(item_id_to_remove: int) -> Item:
    var removed_item: Item = null

    for i in range(items.size()):
        if items[i].id == item_id_to_remove:
            if items[i].tags.has("cannot_drop"):
                # Using 'continue' here instead of 'break'.
                # This guards against bugs caused by item id collisions.
                continue

            removed_item = items[i]
            items.remove_at(i)
            break

    return removed_item


func to_table() -> String:
    var text = ""
    var border_width = 50  # Adjust as needed
    
    text += "[center][b]%s[/b][/center]\n" % display_name
    text += "┌" + "─".repeat(border_width - 2) + "┐\n"    
    text += "[table=2][cell][b]    Item    [/b][/cell][cell][b]    Description    [/b][/cell]"
    
    for item in items:
        text += "[cell]    [u][color=yellow]%s[/color][/u]    [/cell][cell]    [i]%s[/i]    [/cell]" % [
            item.display_name, 
            item.short_desc
        ]
    
    text += "[/table]\n"
    text += "└" + "─".repeat(border_width - 2) + "┘"
    
    return text
#endregion
