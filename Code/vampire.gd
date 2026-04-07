class_name vampire extends GenericMazeEntity


@export var player: CharacterBody2D
@export var recalc_rate := 0.2

var graph: Dictionary = {}
var path: Array[Vector2i] = []
var path_index := 0
var timer := 0.0
var has_killed := false


func _ready():
	await super._ready()

	if tilemap == null:
		push_error("Tilemap missing!")
		return

	_build_graph()
	_recalculate_path()


func _physics_process(delta):

	if player == null:
		return

	super._physics_process(delta)

	_check_player_collision()

	#if has_killed:
		#return

	timer += delta

	if timer >= recalc_rate:
		timer = 0.0
		_recalculate_path()

	if not is_moving():
		_follow_path()


func _build_graph():

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


func _recalculate_path():

	if player == null:
		return

	var start = current_cell
	var goal = tilemap.local_to_map(player.global_position)

	path = _bfs(start, goal)
	path_index = 0


func _bfs(start: Vector2i, goal: Vector2i) -> Array[Vector2i]:

	var queue = [start]
	var came_from = {}
	came_from[start] = null

	while queue.size() > 0:

		var current = queue.pop_front()

		if current == goal:
			break

		if not graph.has(current):
			continue

		for next in graph[current]:

			if came_from.has(next):
				continue

			came_from[next] = current
			queue.append(next)

	var path_result: Array[Vector2i] = []

	if not came_from.has(goal):
		return []

	var cur = goal

	while cur != null:
		path_result.push_front(cur)
		cur = came_from[cur]

	return path_result


func _follow_path():

	if path.is_empty():
		return

	if path_index >= path.size() - 1:
		return

	var next_cell = path[path_index + 1]

	var dir = _normalize_dir(next_cell - current_cell)

	if move_in_direction(dir):
		path_index += 1


func _normalize_dir(dir: Vector2i) -> Vector2i:

	if abs(dir.x) > abs(dir.y):
		return Vector2i(sign(dir.x), 0)
	else:
		return Vector2i(0, sign(dir.y))


func _check_player_collision():

	if has_killed:
		return

	var player_cell = tilemap.local_to_map(player.global_position)

	if current_cell == player_cell:
		has_killed = true
		player.player_die()
