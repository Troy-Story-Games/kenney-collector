extends ARVROrigin
class_name VRPlayer

const leftHandScene = preload("res://Player/Hands/LeftHand.tscn")
const rightHandScene = preload("res://Player/Hands/RightHand.tscn")

var mainInstances = Utils.get_main_instances()

onready var camera = $Camera
onready var leftController = $VRControllerA
onready var rightController = $VRControllerB


func _ready():
    mainInstances.player = self

    leftController.set_which_hand(PlayerStats.WhichHand.LEFT)
    leftController.set_hand_model(leftHandScene)

    rightController.set_which_hand(PlayerStats.WhichHand.RIGHT)
    rightController.set_hand_model(rightHandScene)


func get_headset_global_position():
    return camera.global_transform.origin
