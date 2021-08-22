extends Spatial

const crate = preload("res://Objects/Crate.tscn")
const crateExplode = preload("res://Objects/CrateExplode.tscn")
const optionCrate = preload("res://Objects/OptionCrate.tscn")

export(float) var SLOW_SPAWN_RATE = 2.5
export(float) var FAST_SPAWN_RATE = 1.0
export(float) var CONVEYOR_SPEED = 2.0

var playerStats = Utils.get_player_stats()
var started = false
var start_crate : Crate = null
var option_crate : OptionCrate = null
var spawn_rate : float = SLOW_SPAWN_RATE

onready var spawn = $Conveyor/Spawn
onready var timer = $Conveyor/Timer
onready var conveyor = $Conveyor
onready var conveyorSound = $Conveyor/ConveyorSound
onready var startCrateSpawn = $StartCrateSpawn
onready var startCrateRespawnTimer = $StartCrateRespawnTimer
onready var infoScreen = $InfoScreen
onready var optionCrateSpawn = $OptionCrateSpawn


func _ready():
    SaveAndLoad.load_game()
    playerStats.high_score = SaveAndLoad.custom_data.high_score

    Music.play("Game")
    Utils.initialize_vr()
    spawn_start_crate()
    spawn_option_crate()

    # warning-ignore:return_value_discarded
    Events.connect("global_toggle_faster", self, "_on_Events_global_toggle_faster")
    # warning-ignore:return_value_discarded
    Events.connect("global_toggle_train", self, "_on_Events_global_toggle_train")


func spawn_option_crate():
    var instance : CPUParticles = Utils.instance_scene_on_main(crateExplode, optionCrateSpawn.global_transform)
    instance.emitting = true

    option_crate = Utils.instance_scene_on_main(optionCrate, optionCrateSpawn.global_transform)


func spawn_start_crate():
    var instance : CPUParticles = Utils.instance_scene_on_main(crateExplode, startCrateSpawn.global_transform)
    instance.emitting = true

    start_crate = Utils.instance_scene_on_main(crate, startCrateSpawn.global_transform)
    # warning-ignore:return_value_discarded
    start_crate.connect("tree_exited", self, "_on_StartCrate_tree_exiting")
    # warning-ignore:return_value_discarded
    start_crate.connect("button_pressed", self, "_on_StartCrate_button_pressed")


func _on_Timer_timeout():
    var instance : Crate = Utils.instance_scene_on_main(crate, spawn.global_transform)
    instance.apply_central_impulse(Vector3(5, 0, 0))
    instance.random_rotation()
    timer.start(spawn_rate)


func _on_StartCrate_button_pressed():
    started = true
    infoScreen.toggle()
    conveyor.constant_linear_velocity = Vector3(CONVEYOR_SPEED, 0, 0)
    conveyorSound.play()
    timer.start(spawn_rate)


func _on_StartCrate_tree_exiting():
    if not started:
        spawn_start_crate()


func _on_StartCrateSafeArea_body_exited(body : RigidBody):
    if body and body.is_in_group("Crate"):
        startCrateRespawnTimer.start()
        start_crate = body


func _on_StartCrateRespawnTimer_timeout():
    if started:
        return
    if start_crate:
        start_crate.queue_free()
        start_crate = null


func _on_Events_global_toggle_faster():
    if spawn_rate == SLOW_SPAWN_RATE:
        spawn_rate = FAST_SPAWN_RATE
    else:
        spawn_rate = SLOW_SPAWN_RATE


func _on_Events_global_toggle_train():
    pass
