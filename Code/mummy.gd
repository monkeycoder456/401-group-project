class_name Mummy extends "res://code/GenericMazeEntity.gd"

#TODO: fix segments to be less choppy in movement. do this with move towards

@export var mumLength := 4
var currentMumLength = 0
var previous_cell = Vector2i(-1,-1)
var move_delay = 0.0
var random_targ = Vector2i(-1,-1)

signal create_new_seg
signal move_ahead
signal how_long_are_we #relays intended
signal how_long_are_we_currently #relays current

var wrapsScene = preload("res://scenes/wraps.tscn")
var sarcScene = preload("res://scenes/sarc.tscn")

func _ready():
	#print("as a mummy I am waiting")
	await super._ready()
	#print("finished waiting as mummy")
	#current_cell = Vector2i(0,0)
	target_position = tilemap.map_to_local(current_cell)
	randomize()
	_start_wander()
	pass

func _physics_process(delta):
	if moving:
		global_position = global_position.move_toward(target_position ,move_speed * delta)
		if global_position.distance_to(target_position) < 1:
			global_position = target_position
			moving = false
			await get_tree().create_timer(move_delay).timeout
			#print("Mummy Emit signal")
			move_ahead.emit(previous_cell)
			previous_cell = _start_wander()
	#_play_animation(Vector2i(-1,-1))
	pass

func _start_wander():
	var possible_dirs := _get_available_dirs()

	if possible_dirs.is_empty():
		return

	var dir: Vector2i

	if possible_dirs.size() == 2:
		if last_dir != Vector2i.ZERO and possible_dirs.has(last_dir):
			dir = last_dir
		#we need another check for corners. this is so we do not double back
		else:
			#being here means that our last direction isn't an option
			#but the available options is still only 2
			var filtered_dirs = possible_dirs.duplicate()
			filtered_dirs.erase(-last_dir)
			dir = filtered_dirs.pick_random()
	else:
		var filtered_dirs = possible_dirs.duplicate()

		if last_dir != Vector2i.ZERO:
			filtered_dirs.erase(-last_dir)

		if filtered_dirs.is_empty():
			filtered_dirs = possible_dirs

		dir = filtered_dirs.pick_random()

	last_dir = dir
	
	current_cell += dir
	var prev_cell = current_cell
	#signal emit zone
	#print("emitting move signal")
	#print("mummy pos: ", current_cell)
	#print("current to desired: ", currentMumLength, " ", mumLength, " OO")
	if currentMumLength != mumLength:
		#print("emitting create signal")
		if get_child_count() == 2:
			createVirginSegment()
			create_new_seg.emit(previous_cell,0)
			how_long_are_we.emit(mumLength)
			#print("made a new segment, OO")
		else:
			#print("make me a new seg please, OO")
			create_new_seg.emit(previous_cell,0)
			how_long_are_we.emit(mumLength)
			currentMumLength += 1
			#print("made a new segment, OO")
	#else:
		##print("no more segments!!")
	#print("current to desired (after work): ", currentMumLength, " ", mumLength, " OO")

	target_position = tilemap.map_to_local(current_cell)
	moving = true
	_play_animation(dir)
	return prev_cell

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
	else:
		anim.play("hangingAround")

func createVirginSegment():
	currentMumLength += 1
	#print("in creating first segment")
	var new_seg
	if currentMumLength == mumLength:
		#mum length of 1, so just make a sarc
		#print("making sarc")
		new_seg = sarcScene.instantiate()
	else:
		#mum length is longer than 1, make a wraps
		#print("making wrap")
		new_seg = wrapsScene.instantiate()
	print(new_seg)
	#child it to this scene, mummy
	new_seg.tilemap = self.tilemap

	add_child(new_seg)
