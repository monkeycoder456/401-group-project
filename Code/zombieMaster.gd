class_name zombieMaster extends GenericMazeEntity

@export var player: Player
@export var move_delay := 0.5
@export var recalc_rate := 0.2
@export var detection_range := 5
@export var alert_cooldown := 2.0

var graph: Dictionary = {}
var path: Array[Vector2i] = []
var path_index := 0

var timer := 0.0
var can_move := true
var can_alert := true

var alerted := false



func _ready():
	await super._ready()

	player = get_tree().get_first_node_in_group("player")

	if tilemap == null:
		push_error("Tilemap missing!")
		return

	_build_graph()
	_recalculate_path()

	if player:
		player.Im_dead.connect(_on_player_died)


func _on_player_died():

	alerted = false
	can_alert = true

	path.clear()
	path_index = 0
	timer = 0.0

	moving = false
	can_move = true

	target_position = tilemap.map_to_local(current_cell)
	global_position = target_position

	_recalculate_path()


func _physics_process(delta):

	if player == null or player.dead:
		return

	super._physics_process(delta)

	timer += delta

	if timer >= recalc_rate:
		timer = 0.0
		_recalculate_path()

	if not moving and can_move:
		_move_with_delay()

	_scan_for_player_los()


func _move_with_delay():

	if not can_move:
		return

	can_move = false

	await get_tree().create_timer(move_delay).timeout

	if not moving:
		_follow_path()

	can_move = true


func _follow_path():

	if path.is_empty():
		_recalculate_path()
		return

	if path_index >= path.size() - 1:
		_recalculate_path()
		return

	var next_cell = path[path_index + 1]
	var dir = _normalize_dir(next_cell - current_cell)

	var possible_dirs = _get_available_dirs()
	if possible_dirs.is_empty():
		return

	# fallback if path direction blocked
	if not possible_dirs.has(dir):
		dir = possible_dirs.pick_random()

	if move_in_direction(dir):
		path_index += 1


func _scan_for_player_los():

	if player == null:
		return

	var player_cell = player.current_cell

	for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:

		var current_check = current_cell

		for i in range(1, detection_range + 1):

			var next_cell = current_check + dir

			if not _can_see_between(current_check, dir):
				break

			if next_cell == player_cell:

				alerted = true

				if can_alert:
					_alert_all_zombies(player_cell)
					_start_alert_cooldown()

				return

			current_check = next_cell


func _can_see_between(from_cell: Vector2i, dir: Vector2i) -> bool:

	var from_tile = tilemap.get_cell_tile_data(from_cell)
	var to_tile = tilemap.get_cell_tile_data(from_cell + dir)

	if from_tile == null or to_tile == null:
		return false

	return from_tile.get_custom_data(DIRS[dir]) \
		and to_tile.get_custom_data(DIRS[-dir])


func _alert_all_zombies(player_cell: Vector2i):

	for z in get_tree().get_nodes_in_group("zombies"):

		if z.has_method("alert_to_player"):
			z.alert_to_player(player_cell)

		elif z.has_method("receive_alert"):
			z.receive_alert()


func _start_alert_cooldown():

	can_alert = false
	await get_tree().create_timer(alert_cooldown).timeout
	can_alert = true


func _recalculate_path():

	if player == null:
		return

	path = _bfs(current_cell, player.current_cell)
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

	var cells = tilemap.get_used_cells()

	for cell in cells:

		var data = tilemap.get_cell_tile_data(cell)
		if data == null:
			continue

		graph[cell] = []

		for dir in DIRS.keys():

			if not data.get_custom_data(DIRS[dir]):
				continue

			var neighbor = cell + dir

			if cells.has(neighbor):
				graph[cell].append(neighbor)


func _normalize_dir(dir: Vector2i) -> Vector2i:

	if abs(dir.x) > abs(dir.y):
		return Vector2i(sign(dir.x), 0)
	else:
		return Vector2i(0, sign(dir.y))
