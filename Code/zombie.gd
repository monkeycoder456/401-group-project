class_name Zombie extends GenericMazeEntity

@export var player: CharacterBody2D

@export var move_delay := 1.0
@export var recalc_rate := 0.2
@export var alert_duration := 10.0

var alerted := false
var alert_timer := 0.0
var has_killed := false

var graph: Dictionary = {}
var path: Array[Vector2i] = []
var path_index := 0

var move_timer := 0.0
var recalc_timer := 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var last_move_dir := Vector2i.DOWN

var fear_source = null
var is_feared = false


func _ready():
	await super._ready()

	player = get_tree().get_first_node_in_group("player")
	add_to_group("zombies")

	if tilemap == null:
		push_error("Tilemap missing!")
		return

	_build_graph()

	if player:
		player.Im_dead.connect(_on_player_died)


func _on_player_died():
	move_delay = 1.0
	has_killed = false

	alerted = false
	alert_timer = 0.0

	path.clear()
	path_index = 0
	recalc_timer = 0.0

	moving = false

	target_position = tilemap.map_to_local(current_cell)
	global_position = target_position

	_start_wander()


func _physics_process(delta):

	if player == null:
		return

	if is_feared and fear_source != null:
		if not is_moving():
			var dirs = _get_available_dirs()
			if dirs.is_empty():
				return

			var best_dir = dirs[0]
			var best_distance = -1

			for dir in dirs:
				var next_cell = current_cell + dir
				var pos = tilemap.map_to_local(next_cell)
				var dist = pos.distance_to(fear_source.global_position)

				if dist > best_distance:
					best_distance = dist
					best_dir = dir

			if move_in_direction(best_dir):
				last_move_dir = best_dir
				_update_animation(best_dir)
			else:
				dirs.erase(best_dir)
				dirs.erase(-best_dir)
				dirs.shuffle()
				for alt_dir in dirs:
					if move_in_direction(alt_dir):
						last_move_dir = alt_dir
						_update_animation(alt_dir)
						break
		return

	if moving:
		var dir = (target_position - global_position).normalized()
		velocity = dir * move_speed
		move_and_slide()

		if global_position.distance_to(target_position) < 2:
			global_position = target_position
			moving = false
	else:
		velocity = Vector2.ZERO

	_check_player_collision()

	move_timer += delta

	if alerted:
		_alert_logic(delta)
	else:
		_wander_logic()


func _wander_logic():

	if move_timer < move_delay:
		return

	move_timer = 0.0
	_start_wander()


func _start_wander():

	var dirs = _get_available_dirs()
	if dirs.is_empty():
		return

	var dir: Vector2i

	if last_dir != Vector2i.ZERO and dirs.has(last_dir):
		dir = last_dir
	else:
		var filtered = dirs.duplicate()
		if filtered.size() > 1:
			filtered.erase(-last_dir)
		dir = filtered.pick_random()

	if move_in_direction(dir):
		last_move_dir = dir
		_update_animation(dir)
	else:
		dirs.erase(dir)
		dirs.erase(-dir)
		dirs.shuffle()
		for alt_dir in dirs:
			if move_in_direction(alt_dir):
				last_move_dir = alt_dir
				_update_animation(alt_dir)
				break


func _alert_logic(delta):

	alert_timer += delta
	recalc_timer += delta

	if alert_timer >= alert_duration:
		_reset_to_wander()
		return

	if recalc_timer >= recalc_rate:
		recalc_timer = 0.0
		_recalculate_path()

	if not is_moving() and move_timer >= move_delay:
		move_timer = 0.0
		_follow_path()


func _follow_path():

	if path.is_empty():
		_recalculate_path()
		return

	if path_index >= path.size() - 1:
		_recalculate_path()
		return

	var next_cell = path[path_index + 1]
	var dir = _normalize_dir(next_cell - current_cell)

	if move_in_direction(dir):
		last_move_dir = dir
		path_index += 1
		_update_animation(dir)
	else:
		var dirs = _get_available_dirs()
		dirs.erase(dir)
		dirs.erase(-dir)
		dirs.shuffle()
		for alt_dir in dirs:
			if move_in_direction(alt_dir):
				last_move_dir = alt_dir
				path_index += 1
				_update_animation(alt_dir)
				return
		_recalculate_path()


func _recalculate_path():

	if player == null:
		return

	var start = current_cell
	var goal = player.current_cell

	path = _bfs(start, goal)
	path_index = 0


func _bfs(start: Vector2i, goal: Vector2i) -> Array[Vector2i]:

	var queue = [start]
	var came_from = {start: null}

	while queue.size() > 0:

		var current = queue.pop_front()

		if current == goal:
			break

		if not graph.has(current):
			continue

		for next in graph[current]:
			if next in came_from:
				continue

			came_from[next] = current
			queue.append(next)

	if goal not in came_from:
		return []

	var result: Array[Vector2i] = []
	var cur = goal

	while cur != null:
		result.push_front(cur)
		cur = came_from[cur]

	return result


func _build_graph():

	graph.clear()

	var dirs = {
		Vector2i.UP: "N",
		Vector2i.DOWN: "S",
		Vector2i.LEFT: "W",
		Vector2i.RIGHT: "E"
	}

	var cells = tilemap.get_used_cells()

	for cell in cells:

		var data = tilemap.get_cell_tile_data(cell)
		if data == null:
			continue

		graph[cell] = []

		for dir in dirs.keys():

			if not data.get_custom_data(dirs[dir]):
				continue

			var neighbor = cell + dir

			if cells.has(neighbor):
				graph[cell].append(neighbor)


func _reset_to_wander():
	move_delay = 1.0
	alerted = false
	alert_timer = 0.0

	path.clear()
	path_index = 0
	recalc_timer = 0.0

	moving = false

	target_position = tilemap.map_to_local(current_cell)
	global_position = target_position

	_start_wander()


func _update_animation(dir: Vector2i):
	if sprite == null:
		return
	print("am I alerted? : ", alerted)
	if alerted:
		print("I AM IN THE ALERT ANIM AREA")
		if dir == Vector2i.UP:
			sprite.play("alertup")
		elif dir == Vector2i.DOWN:
			sprite.play("alertdown")
		elif dir == Vector2i.LEFT:
			sprite.play("alertleft")
		elif dir == Vector2i.RIGHT:
			sprite.play("alertright")
	else:
		if dir == Vector2i.UP:
			sprite.play("up")
		elif dir == Vector2i.DOWN:
			sprite.play("down")
		elif dir == Vector2i.LEFT:
			sprite.play("left")
		elif dir == Vector2i.RIGHT:
			sprite.play("right")
	print(sprite.animation)


func _normalize_dir(dir: Vector2i) -> Vector2i:

	if abs(dir.x) > abs(dir.y):
		return Vector2i(sign(dir.x), 0)
	else:
		return Vector2i(0, sign(dir.y))


func _check_player_collision():

	if player == null or has_killed:
		return

	if global_position.distance_to(player.global_position) < 10:
		has_killed = true
		player.player_die()


func alert_to_player(player_cell: Vector2i):
	move_delay = 0.0
	alerted = true
	alert_timer = 0.0

	path = _bfs(current_cell, player_cell)
	path_index = 0
	
	_update_animation(last_move_dir)


func enter_fear_mode(source):
	is_feared = true
	fear_source = source
	alerted = false


func exit_fear_mode():
	is_feared = false
	fear_source = null
