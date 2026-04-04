class_name Player extends GenericMazeEntity

var lastDirection := Vector2.RIGHT
var dead := false

func _ready():
	move_speed = 150
	print("player wait")
	current_cell = await get_parent().spawn_player
	print("My current_cell is: ", current_cell)
	target_position = tilemap.map_to_local(current_cell)
	global_position = target_position
	print("player done waiting")
	pass



func _physics_process(delta):
	#take input
	#correct the input based on the hallway
	#make that the target
	#do the bog standard shit every entity does to move
	
	#this approach will unify behavior among the classes

	if dead:
		return
	
	global_position = global_position.move_toward(target_position ,move_speed * delta)
	if global_position.distance_to(target_position) < 1:
		global_position = target_position
		#we reached a new cell. get player input for direction
		var direction_to_move = getting_new_targ()
		#print(direction_to_move)
		current_cell += direction_to_move
		target_position = tilemap.map_to_local(current_cell)
		if direction_to_move != Vector2i(0,0):
			play_move_animation(direction_to_move)
			lastDirection = direction_to_move
		else:
			play_idle_animation(lastDirection)
	
	
	
	#var dir = correct_inputs([up,down,left,right])
	#var my_tile = tilemap.get_cell_tile_data(current_cell)
	#print("current cell: ", my_tile.get_custom_data("N"), my_tile.get_custom_data("S"), my_tile.get_custom_data("E"), my_tile.get_custom_data("W"))



	#var direction := Vector2.ZERO
#
	## prevent diagonal movement
	#if input_dir.x != 0:
		#direction = Vector2(sign(input_dir.x),0)
	#elif input_dir.y != 0:
		#direction = Vector2(0,sign(input_dir.y))
#
	#if direction != Vector2.ZERO:
#
		#var grid_dir := Vector2i(direction)
#
		#if can_move(grid_dir):
#
			#lastDirection = direction
#
			#velocity = direction * maxSpeed
			#move_and_slide()
#
			#current_cell = tilemap.local_to_map(global_position)
#
			#play_move_animation(direction)
#
		#else:
#
			#velocity = Vector2.ZERO
			#play_idle_animation(lastDirection)
#
	#else:
#
		#velocity = Vector2.ZERO
		#play_idle_animation(lastDirection)
#


func can_move(dir: Vector2i) -> bool:

	if not DIRS.has(dir):
		return false

	var tile_data = tilemap.get_cell_tile_data(current_cell)

	if tile_data == null:
		return false

	return tile_data.get_custom_data(DIRS[dir]) == true

func play_move_animation(direction):

	if direction.x > 0:
		$AnimatedSprite2D.play("right")
	elif direction.x < 0:
		$AnimatedSprite2D.play("left")
	elif direction.y > 0:
		$AnimatedSprite2D.play("down")
	elif direction.y < 0:
		$AnimatedSprite2D.play("up")

func play_idle_animation(direction):

	if direction.x > 0:
		$AnimatedSprite2D.play("idleright")
	elif direction.x < 0:
		$AnimatedSprite2D.play("idleleft")
	elif direction.y > 0:
		$AnimatedSprite2D.play("idledown")
	elif direction.y < 0:
		$AnimatedSprite2D.play("idleup")

func correct_inputs(inputs : Array):
	#up, down, left, right
	var tile_self = tilemap.get_cell_tile_data(current_cell)
	var tiledata = [tile_self.get_custom_data("N"),tile_self.get_custom_data("S"),tile_self.get_custom_data("W"),tile_self.get_custom_data("E")]
	var allowed_input = []
	for i in range(4):
		if inputs[0] == tiledata[0] == true:
			allowed_input.append(true)
		else:
			allowed_input.append(false)
	#available dirs would be an arbitraryly sized array containing strings of directions (NSWE)
	#print("allowed inputs")
	#print(allowed_input)
	
	
	#based on the current tile's tile data
	#either zero or keep the value if the hallway corespoding to that direction is 
	pass

func player_die():

	if dead:
		return

	dead = true

	print("Player died")

	velocity = Vector2.ZERO

	$AnimatedSprite2D.stop()

	visible = false

	if $CollisionShape2D:
		$CollisionShape2D.disabled = true

	set_physics_process(false)


func getting_new_targ():
	#get new target cell based on player input.
	var input_array = [Input.is_action_pressed("ui_up"), Input.is_action_pressed("ui_down"),Input.is_action_pressed("ui_left"),Input.is_action_pressed("ui_right")]
	var tile_self = tilemap.get_cell_tile_data(current_cell)
	var tiledata = [tile_self.get_custom_data("N"),tile_self.get_custom_data("S"),tile_self.get_custom_data("W"),tile_self.get_custom_data("E")]
	var allowed_input = []
	for i in range(4):
		if true == input_array[i] and true == tiledata[i]:
			allowed_input.append(true)
		else:
			allowed_input.append(false)
	#print(allowed_input)
	if allowed_input.has(true):
		#we can actually move horray
		var our = DIRS.keys()
		for dir in range(allowed_input.size()):
			if allowed_input[dir] == true:
				return our[dir]
		#print("we can move")
	else:
		#print("we cannot move")
		return Vector2i(0,0)
	#var directions = 
	#pass
