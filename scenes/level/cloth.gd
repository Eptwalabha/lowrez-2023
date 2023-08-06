class_name Cloth
extends Node3D

signal behind_camera

@export var speed : float = 5.0

func _process(delta: float) -> void:
	position.y += delta * speed * GameData.speed
	if position.y > 10.0:
		emit_signal("behind_camera")
