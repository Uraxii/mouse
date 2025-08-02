class_name Inventory extends Resource

static var INFINITE := 0

#region Resource Data
@export var id := -1
@export var items: Array[Item]
@export var capacity := INFINITE

@export_multiline var inspect_text := "It can hold items."
@export_multiline var empty_text := "Sorry bud. Nothing but air here."
#endregion

#region State Data
var text := ""

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
    return text
#endregion


#region Inventory Management
func add_item(item_to_add: Item) -> Item:
    if capacity and items.size() >= capacity:
        return item_to_add

    items.append(item_to_add)
    update_inventory_text()
    return null
    

func remove_item_by_name(display_name: String) -> Item:
    var removed_item: Item = null

    for i in range(items.size()):
        if items[i].display_name.to_lower() == display_name.to_lower():
            if items[i].tags.has("cannot_drop"):
                # Using 'continue' here instead of 'break'.
                # This guards against bugs caused by item id collisions.
                continue

            removed_item = items[i]
            items.remove_at(i)
            break
            
    update_inventory_text()

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
            
    update_inventory_text()

    return removed_item


func update_inventory_text() -> void:
    if is_empty:
        text = empty_text
        return
    
    for item in items:
        text += "[b][u]%s[/b][/u]\n\t-[i]%s[/i]\n" % [item.display_name, item.short_desc]
#endregion
