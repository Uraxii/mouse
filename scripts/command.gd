class_name Command

var action := ""
var target := ""


func _init(_action: String, _target: String) -> void:
    self.action = _action.to_lower()
    self.target = _target.to_lower()


func _to_string() -> String:
    return "%s %s" % [action, target]
