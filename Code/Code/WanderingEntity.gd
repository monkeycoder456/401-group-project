class_name WanderingEntity extends GenericMazeEntity


func _ready():
	print(get_parent())
	if get_parent() is Mazery:
		tilemap = get_parent()
	else:
		##parent must be enemy handler, hook up signal and wait for order
		##await $
		pass
	#moving = true
	print("waiting for maze to finish")
	await tilemap.spawn_enemies
	print("done waiting")
	var local_pos = tilemap.to_local(global_position)
	#current_cell = where_to_begin
	target_position = tilemap.map_to_local(current_cell)
	randomize()
	_start_wander()
	pass

func _physics_process(delta):
	#if moving:
		#global_position = global_position.move_toward(
			#target_position,
			#move_speed * delta
		#)
#
		#if global_position.distance_to(target_position) < 1:
			#global_position = target_position
			#moving = false
			#await get_tree().create_timer(move_delay).timeout
			#_start_wander()
	_play_animation(Vector2i(-1,-1))
	pass

func _start_wander():
	#var possible_dirs := _get_available_dirs()
#
	#if possible_dirs.is_empty():
		#return
#
	#var dir: Vector2i
#
	#if possible_dirs.size() == 2:
		#if last_dir != Vector2i.ZERO and possible_dirs.has(last_dir):
			#dir = last_dir
		#else:
			#dir = possible_dirs.pick_random()
	#else:
		#var filtered_dirs = possible_dirs.duplicate()
#
		#if last_dir != Vector2i.ZERO:
			#filtered_dirs.erase(-last_dir)
#
		#if filtered_dirs.is_empty():
			#filtered_dirs = possible_dirs
#
		#dir = filtered_dirs.pick_random()
#
	#last_dir = dir
	#current_cell += dir
	#target_position = tilemap.map_to_local(current_cell)
	#moving = true
	#_play_animation(dir)
	pass

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
		anim.play("wandering")
	elif dir == Vector2i.DOWN:
		anim.play("wandering")
	elif dir == Vector2i.LEFT:
		anim.play("wandering")
	elif dir == Vector2i.RIGHT:
		anim.play("wandering")
	else:
		anim.play("hangingAround")
