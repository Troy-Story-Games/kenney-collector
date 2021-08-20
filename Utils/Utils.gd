extends Node

# Auto-load singleton with common utilities
# needed in most games


func instance_scene_on_main(packed_scene: PackedScene, position: Transform) -> Node:
	var main := get_tree().current_scene
	var instance : Spatial = packed_scene.instance()
	main.add_child(instance)
	instance.global_transform = position
	return instance


func get_player_stats() -> Resource:
	return ResourceLoader.load("res://Player/PlayerStats.tres")
