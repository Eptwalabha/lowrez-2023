class_name Segment
extends Node3D

signal end_of_line

@export var speed : float = 20.0

func _process(delta: float) -> void:
	position.y += delta * speed * GameData.speed
	if position.y > 10.0:
		emit_signal("end_of_line")
