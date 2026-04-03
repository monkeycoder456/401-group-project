class_name BasicZombie
extends GenericMazeEntity

@export var player: CharacterBody2D
@export var move_delay := 0.0
@export var kill_distance := 16.0

var previous_cell := Vector2i(-1, -1)
var has_killed := false


func _ready():
	await super._ready()

	target_position = tilemap.map_to_local(current_cell)
	global_position = target_position

	randomize()
	_start_wander()


func _physics_process(delta):

	if moving:

		global_position = global_position.move_toward(
			target_position,
			move_speed * delta
		)

		if global_position.distance_to(target_position) < 1:
			global_position = target_position
			moving = false

			await get_tree().create_timer(move_delay).timeout

			_start_wander()

	_check_player_collision()


func _start_wander():

	var possible_dirs := _get_available_dirs()

	if possible_dirs.is_empty():
		return

	var dir: Vector2i

	if possible_dirs.size() == 2:
		if last_dir != Vector2i.ZERO and possible_dirs.has(last_dir):
			dir = last_dir
		else:
			dir = possible_dirs.pick_random()

	else:
		var filtered := possible_dirs.duplicate()

		if last_dir != Vector2i.ZERO:
			filtered.erase(-last_dir)

		if filtered.is_empty():
			filtered = possible_dirs

		dir = filtered.pick_random()

	last_dir = dir
	current_cell += dir

	target_position = tilemap.map_to_local(current_cell)
	moving = true

	_play_animation(dir)

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


func _check_player_collision():

	if player == null or has_killed:
		return

	if global_position.distance_to(player.global_position) < kill_distance:
		has_killed = true
		player.player_die()


func _play_animation(dir: Vector2i):

	var anim := $AnimatedSprite2D

	match dir:
		Vector2i.UP:
			anim.play("up")
		Vector2i.DOWN:
			anim.play("down")
		Vector2i.LEFT:
			anim.play("left")
		Vector2i.RIGHT:
			anim.play("right")
		_:
			anim.play("idle")
