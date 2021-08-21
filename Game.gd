extends Spatial

const crate = preload("res://Crate.tscn")

onready var spawn = $Spawn


func _ready():
    Music.play("Menu")
    Utils.initialize_vr()


func _on_Timer_timeout():
    # warning-ignore:return_value_discarded
    Utils.instance_scene_on_main(crate, spawn.global_transform)
