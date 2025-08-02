class_name Item extends Resource

static var INFINITE := -1

@export var display_name := ""
@export_multiline var short_desc: String = ""
@export_multiline var inspect_text: String = ""

@export var charges := INFINITE
@export var tags : Array[String] = []


func inspect() -> String:
    return inspect_text
