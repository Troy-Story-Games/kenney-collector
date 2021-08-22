extends KinematicBody
class_name OptionCrate

export(float) var SPEED = 2.5
export(float) var CLOSE_ENOUGH = 0.4

var holding := false
var direction := Vector3.ZERO
var velocity := Vector3.ZERO
var spawn := Vector3.ZERO

onready var fasterButton = $FasterButtonUI3D/Viewport/FasterButton
onready var advanceTrain = $AdvanceTrainButtonUI3D/Viewport/AdvanceTrainButton

func _ready():
    var parent = get_parent()
    var spawn_node : Position3D = parent.find_node("OptionCrateSpawn")
    assert(spawn_node != null)
    spawn = spawn_node.global_transform.origin


func _physics_process(delta):
    if holding:
        return
    if global_transform.origin.distance_to(spawn) <= CLOSE_ENOUGH:
        return

    direction = global_transform.origin.direction_to(spawn)
    velocity = direction * (SPEED * delta)
    # warning-ignore:return_value_discarded
    move_and_collide(velocity)


func _on_FasterButtonArea_body_entered(_body):
    Events.emit_signal("global_toggle_faster")
    fasterButton.toggle()


func _on_AdvanceTrainButtonArea_body_entered(_body):
    Events.emit_signal("global_toggle_train")
    advanceTrain.toggle()
