extends RigidBody
class_name Crate


func _on_VisibilityNotifier_screen_exited():
    queue_free()
