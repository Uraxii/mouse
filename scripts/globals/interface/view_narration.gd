class_name ViewNarration extends RichTextLabel


#region Godot Callback Functions
func _ready() -> void:
    add_theme_font_override(
        "normal_font",
        preload("res://fonts/Noto_Sans/static/NotoSans-Regular.ttf"))
        
    _connect_signals()
    clear()
#endregion


#region Private Functions
func _connect_signals() -> void:
    print_debug("connecting narratio signals")
    Global.signals.message.connect(_on_message)
    

func _on_message(msg: String) -> void:
    print_debug(msg)
    # clear()
    append_text(msg + "\n\n")
#endregion
