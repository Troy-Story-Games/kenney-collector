extends XRController3D
class_name VRController

var controller_velocity := Vector3.ZERO
var prior_controller_position := Vector3.ZERO
var prior_controller_velocities := []
var vr_camera : XRCamera3D = null
var hand_model : Hand = null
var which_hand = PlayerStats.WhichHand.NONE


func _ready():
	vr_camera = get_parent().find_child("*Camera3D")

	# Crash if we don't have the required nodes
	assert(vr_camera != null, "Could not find Camera3D!")


func _physics_process(delta):
	update_velocity(delta)


func set_hand_model(hand_scene):
	# This needs to be set before the model at least one time
	assert(which_hand != PlayerStats.WhichHand.NONE, "which_hand is not set to anything!")

	if hand_model:
		hand_model.queue_free()

	if hand_scene is PackedScene:
		hand_model = hand_scene.instantiate()
	elif hand_scene is String:
		# warning-ignore:unsafe_method_access
		hand_model = load(hand_scene).instantiate()
	elif hand_scene is Hand:
		hand_model = hand_scene
	else:
		# This would be a bug.
		assert(false, "ERROR: Unsupported type in set_hand_model")

	add_child(hand_model)


func set_which_hand(whand):
	assert(whand != PlayerStats.WhichHand.NONE, "which_hand is not set to anything!")
	which_hand = whand


func empty_hand_model():
	# Set to the default hand model
	match which_hand:
		PlayerStats.WhichHand.LEFT:
			set_hand_model("res://Player/Hands/LeftHand.tscn")
		PlayerStats.WhichHand.RIGHT:
			set_hand_model("res://Player/Hands/RightHand.tscn")


func rumble_for(time : float, intensity : float = 0.5):
	trigger_haptic_pulse("haptic_output", 1.0, intensity, time, 0)


func update_velocity(delta):
	# Reset the controller velocity
	controller_velocity = Vector3.ZERO

	if prior_controller_velocities.size() > 0:
		for vel in prior_controller_velocities:
			controller_velocity += vel

		# Get the average velocity, instead of just adding them together.
		controller_velocity = controller_velocity / prior_controller_velocities.size()

	# Add the most recent controller velocity to the list of proper controller velocities
	prior_controller_velocities.append((global_transform.origin - prior_controller_position) / delta)

	# Calculate the velocity using the controller's prior position.
	controller_velocity += (global_transform.origin - prior_controller_position) / delta
	prior_controller_position = global_transform.origin

	# If we have more than a third of a seconds worth of velocities, then we
	# should remove the oldest
	if prior_controller_velocities.size() > 30:
		prior_controller_velocities.pop_front()


func _on_VRInputParser_trigger_pressed():
	if hand_model:
		hand_model.trigger_action()


func _on_VRInputParser_trigger_released():
	if hand_model:
		hand_model.trigger_released_action()


func _on_VRInputParser_grip_pressed():
	if hand_model:
		hand_model.grip_action()


func _on_button_pressed(name):
	if name == "grip":
		_on_VRInputParser_grip_pressed()
	elif name == "trigger":
		_on_VRInputParser_trigger_pressed()


func _on_button_released(name):
	if name == "trigger":
		_on_VRInputParser_trigger_released()
