extends Node3D

@onready var pivot: Node3D = $Pivot
@onready var player: Node3D = %player
@onready var cloth: Node3D = $building/cloth
@onready var particles: CPUParticles3D = $CPUParticles3D
@onready var blocks: Node3D = $building/blocks
@onready var camera_3d: Camera3D = %camera

var BLOCK = preload("res://scenes/level/block/block_item.tscn")

const SPEED : float = 20.0
const ROTATION_SPEED : float = 3.0
const MOVEMENT_SPEED : float = 5.0
const RESET_CLOTH_POSITION : float = 30.0
const GRID_WIDTH : int = 5
const LOWEST_LEVEL : int = 10

var player_pos : Vector2i = Vector2(0, 1)
var player_dir : Vector2i = Vector2(0, -1)
var can_move : bool = true
var next_move : Vector2i = Vector2i.ZERO

var level : int = 0
var cube : Dictionary = {}

func _ready() -> void:
	player.position = Vector3(player_pos.x, 0, player_pos.y) * GameData.cell_size
	cloth.position.y = RESET_CLOTH_POSITION
	reset_level()

func reset_level() -> void:
	var x : float = GameData.cell_size * GRID_WIDTH
	$building/wall1.position.z = -GameData.cell_size / 2.0
	$building/wall2.position.z = -GameData.cell_size / 2.0 + x
	var id = random_cell_id()
	player_pos = cell_id_to_vector2(id)
	player.position = cell_position(player_pos)
	camera_3d.position = player.position
	camera_3d.position.y = (x + .5) / (2 * sin(PI / 2.0))
	cube = {}
	for i in range(LOWEST_LEVEL):
		cube[i] = []
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

	cube[level] = []
	for i in range(randi() % 3 + 1):
		var b = BLOCK.instantiate()
		blocks.add_child(b)
		b.set_color(level)
		var p2 = cell_id_to_vector2(random_cell_id())
		var p3 = cell_position(p2)
		p3.y = -(LOWEST_LEVEL - 1) * GameData.cell_size
		b.position = p3
		cube[level].push_back(p2)

	tween.tween_property(material, "uv1_offset:y", -level * 0.125 - .1, GameData.TICK_COOLDOWN)

func move_player(x: int, y: int) -> void:
	if not can_move:
		next_move = Vector2i(x, y)
		return
	do_move(x, y)

func zone_clamp(vector: Vector2i) -> Vector2i:
	return vector.clamp(Vector2i.ZERO, Vector2i(GRID_WIDTH - 1, GRID_WIDTH - 1))

func new_position_allowed(pos: Vector2i) -> bool:
	var key : int = level - LOWEST_LEVEL + 1
	if cube.has(key):
		for i in cube[key]:
			if i == pos:
				return false
	return true

func do_move(x: int, y: int) -> void:
	var new_player_pos : Vector2i = zone_clamp(player_pos + Vector2i(x, y))
	if new_player_pos != player_pos and new_position_allowed(new_player_pos):
		level += 1
		move_level_up()
		can_move = false
		player_pos = new_player_pos
		var tween : Tween = create_tween()
		tween.tween_property(player, "rotation:y", direction(x, y), GameData.TICK_COOLDOWN / 2.0)
		player_dir = Vector2i(x, y)
		var pp1 = cell_position(player_pos)
		var pp2 = pp1
		pp2.y = camera_3d.position.y
		tween.parallel().tween_property(player, "position", pp1, GameData.TICK_COOLDOWN)
		tween.parallel().tween_property(camera_3d, "position", pp2, GameData.TICK_COOLDOWN)
		tween.finished.connect(_player_move_over, CONNECT_ONE_SHOT)

func cell_id_to_vector2(id: int) -> Vector2i:
	return Vector2i(id % GRID_WIDTH, id / GRID_WIDTH)

func cell_pos_to_id(pos: Vector2i) -> int:
	return pos.x + pos.y * GRID_WIDTH

func cell_position(pos: Vector2i) -> Vector3:
	return Vector3(pos.x * GameData.cell_size, 0.0, pos.y * GameData.cell_size)

func random_cell_id() -> int:
	return randi() % (GRID_WIDTH * GRID_WIDTH)

func random_cell_position(height: float) -> Vector3:
	var l : Array = range(0, GRID_WIDTH)
	print(l)
	var p : Vector3 = cell_position(Vector2i(l.pick_random(), l.pick_random()))
	p.y = height
	return p

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
