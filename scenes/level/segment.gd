class_name Segment
extends Node3D

signal end_of_line

@export var speed : float = 20.0
@export_color_no_alpha var color : Color = Color.WHITE 

@onready var csg_mesh_3d: CSGMesh3D = $Pivot/CSGMesh3D

func _ready() -> void:
	csg_mesh_3d.material.albedo_color = color

func _process(delta: float) -> void:
	position.y += delta * speed * GameData.speed
	if position.y > 10.0:
		emit_signal("end_of_line")
