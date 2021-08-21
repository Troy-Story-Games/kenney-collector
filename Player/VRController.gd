extends ARVRController
class_name VRController

var controller_velocity := Vector3.ZERO
var prior_controller_position := Vector3.ZERO
var prior_controller_velocities := []
var vr_camera : ARVRCamera = null
var hand_model : Hand = null
var which_hand = PlayerStats.WhichHand.NONE

onready var input = $VRInputParser
onready var rumbleTimer = $RumbleTimer


func _ready():
    # Never leave them rumbling
    rumble = 0.0

    vr_camera = get_parent().find_node("*Camera")

    # Crash if we don't have the required nodes
    assert(vr_camera != null)


func _physics_process(delta):
    if not input.initialized:
        return

    update_velocity(delta)


func set_hand_model(hand_scene):
    # This needs to be set before the model at least one time
    assert(which_hand != PlayerStats.WhichHand.NONE)

    if hand_model:
        hand_model.queue_free()

    if hand_scene is PackedScene:
        hand_model = hand_scene.instance()
    elif hand_scene is String:
        # warning-ignore:unsafe_method_access
        hand_model = load(hand_scene).instance()
    elif hand_scene is Hand:
        hand_model = hand_scene
    else:
        print("ERROR: Unsupported type in set_hand_model")
        assert(false)  # This would be a bug.

    add_child(hand_model)


func set_which_hand(whand):
    assert(whand != PlayerStats.WhichHand.NONE)  # This would be a bug
    which_hand = whand


func empty_hand_model():
    # Set to the default hand model
    match which_hand:
        PlayerStats.WhichHand.LEFT:
            set_hand_model("res://Player/Hands/LeftHand.tscn")
        PlayerStats.WhichHand.RIGHT:
            set_hand_model("res://Player/Hands/RightHand.tscn")


func rumble_for(time : float, intensity : float = 0.5):
    rumble = clamp(rumble + intensity, 0.0, 1.0)
    rumbleTimer.start(time)


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


func _on_VRInputParser_trigger_pressed():
    if hand_model:
        hand_model.trigger_action()


func _on_VRInputParser_trigger_released():
    if hand_model:
        hand_model.trigger_released_action()


func _on_VRInputParser_grip_pressed():
    if hand_model:
        hand_model.grip_action()


func _on_RumbleTimer_timeout():
    rumble = 0.0
