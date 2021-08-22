extends KinematicBody
class_name Hand

# Base Player hand scene - All hands should inherit from this and
# populate with whatever child nodes are required. This script
# defines the base methods that all Hand type objects must implement

var controller = null
var held_object = null

onready var grabArea = $GrabArea
onready var grabPos = $GrabPos


func _ready():
    controller = get_parent()


func _physics_process(_delta):
    # Update the held object's position
    if held_object != null:
        held_object.global_transform = grabPos.global_transform


func trigger_action():
    # Pickup an object
    if held_object:
        return

    var bodies : Array = grabArea.get_overlapping_bodies()
    if len(bodies) > 0:
        for body in bodies:
            if body is RigidBody or body is OptionCrate:
                held_object = body
                break

    if not held_object:
        return

    # warning-ignore:return_value_discarded
    held_object.connect("tree_exiting", self, "_on_held_object_tree_exiting")

    # This makes it so you can pickup the object and it doesn't just snap
    # to the center of your controller. (e.g. the pickup of the object
    # is at the collision point)
    grabPos.global_transform = held_object.global_transform

    if held_object is OptionCrate:
        held_object.holding = true
        return  # OptionCrate is a kinematic body - don't need to change its mode

    # Store the old mode for later and set it to static so we can move it
    held_object.mode = RigidBody.MODE_STATIC


func trigger_released_action():
    # Drop the held object
    if not held_object:
        return

    grabPos.translation = Vector3.ZERO

    if held_object is OptionCrate:
        held_object.holding = false
        held_object = null
        return

    held_object.mode = RigidBody.MODE_RIGID
    held_object.apply_impulse(Vector3(0, 0, 0), controller.controller_velocity)
    held_object = null


func grip_action():
    # This is called when the controller that has this hand applied
    # gets the grip_pressed signal
    pass  # Default implementation does nothing.


func _on_held_object_tree_exiting():
    held_object = null
