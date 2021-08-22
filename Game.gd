extends Spatial

const crate = preload("res://Crate.tscn")

onready var spawn = $Conveyor/Spawn


func _ready():
	Music.play("Menu")
	Utils.initialize_vr()


func _on_Timer_timeout():
	var instance : RigidBody = Utils.instance_scene_on_main(crate, spawn.global_transform)
	instance.apply_central_impulse(Vector3(5, 0, 0))
