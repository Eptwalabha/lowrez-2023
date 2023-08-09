class_name BlockItem
extends Node3D

@onready var csg_mesh_3d: CSGMesh3D = $CSGMesh3D

var level : int = 0

func set_color(level: int) -> void:
	var h : float = float(level % 10) / 10.0
	csg_mesh_3d.mesh.material.albedo_color = Color.from_hsv(h, 1, 1)

func tick(new_level: int) -> void:
	if new_level != level:
		level = new_level
		var tween : Tween = create_tween()
		tween.tween_property(self, "position:y", position.y + GameData.cell_size, GameData.TICK_COOLDOWN)
		tween.finished.connect(_check_position_y, CONNECT_ONE_SHOT)

func _check_position_y() -> void:
	if global_position.y > 0:
		queue_free()
