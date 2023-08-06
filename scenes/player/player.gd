extends Node3D

signal cloth_caugth(cloth)

@onready var pivot: Node3D = $Pivot
@onready var sprite: Sprite3D = $Pivot/Sprite

var time : float = 0

func _process(delta: float) -> void:
	time += delta
	sprite.rotation.y = sin(time * 3.0) * .2 + PI

func _on_area_3d_area_entered(area: Area3D) -> void:
	var cloth = area.owner
	if cloth is Cloth:
		emit_signal("cloth_caugth", cloth)
