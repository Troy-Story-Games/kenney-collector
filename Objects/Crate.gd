extends RigidBody
class_name Crate

signal button_pressed()

# warning-ignore:unused_class_variable
export(int) var POINTS = 1
export(Color) var PRESSED_COLOR = Color.greenyellow

var button_pressed = false

onready var button = $Button


func random_rotation():
	# First decide if we're going to lay it on it's side or flip it upside down
	var rotate_amnt : float = 180.0
	var r : float = randf()
	if r < 0.5:
		rotate_amnt = 90.0
	rotate(Vector3(1, 0, 0), deg2rad(rotate_amnt))

	# Then decide how much to rotate it around the Y
	rotate_amnt = rand_range(0.0, 360.0)
	rotate(Vector3(0, 1, 0), deg2rad(rotate_amnt))


func _on_ButtonPressArea_body_entered(_body):
	var mesh : ArrayMesh = button.mesh
	var mat : SpatialMaterial = SpatialMaterial.new()
	mat.albedo_color = PRESSED_COLOR
	mesh.surface_set_material(1, mat)
	button_pressed = true
	emit_signal("button_pressed")
	# TODO: Dissolve/Delete
	# TODO: Spawn inner item
