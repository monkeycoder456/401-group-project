class_name PlayerHandler extends Sprite2D

@onready var the_Maze = get_parent()

var player_spawn_point := Vector2i(-1,-1)

var player_scene = preload("res://scenes/player.tscn")

var my_player : Node


signal spawn_player
signal player_node

#the player handler's job is to:

#create the player on game start
#give the player it's tilemap data
#create the player on respawn
#communicate with enemy handler, sending player data

#it will indicate what it is doing with states, repsesented with colors

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent() is Mazery:
		print("initiating...")
		set_modulate(Color(0.366, 0.369, 0.366, 1.0))
		get_parent().spawn_player.connect(_set_spawn_point_spawn_player)
		get_parent().clearing.connect(_clean_up_player)
		#this it to give the data over to enemy handler
	else:
		print("alone...")

func _clean_up_player():
	#this function will set the player back to start
		#if player dies
	if my_player is Player:
		my_player.global_position = the_Maze.map_to_local(player_spawn_point)
		my_player.target_position = the_Maze.map_to_local(player_spawn_point)
		my_player.current_cell = player_spawn_point
		my_player.set_process_mode(Node.PROCESS_MODE_DISABLED)
		my_player.visible = false
	set_modulate(Color(0.366, 0.369, 0.366, 1.0))
	pass

func _respawn_player():
	#this function will "respawn the player"
		#make the player active again
	if my_player is Player:
		my_player.set_process_mode(Node.PROCESS_MODE_ALWAYS)
		set_modulate(Color(1.0, 1.0, 1.0, 1.0))
		my_player.visible = true
	pass

func _set_spawn_point_spawn_player(location : Vector2i):
	print("got spawn point")
	player_spawn_point = location
	set_modulate(Color(1.0, 1.0, 1.0, 1.0))
	print(player_spawn_point)
	my_player = player_scene.instantiate()
	my_player.tilemap = the_Maze
	add_child(my_player)
	spawn_player.emit(player_spawn_point)
	print("emitting signal of player")
	call_deferred("emit_signal","player_node",my_player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#space button
	#if Input.is_action_just_pressed("ui_accept"):
		#_clean_up_player()
	##escape button
	#if Input.is_action_just_pressed("ui_cancel"):
		#_respawn_player()
	pass
