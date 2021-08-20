extends ARVRController
class_name VRController

const LeftHand = preload("res://VRPlayer/LeftHand.tscn")
const RightHand = preload("res://VRPlayer/RightHand.tscn")
const Projectile = preload("res://Projectile.tscn")  # Demo code

enum Hand {
	LEFT,
	RIGHT
}
enum MovementMode {
	NONE,
	DIRECTIONAL,
	TELEPORT
}

# Using a really large dead zone. This is because we do not want to move
# the player if they barely bump the trackpad/joystick.
export(float) var CONTROLLER_DEADZONE = 0.65
# The speed the player moves at when moving using the trackpad and/or joystick.
export(float) var MOVEMENT_SPEED = 1.5
# If we can't auto-determine which hand this is, fallback to this value.
# When setting up a VR player with two controllers, one should be set to
# LEFT and the other set to RIGHT
export(Hand) var FALLBACK_HAND = Hand.LEFT
# Whether or not to enable track-pad (non-telport) based VR movement
export(MovementMode) var MOVEMENT_MODE = MovementMode.TELEPORT

# The velocity the controller is moving at (calculated using physics frames)
var controller_velocity := Vector3.ZERO
# The controller's previous position (used to calculate velocity)
var prior_controller_position := Vector3.ZERO
# The last 30 calculated velocities (1/3 of a second worth of velocity
# calculations, assuming the game is running at 90 FPS)
var prior_controller_velocities := []

# The currently held object, if there is one
var held_object : RigidBody = null
# The RigidBody data of the currently held object, used to 
# reset the object when no longer holding it.
var held_object_data := {
	"mode": RigidBody.MODE_RIGID,
	"layer": 1,
	"mask": 1
}

# The position the teleport raycast is aimed at, the mesh used to represent the teleport
# position, the teleport 'laser sight' finger mesh, a variable to track whether the teleport
# button is down, and the teleport raycast.
var teleport_pos = null
var teleport_mesh : MeshInstance = null
var teleport_button_down := false

# A boolean to track whether the player is moving using the controller.
# This can be used externally to check if the player is moving via the
# touch pad/joystick - Can be used to display some sort of visual indicator
var directional_movement := false

# Whether or not the controller has been initialized yet
var initialized := false

# The hand mesh instance for this controller (e.g. left or right hand)
var hand_mesh : MeshInstance = null
# The VR camera node
var vr_camera : ARVRCamera = null

onready var grabPos = $GrabPos
onready var grabArea = $GrabArea
onready var teleportRayCast = $TeleportRayCast


func _ready():
	# Get the teleport mesh
	teleport_mesh = get_tree().root.find_node("*TeleportMesh*", true, false)
	# Get the VR Camera
	vr_camera = get_parent().find_node("*Camera")

	# Crash if we don't have the required nodes
	assert(teleport_mesh != null)
	assert(vr_camera != null)


func init_controller():
	var controller_name := get_controller_name()
	if controller_name:
		print("DEBUG: Controller name: ", controller_name)

	# See if we know which hand this is automatically
	var detected_hand := get_hand()
	match detected_hand:
		ARVRPositionalTracker.TRACKER_LEFT_HAND:
			print("DEBUG: Controller ", controller_id, " is left hand")
			instance_hand_mesh(Hand.LEFT)
		ARVRPositionalTracker.TRACKER_RIGHT_HAND:
			print("DEBUG: Controller ", controller_id, " is right hand")
			instance_hand_mesh(Hand.RIGHT)
		ARVRPositionalTracker.TRACKER_HAND_UNKNOWN:
			print("DEBUG: Controller ", controller_id, " hand is unknown")
			instance_hand_mesh(FALLBACK_HAND)

	teleportRayCast.rotation = hand_mesh.rotation
	teleportRayCast.rotation.x -= deg2rad(90.0)


