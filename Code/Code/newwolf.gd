extends GenericMazeEntity

@export var player: Node2D
@export var jump_delay := 2.0

var jumping := false
var preparing_jump := false
var has_killed := false

var jump_target: Vector2
var jump_cell: Vector2i


func _physics_process(delta):

	if player == null:
		return

	if jumping:
		var dir = (jump_target - global_position).normalized()
		velocity = dir * (move_speed * 2.2)
		move_and_slide()

		_play_animation(last_dir)

		_check_player_collision()

		if global_position.distance_to(jump_target) < 3:
			global_position = jump_target
			current_cell = jump_cell
			jumping = false
		return

	super._physics_process(delta)

	_check_player_collision()

	if not is_moving() and not preparing_jump:
		_decide_move()

func _decide_move():
	var walk_option = _get_best_walk()
	var jump_option = _get_best_jump()

	if jump_option != null and jump_option.distance < walk_option.distance:
		_prepare_jump(jump_option.dir, jump_option.cell)
	else:
		if walk_option.dir != Vector2i.ZERO:
			move_in_direction(walk_option.dir)

func _get_best_walk():
	var dirs = get_available_dirs()

	if dirs.size() > 1 and -last_dir in dirs:
		dirs.erase(-last_dir)

	var best = {
		"dir": Vector2i.ZERO,
		"distance": INF
	}

	for dir in dirs:
		var next_cell = current_cell + dir
		var pos = tilemap.map_to_local(next_cell)
		var dist = pos.distance_to(player.global_position)

		if dist < best.distance:
			best.dir = dir
			best.distance = dist

	return best

func _get_best_jump():
	var best_jump = null

	for dir in DIRS.keys():

		if dir == -last_dir:
			continue

		var mid_cell = current_cell + dir
		var land_cell = current_cell + dir * 2

		var mid_data = tilemap.get_cell_tile_data(mid_cell)
		var land_data = tilemap.get_cell_tile_data(land_cell)

		if _is_blocked(mid_data) and _is_walkable(land_data):

			var pos = tilemap.map_to_local(land_cell)
			var dist = pos.distance_to(player.global_position)

			if best_jump == null or dist < best_jump.distance:
				best_jump = {
					"dir": dir,
					"cell": land_cell,
					"distance": dist
				}

	return best_jump

func _prepare_jump(dir: Vector2i, land_cell: Vector2i):
	preparing_jump = true
	last_dir = dir

	_play_charge_animation(dir)

	await get_tree().create_timer(jump_delay).timeout

	var pos = tilemap.map_to_local(land_cell)
	var new_dist = pos.distance_to(player.global_position)

	if new_dist > global_position.distance_to(player.global_position):
		preparing_jump = false
		return

	jump_cell = land_cell
	jump_target = pos

	jumping = true
	preparing_jump = false

func _play_charge_animation(dir: Vector2i):
	var anim := $AnimatedSprite2D

	if dir == Vector2i.UP:
		anim.play("chargeup")
	elif dir == Vector2i.DOWN:
		anim.play("chargedown")
	elif dir == Vector2i.LEFT:
		anim.play("chargeleft")
	elif dir == Vector2i.RIGHT:
		anim.play("chargeright")

func _check_player_collision():

	if player == null or has_killed:
		return

	if global_position.distance_to(player.global_position) < 20:
		has_killed = true
		player.player_die()

func _is_blocked(tile_data) -> bool:
	if tile_data == null:
		return true

	for key in ["N", "S", "E", "W"]:
		if tile_data.get_custom_data(key):
			return false

	return true


func _is_walkable(tile_data) -> bool:
	if tile_data == null:
		return false

	for key in ["N", "S", "E", "W"]:
		if tile_data.get_custom_data(key):
			return true

	return false
