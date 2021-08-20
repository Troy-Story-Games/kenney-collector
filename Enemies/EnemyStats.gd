extends Node
class_name BrickStats

signal brick_broken()
signal brick_health_changed(value)

export(int) var max_health = 1

onready var health : int = max_health setget set_health


func set_health(value : int):
	health = int(clamp(value, 0, max_health))
	emit_signal("brick_health_changed", health)
	if health == 0:
		emit_signal("brick_broken")
