extends Control

var on := false
var viewport = null

onready var offColorRect = $OffColorRect
onready var onColorRect = $OnColorRect


func _ready():
    viewport = get_parent()
    viewport.render_target_clear_mode = Viewport.CLEAR_MODE_NEVER


func toggle():
    on = !on
    if on:
        offColorRect.visible = false
        onColorRect.visible = true
    else:
        offColorRect.visible = true
        onColorRect.visible = false
    viewport.render_target_clear_mode = Viewport.CLEAR_MODE_ONLY_NEXT_FRAME
