extends Spatial

const crate = preload("res://Objects/Crate.tscn")

export(float) var CONVEYOR_SPEED = 2.0

onready var spawn = $Conveyor/Spawn
onready var timer = $Conveyor/Timer
onready var conveyor = $Conveyor


func _ready():
    Music.play("Menu")
    Utils.initialize_vr()


func _on_Timer_timeout():
    var instance : Crate = Utils.instance_scene_on_main(crate, spawn.global_transform)
    instance.apply_central_impulse(Vector3(5, 0, 0))
    instance.random_rotation()
    timer.start()


func _on_StartCrate_button_pressed():
    conveyor.constant_linear_velocity = Vector3(CONVEYOR_SPEED, 0, 0)
    timer.start()

