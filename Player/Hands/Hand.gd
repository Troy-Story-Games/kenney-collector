extends KinematicBody
class_name Hand

# Base Player hand scene - All hands should inherit from this and
# populate with whatever child nodes are required. This script
# defines the base methods that all Hand type objects must implement

var controller = null
var held_object : RigidBody = null

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
            if body is RigidBody:
                held_object = body
                break

    if not held_object:
        return

    # Store the old mode for later and set it to static so we can move it
    held_object.mode = RigidBody.MODE_STATIC

    # This makes it so you can pickup the object and it doesn't just snap
    # to the center of your controller. (e.g. the pickup of the object
    # is at the collision point)
    grabPos.global_transform = held_object.global_transform


func trigger_released_action():
    # Drop the held object
    if not held_object:
        return

    held_object.mode = RigidBody.MODE_RIGID
    grabPos.translation = Vector3.ZERO
    held_object.apply_impulse(Vector3(0, 0, 0), controller.controller_velocity)
    held_object = null


func grip_action():
    # This is called when the controller that has this hand applied
    # gets the grip_pressed signal
    pass  # Default implementation does nothing.
