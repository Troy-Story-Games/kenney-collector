extends CharacterBody3D
class_name OptionCrate

@export var SPEED: float = 2.5
@export var CLOSE_ENOUGH: float = 0.4

var holding := false
var direction := Vector3.ZERO
var spawn := Vector3.ZERO

@onready var fasterButton = $FasterButtonUI3D/SubViewport/FasterButton
@onready var advanceTrain = $AdvanceTrainButtonUI3D/SubViewport/AdvanceTrainButton

func _ready():
	var parent = get_parent()
	var spawn_node : Marker3D = parent.find_child("OptionCrateSpawn")
	assert(spawn_node != null)
	spawn = spawn_node.global_transform.origin

	# warning-ignore:return_value_discarded
	Events.connect("global_train_at_station", Callable(self, "_on_Events_global_train_at_station"))


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
	SoundFx.play_3d("OptionToggle", global_transform.origin)
	Events.emit_signal("global_toggle_faster")
	fasterButton.toggle()


func _on_AdvanceTrainButtonArea_body_entered(_body):
	SoundFx.play_3d("OptionToggle", global_transform.origin)
	Events.emit_signal("global_toggle_train")
	advanceTrain.toggle()


func _on_Events_global_train_at_station():
	if advanceTrain.on:
		advanceTrain.toggle()
