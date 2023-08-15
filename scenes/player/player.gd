class_name Player
extends Node3D

signal cloth_caugth(cloth)

@onready var pivot: Node3D = $Pivot
@onready var sprite: Sprite3D = $Pivot/Sprite
@onready var area_3d = $Pivot/Area3D

var time : float = 0
var direction : Vector2i = Vector2i.UP

func _process(delta: float) -> void:
	time += delta
	sprite.rotation.y = sin(time * 3.0) * .2 + PI

func face(new_direction: Vector2i) -> void:
	var tween : Tween = create_tween()
	var angle = Vector2(direction).angle_to(new_direction)
	direction = new_direction
	tween.tween_property(pivot, "rotation:y", pivot.rotation.y - angle, GameData.TICK_COOLDOWN / 2.0)

func _on_area_3d_area_entered(area: Area3D) -> void:
	var cloth = area.owner
	if cloth is Cloth:
		emit_signal("cloth_caugth", cloth)
	elif cloth is Section:
		print("oups")

func can_move(new_direction: Vector2i) -> bool:
	match new_direction:
		Vector2i.UP: return not $Directions/RayUp.is_colliding()
		Vector2i.RIGHT: return not $Directions/RayRight.is_colliding()
		Vector2i.DOWN: return not $Directions/RayDown.is_colliding()
		Vector2i.LEFT: return not $Directions/RayLeft.is_colliding()
	return false
