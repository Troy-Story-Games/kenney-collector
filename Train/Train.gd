extends Spatial

const trainExplosion = preload("res://Train/TrainExplosion.tscn")

export(float) var ACCELERATION = 1.0
export(float) var BREAKING = 5.0
export(float) var MAX_SPEED = 10.0

var on := false
var speed := 0.0
var direction := Vector3(0, 0, -1)
var velocity := Vector3.ZERO

onready var fullTrain = $FullTrain
onready var newTrainSpawn = $NewTrainSpawn
onready var storageCollision = $FullTrain/Storage/CollisionShape
onready var storage2Collision = $FullTrain/Storage2/CollisionShape


func toggle():
    on = !on
    if on:
        SoundFx.play_3d("TrainSound", fullTrain.global_transform.origin, 0.75, 6.0)


func _physics_process(delta):
    if not on:
        if speed > 0.0:
            speed = clamp(speed - (BREAKING * delta), 0.0, MAX_SPEED)
        else:
            return
    else:
        speed = clamp(speed + (ACCELERATION * delta), 0.0, MAX_SPEED)

    velocity = direction * (speed * delta)
    fullTrain.translate(velocity)


func _on_Area_body_entered(_body):
    fullTrain.global_transform.origin.z = newTrainSpawn.global_transform.origin.z
    storageCollision.disabled = true
    storage2Collision.disabled = true


func _on_StartArea_body_entered(_body):
    storageCollision.disabled = false
    storage2Collision.disabled = false
    if on:
        on = false
        SoundFx.play_3d("TrainSound", fullTrain.global_transform.origin, 0.75, 6.0)
        Events.emit_signal("global_train_at_station")
