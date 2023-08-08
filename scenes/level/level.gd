extends Node3D

@onready var pivot: Node3D = $Pivot
@onready var player: Node3D = $Pivot/player
@onready var cloth: Node3D = $building/cloth
@onready var particles: CPUParticles3D = $CPUParticles3D
@onready var blocks: Node3D = $building/blocks

var BLOCK = preload("res://scenes/level/block/block_item.tscn")

const SPEED : float = 20.0
const ROTATION_SPEED : float = 3.0
const MOVEMENT_SPEED : float = 5.0
const RESET_CLOTH_POSITION : float = 30.0

var player_pos : Vector2i = Vector2(0, 1)
var player_dir : Vector2i = Vector2(0, -1)
var can_move : bool = true
var next_move : Vector2i = Vector2i.ZERO

var level : int = 0

func _ready() -> void:
	player.position = Vector3(player_pos.x, 0, player_pos.y) * GameData.cell_size
	cloth.position.y = RESET_CLOTH_POSITION
	reset_level()

func reset_level() -> void:
	level = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move-down"):
		move_player(0, 1)
	if event.is_action_pressed("move-up"):
		move_player(0, -1)
	if event.is_action_pressed("move-left"):
		move_player(-1, 0)
	if event.is_action_pressed("move-right"):
		move_player(1, 0)

func move_level_up() -> void:
	var material : Material = $building/wall1.mesh.material
	var tween : Tween = create_tween()

	for block in blocks.get_children():
		if block is BlockItem:
			block.tick(level)

	for i in range(randi() % 3):
		var b = BLOCK.instantiate()
		blocks.add_child(b)
		b.position = random_cell_position(-10 * GameData.cell_size)
	tween.tween_property(material, "uv1_offset:y", -level * 0.25 - .1, GameData.TICK_COOLDOWN)

func move_player(x: int, y: int) -> void:
	if not can_move:
		next_move = Vector2i(x, y)
		return
	do_move(x, y)

func zone_clamp(vector: Vector2i) -> Vector2i:
	return vector.clamp(Vector2i(-1, -1), Vector2i(1, 1))

func do_move(x: int, y: int) -> void:
	var new_player_pos : Vector2i = zone_clamp(player_pos + Vector2i(x, y))
	if new_player_pos != player_pos:
		level += 1
		move_level_up()
		can_move = false
		player_pos = new_player_pos
		var tween : Tween = create_tween()
		tween.tween_property(player, "rotation:y", direction(x, y), GameData.TICK_COOLDOWN / 2.0)
		player_dir = Vector2i(x, y)
		tween.parallel().tween_property(player, "position", cell_position(player_pos), GameData.TICK_COOLDOWN)
		tween.finished.connect(_player_move_over, CONNECT_ONE_SHOT)

func random_cell_position(height: float) -> Vector3:
	var p : Vector3 = cell_position(Vector2i(randi() % 3 - 1, randi() % 3 - 1))
	p.y = height
	return p

func cell_position(pos: Vector2i) -> Vector3:
	return Vector3(pos.x * GameData.cell_size, 0.0, pos.y * GameData.cell_size)

func direction(x: int, y: int) -> float:
	return player.rotation.y + Vector2(x, y).angle_to(player_dir)

func _on_segment_reached_end_of_line(segment : Segment) -> void:
	segment.position.y -= 120.0

func _on_cloth_behind_camera() -> void:
	cloth.position.y -= RESET_CLOTH_POSITION + randi() % 100

func _on_player_cloth_caugth(caught_cloth) -> void:
	caught_cloth.position = random_cell_position(-RESET_CLOTH_POSITION + randi() % 100)
	particles.global_position = player.global_position
	particles.emitting = true

func _player_move_over() -> void:
	can_move = true
	if next_move != Vector2i.ZERO:
		do_move(next_move.x, next_move.y)
		next_move = Vector2i.ZERO
