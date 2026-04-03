class_name GenericMazeEntity extends CharacterBody2D

@export var tilemap: TileMapLayer
@export var move_speed: float = 90.0

var current_cell: Vector2i
var target_position: Vector2
var moving := false
var last_dir: Vector2i = Vector2i.ZERO
var spawn_tile = Vector2i(-1,-1)

const DIRS: Dictionary[Vector2i, String] = {
	Vector2i.UP: "N",
	Vector2i.DOWN: "S",
	Vector2i.LEFT: "W",
	Vector2i.RIGHT: "E"
}

func _ready():
	#NOTE: this line is to prevent insta-crash.
	if get_parent() is Mazery or get_parent() is enemyHandler:
		print("I am waiting")
		spawn_tile = await get_parent().spawn_enemies
		print("done waiting")
		print("My spawn tile:", spawn_tile)
		current_cell = spawn_tile
		target_position = tilemap.map_to_local(current_cell)
		global_position = tilemap.map_to_local(current_cell)
	else:
		print("unable to act...")
		process_mode = Node.PROCESS_MODE_DISABLED

func _physics_process(_delta):

	if moving:
		var dir = (target_position - global_position).normalized()
		velocity = dir * move_speed
		move_and_slide()

		_play_animation(last_dir)

		# Snap to tile
		if global_position.distance_to(target_position) < 2:
			global_position = target_position
			moving = false
	else:
		velocity = Vector2.ZERO
		_play_animation(Vector2i.ZERO)

func move_in_direction(dir: Vector2i) -> bool:

	if moving:
		return false

	var valid_dirs = _get_available_dirs()

	if dir not in valid_dirs:
		return false

	last_dir = dir
	current_cell += dir
	target_position = tilemap.map_to_local(current_cell)
	moving = true

	return true

func get_available_dirs() -> Array[Vector2i]:
	return _get_available_dirs()

func is_moving() -> bool:
	return moving

# Internal
func _get_available_dirs() -> Array[Vector2i]:
	var results: Array[Vector2i] = []
	var tile_data := tilemap.get_cell_tile_data(current_cell)

	if tile_data == null:
		return results

	for dir in DIRS.keys():
		var key := DIRS[dir]
		if tile_data.get_custom_data(key):
			results.append(dir)

	return results

func _play_animation(dir: Vector2i):
	var anim := $AnimatedSprite2D

	if dir == Vector2i.UP:
		anim.play("up")
	elif dir == Vector2i.DOWN:
		anim.play("down")
	elif dir == Vector2i.LEFT:
		anim.play("left")
	elif dir == Vector2i.RIGHT:
		anim.play("right")
