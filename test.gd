extends Node2D

@onready var camera_2d: Camera2D = $Camera2D

var time : float = 0.0

func _process(delta: float) -> void:
	time += delta
#	camera_2d.zoom = Vector2.ONE * (1.01 + sin(time)) * 2
