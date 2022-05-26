extends RigidBody
class_name BadCrate


func _on_VisibilityNotifier_screen_exited():
    queue_free()
