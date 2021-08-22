extends RigidBody
class_name Crate

const crateExplode = preload("res://Objects/CrateExplode.tscn")

signal button_pressed()

# warning-ignore:unused_class_variable
export(int) var POINTS = 1
export(Color) var PRESSED_COLOR = Color.greenyellow

var playerStats = Utils.get_player_stats()
var button_pressed = false

onready var button = $Button
onready var timer = $Timer


func random_rotation():
    # First decide if we're going to lay it on it's side or flip it upside down
    var rotate_amnt : float = 180.0
    var r : float = randf()
    if r < 0.5:
        rotate_amnt = 90.0
    rotate(Vector3(1, 0, 0), deg2rad(rotate_amnt))

    # Then decide how much to rotate it around the Y
    rotate_amnt = rand_range(0.0, 360.0)
    rotate(Vector3(0, 1, 0), deg2rad(rotate_amnt))
    SoundFx.play_3d("BoxSpawn", global_transform.origin)


func delete_crate():
    var particles : CPUParticles = Utils.instance_scene_on_main(crateExplode, global_transform)
    particles.emitting = true

    var packed_scene : PackedScene = Utils.get_random_kenney_asset()

    # warning-ignore:return_value_discarded
    Utils.instance_scene_on_main(packed_scene, global_transform)

    queue_free()


func _on_ButtonPressArea_body_entered(_body):
    if button_pressed:
        return
    playerStats.add_total_score(POINTS)
    button_pressed = true

    SoundFx.play_3d("ButtonPress", global_transform.origin)
    var mesh : ArrayMesh = button.mesh
    var mat : SpatialMaterial = SpatialMaterial.new()
    mat.albedo_color = PRESSED_COLOR
    mesh.surface_set_material(1, mat)
    emit_signal("button_pressed")
    timer.start()


func _on_Timer_timeout():
    delete_crate()


func _on_VisibilityNotifier_screen_exited():
    queue_free()
