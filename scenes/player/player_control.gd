extends Node3D

@onready var top: CSGMesh3D = $Top
@onready var right: CSGMesh3D = $Right
@onready var bottom: CSGMesh3D = $Bottom
@onready var left: CSGMesh3D = $Left

func _ready() -> void:
	top.mesh.size = Vector2.ONE * 1.3
