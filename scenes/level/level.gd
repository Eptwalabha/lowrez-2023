extends Node3D

@onready var pivot: Node3D = $Pivot
@onready var player: Node3D = $Pivot/player
@onready var cloth: Node3D = $cloth
@onready var particles: CPUParticles3D = $CPUParticles3D

const SPEED : float = 40.0
const ROTATION_SPEED : float = 3.0
const MOVEMENT_SPEED : float = 5.0
const RESET_CLOTH_POSITION : float = -30.0
const CELL_SIZE : float = 3.0

var player_pos : Vector2i = Vector2(0, 1)
var player_dir : Vector2i = Vector2(0, -1)
var can_move : bool = true
var next_move : Vector2i = Vector2i.ZERO

func _ready() -> void:
	player.position = Vector3(player_pos.x, 0, player_pos.y) * CELL_SIZE
	cloth.position.y = RESET_CLOTH_POSITION
	for segment in $Segments.get_children():
		if segment is Segment:
			segment.speed = SPEED
			segment.end_of_line.connect(_on_segment_reached_end_of_line.bind(segment))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move-down"):
		move_player(0, 1)
	if event.is_action_pressed("move-up"):
		move_player(0, -1)
	if event.is_action_pressed("move-left"):
		move_player(-1, 0)
	if event.is_action_pressed("move-right"):
		move_player(1, 0)

func move_player(x: int, y: int) -> void:
	if not can_move:
		next_move = Vector2i(x, y)
		return
	do_move(x, y)

func do_move(x: int, y: int) -> void:
	var new_player_pos : Vector2i = Vector2i.ZERO
	new_player_pos.y = clampi(player_pos.y + y, -1, 1)
	new_player_pos.x = clampi(player_pos.x + x, -1, 1)
	if new_player_pos != player_pos:
		can_move = false
		player_pos = new_player_pos
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(player, "rotation:y", direction(x, y), 0.1)
		player_dir = Vector2i(x, y)
		tween.tween_property(player, "position", cell_position(player_pos), 0.2)
		tween.finished.connect(_player_move_over, CONNECT_ONE_SHOT)

func cell_position(pos: Vector2i) -> Vector3:
	return Vector3(pos.x * CELL_SIZE, 0.0, pos.y * CELL_SIZE)

func direction(x: int, y: int) -> float:
	return player.rotation.y + Vector2(x, y).angle_to(player_dir)

func _on_segment_reached_end_of_line(segment : Segment) -> void:
	segment.position.y -= 120.0

func _on_cloth_behind_camera() -> void:
	cloth.position.y -= RESET_CLOTH_POSITION + randi() % 100

func _on_player_cloth_caugth(caught_cloth) -> void:
	caught_cloth.position = cell_position(Vector2i(randi() % 3 - 1, randi() % 3 - 1))
	caught_cloth.position.y -= RESET_CLOTH_POSITION + randi() % 100
	particles.global_position = player.global_position
	particles.emitting = true

func _player_move_over() -> void:
	can_move = true
	if next_move != Vector2i.ZERO:
		do_move(next_move.x, next_move.y)
		next_move = Vector2i.ZERO
