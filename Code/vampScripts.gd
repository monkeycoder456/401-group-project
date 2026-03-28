class_name Vampire extends GenericMazeEntity

@export var player: CharacterBody2D

var has_killed := false


func _ready():
	await super._ready()

	#Spawn position for seed 10
	current_cell = Vector2i(39, 3)
	target_position = tilemap.map_to_local(current_cell)
	global_position = target_position

	_choose_direction()


func _physics_process(delta):

	if player == null:
		return

	super._physics_process(delta)

	_check_player_collision()

	if not is_moving():
		_choose_direction()


func _choose_direction():

	var possible_dirs := get_available_dirs()

	if possible_dirs.is_empty():
		return

	if last_dir != Vector2i.ZERO and possible_dirs.size() > 1:
		possible_dirs.erase(-last_dir)

	var player_cell = tilemap.local_to_map(player.global_position)

	var best_dir := possible_dirs[0]
	var best_distance := INF

	for dir in possible_dirs:
		var next_cell = current_cell + dir
		var dist = next_cell.distance_to(player_cell)

		if dist < best_distance:
			best_distance = dist
			best_dir = dir

	move_in_direction(best_dir)


func _check_player_collision():

	if player == null or has_killed:
		return

	if global_position.distance_to(player.global_position) < 16:
		has_killed = true
		player.player_die()