func _physics_process(delta):
	# Update the teleportation mesh and position IF the teleport button is down
	if teleport_button_down:
		update_teleport_raycast()

	# Update the velocity if the controller is moving
	if get_is_active():
		if not initialized:
			initialized = true
			init_controller()
		update_velocity(delta)

	# Update the held object's position
	if held_object != null:
		var held_scale : Vector3 = held_object.scale
		held_object.global_transform = grabPos.global_transform
		held_object.scale = held_scale

	# Process VR controller track-pad-based movement
	if MOVEMENT_MODE == MovementMode.DIRECTIONAL:
		process_directional_movement(delta)


func instance_hand_mesh(hand):
	var instance : MeshInstance = null
	match hand:
		Hand.LEFT:
			instance = LeftHand.instance()
		Hand.RIGHT:
			instance = RightHand.instance()
	add_child(instance)
	hand_mesh = instance


func update_teleport_raycast():
	teleportRayCast.force_raycast_update()
	if teleportRayCast.is_colliding():
		# Make sure the normal is approx. straight up and down
		if teleportRayCast.get_collision_normal().y >= 0.85:
			# Set teleport_pos to the raycast point and move the teleport mesh.
			teleport_pos = teleportRayCast.get_collision_point()
			teleport_mesh.global_transform.origin = teleport_pos


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
		prior_controller_velocities.remove(0)


func process_directional_movement(delta):
	# TODO: May need to change this depending on which VR controllers
	# are being used and which OS you are on.
	var trackpad_vector := Vector2(-get_joystick_axis(1), get_joystick_axis(0))
	var joystick_vector := Vector2(-get_joystick_axis(5), get_joystick_axis(4))

	# Account for dead zones on the trackpad
	if trackpad_vector.length() < CONTROLLER_DEADZONE:
		trackpad_vector = Vector2.ZERO
	else:
		trackpad_vector = trackpad_vector.normalized() * ((trackpad_vector.length() - CONTROLLER_DEADZONE) / (1 - CONTROLLER_DEADZONE))

	# Account for dead zones on the the joystick
	if joystick_vector.length() < CONTROLLER_DEADZONE:
		joystick_vector = Vector2.ZERO
	else:
		joystick_vector = joystick_vector.normalized() * ((joystick_vector.length() - CONTROLLER_DEADZONE) / (1 - CONTROLLER_DEADZONE))
	
	# Get the VR camera's forward and right directional/local-space vectors
	var forward_direction = vr_camera.global_transform.basis.z.normalized()
	var right_direction = vr_camera.global_transform.basis.x.normalized()
	
	# Calculate how much we will move by adding both the trackpad and the joystick vectors together
	# and normalizing them.
	var movement_vector = (trackpad_vector + joystick_vector).normalized()
	
	# Calculate how far we will move forward/backwards and right/left, using the camera's directional/local-space vectors.
	var movement_forward = forward_direction * movement_vector.x * delta * MOVEMENT_SPEED
	var movement_right = right_direction * movement_vector.y * delta * MOVEMENT_SPEED
	
	# Remove movement on the Y axis so the player cannot fly/fall by moving
	movement_forward.y = 0
	movement_right.y = 0
	
	# Move the player if there is any movement forward/backwards or right/left.
	if (movement_right.length() > 0 or movement_forward.length() > 0):
		var player : ARVROrigin = get_parent()
		player.translate(movement_right + movement_forward)
		directional_movement = true
	else:
		directional_movement = false


func _on_SleepArea_body_entered(body):
	if "can_sleep" in body:
		body.can_sleep = false
		body.sleeping = false


func _on_SleepArea_body_exited(body):
	# When a body exits, check if it has can_sleep. If it has can_sleep, then make sure it can sleep again
	# to save on performance.
	if "can_sleep" in body:
		body.can_sleep = true


