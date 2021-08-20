extends KinematicBody
class_name Player

signal player_died()

export(float) var GRAVITY = -24.8
export(float) var MAX_SPEED = 5
export(float) var JUMP_SPEED = 10
export(float) var ACCELERATION = 12
export(float) var FRICTION = 18
export(float) var MAX_SLOPE_ANGLE = 50
export(float) var MOUSE_SENSITIVITY = 0.1

var playerStats : PlayerStats = Utils.get_player_stats()
var velocity := Vector3.ZERO
var direction := Vector3.ZERO

onready var camera = $RotationHelper/Camera
onready var rotation_helper = $RotationHelper


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# warning-ignore:return_value_discarded
	playerStats.connect("player_died", self, "_on_died")


func _on_died():
	emit_signal("player_died")
	queue_free()


func _physics_process(delta):
	process_input(delta)
	process_movement(delta)


func process_input(_delta):
	# ----------------------------------
	# Walking
	var cam_xform : Transform = camera.get_global_transform()
	var input_movement_vector := Vector2()

	direction = Vector3.ZERO

	if Input.is_action_pressed("ui_up"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("ui_down"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("ui_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()

	# Basis vectors are already normalized.
	direction += -cam_xform.basis.z * input_movement_vector.y
	direction += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_SPEED
	# ----------------------------------

	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------


func process_movement(delta):
	direction.y = 0
	direction = direction.normalized()

	velocity.y += delta * GRAVITY

	var hvel := velocity
	hvel.y = 0

	var target := direction
	target *= MAX_SPEED

	var acceleration : float = ACCELERATION
	if direction.dot(hvel) <= 0:
		acceleration = FRICTION

	hvel = hvel.linear_interpolate(target, acceleration * delta)
	velocity.x = hvel.x
	velocity.z = hvel.z
	velocity = move_and_slide(velocity, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))


func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot : Vector3 = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
