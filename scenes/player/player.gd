class_name Player
extends Node3D

signal cloth_caugth(cloth)

@onready var pivot: Node3D = $Pivot
@onready var sprite: Sprite3D = $Pivot/Sprite
@onready var area_3d = $Pivot/Area3D

var time : float = 0
var direction : Vector2i = Vector2i.UP
var touching : int = 0
var touch_duration : float = 0.0

func _process(delta: float) -> void:
	time += delta
	sprite.rotation.y = sin(time * 3.0) * .2 + PI
	if touching > 0:
		touch_duration += delta
		print(touch_duration)
		if touch_duration > 0.1:
			hit()

func face(new_direction: Vector2i) -> void:
	var tween : Tween = create_tween()
	var angle = Vector2(direction).angle_to(new_direction)
	direction = new_direction
	tween.tween_property(pivot, "rotation:y", pivot.rotation.y - angle, GameData.TICK_COOLDOWN / 2.0)

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.owner is Cloth:
		emit_signal("cloth_caugth", area.owner)
	elif area is BlockItem:
		if touching == 0:
			touch_duration = 0.0
		touching += 1
		prints(touching, touch_duration)

func _on_area_3d_area_exited(area: Area3D) -> void:
	var item = area.owner
	if area is BlockItem:
		touching = max(touching - 1, 0)

func can_move(new_direction: Vector2i) -> bool:
	match new_direction:
		Vector2i.UP: return not $Directions/RayUp.is_colliding()
		Vector2i.RIGHT: return not $Directions/RayRight.is_colliding()
		Vector2i.DOWN: return not $Directions/RayDown.is_colliding()
		Vector2i.LEFT: return not $Directions/RayLeft.is_colliding()
	return false

func hit() -> void:
	touching = 0
	touch_duration = 0.0
	print("ouch!")