func _on_VRController_button_pressed(button):
	# If the trigger is pressed...
	if button == 15:
		if held_object != null:
			if held_object.has_method("interact"):
				# warning-ignore:unsafe_method_access
				held_object.interact()
		elif MOVEMENT_MODE == MovementMode.TELEPORT:
			teleport_button_down = true
			teleport_mesh.visible = true
			teleportRayCast.visible = true
		else:
			# DEMO CODE - Fire a projectile
			var instance : RigidBody = Utils.instance_scene_on_main(Projectile, grabPos.global_transform)
			var direction = global_transform.basis.xform(Vector3.UP)
			instance.apply_central_impulse(direction * -500)

	# If the grab button is pressed...
	if button == 2:
		# Make sure we cannot pick up objects while trying to teleport.
		if teleport_button_down:
			return

		# Pick up RigidBody if we are not holding a object
		if held_object == null:
			var rigid_body : RigidBody = null
			var bodies : Array = grabArea.get_overlapping_bodies()
			if len(bodies) > 0:
				# Check to see if there is a rigid body among the bodies inside the grab area.
				for body in bodies:
					if body is RigidBody:
						# Assuming there is no variable called NO_PICKUP in the RigidBody.
						# By adding a variable/constant called NO_PICKUP, you can make it where
						# the RigidBody cannot be picked up by the controller(s).
						if !("NO_PICKUP" in body):
							rigid_body = body
							break

			if rigid_body != null:
				# Assign held object to it.
				held_object = rigid_body
				
				# Store the now held RigidBody's information.
				held_object_data["mode"] = held_object.mode
				held_object_data["layer"] = held_object.collision_layer
				held_object_data["mask"] = held_object.collision_mask

				# Set it so it cannot collide with anything.
				held_object.mode = RigidBody.MODE_STATIC
				held_object.collision_layer = 0
				held_object.collision_mask = 0

				# Make the hand mesh invisible.
				if hand_mesh != null:
					hand_mesh.visible = false

				# If the RigidBody has a function called picked_up, then call it.
				if held_object.has_method("picked_up"):
					# warning-ignore:unsafe_method_access
					held_object.picked_up()

				# If the RigidBody has a variable called controller, then assign it to this controller.
				if "controller" in held_object:
					held_object.controller = self
		else:
			# Set the held object's RigidBody data back to what is stored.
			held_object.mode = held_object_data["mode"]
			held_object.collision_layer = held_object_data["layer"]
			held_object.collision_mask = held_object_data["mask"]

			# Apply a impulse in the direction of the controller's velocity.
			held_object.apply_impulse(Vector3.ZERO, controller_velocity)

			# If the RigidBody has a function called dropped, then call it.
			if held_object.has_method("dropped"):
				# warning-ignore:unsafe_method_access
				held_object.dropped()

			# If the RigidBody has a variable called controller, then set it to null
			if "controller" in held_object:
				held_object.controller = null

			# Set held_object to null since this controller is no longer holding anything.
			held_object = null

			if hand_mesh != null:
				# Make the hand mesh visible.
				hand_mesh.visible = true


func _on_VRController_button_release(button):
	# If the trigger button is released...
	if button == 15:
		# Make sure we are trying to teleport.
		if teleport_button_down:
			# If we have a teleport position, and the teleport mesh is visible, then teleport the player.
			if teleport_pos != null and teleport_mesh.visible:
				# Because of how ARVR origin works, we need to figure out where the player is in relation to the ARVR origin.
				# This is so we can teleport the player at their current position in VR to the teleport position
				var camera_offset = vr_camera.global_transform.origin - get_parent().global_transform.origin
				# We do not want to account for offsets in the player's height.
				camera_offset.y = 0

				# Teleport the ARVR origin to the teleport position, applying the camera offset.
				get_parent().global_transform.origin = teleport_pos - camera_offset

			# Reset the teleport related variables.
			teleport_button_down = false
			teleport_mesh.visible = false
			teleportRayCast.visible = false
			teleport_pos = null
