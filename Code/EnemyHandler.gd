class_name enemyHandler extends Sprite2D


var player_reference : Node
var the_opposite : Node
var the_maze : Node
@export var enemy_spawn_delay := 2

@export var mummy_path = preload("res://scenes/Mummy.tscn")
@export var vampire_path = preload("res://scenes/vamp.tscn")
@export var warewolf_path = preload("res://scenes/wolf.tscn")
@export var zombie_path = preload("res://scenes/zombie.tscn")
@export var zombieMaster_path = preload("res://scenes/zombieMaster.tscn")

@export var mummy_small := 8
@export var mummy_long := 16
# 0 5 3 10 1
var ENEMY_RATIO = {"mummy": 1, "vampire": 5, "warewolf": 3, "zombie": 10, "zombieMaster": 1}
var ENEMY_FETCH = {"mummy":mummy_path,"vampire":vampire_path,"warewolf":warewolf_path,"zombie":zombie_path,"zombieMaster":zombieMaster_path}

signal spawn_enemies

var enemy_array := []
var enemy_spawn_point := Vector2i(-1,-1)


# Called when the node enters the scene tree for the first time.
func _ready():
	set_modulate(Color(0.302, 0.302, 0.302, 1.0))
	if get_parent() is Mazery:
		the_maze = get_parent()
		the_opposite = await get_parent().player_handler
		print("I have player handler reference")
		player_reference = await the_opposite.player_node
		print("I have player reference: ",player_reference)
		set_modulate(Color(1.0, 1.0, 1.0, 1.0))
		get_parent().spawn_enemies.connect(_set_spawn_point_spawn_enemies)
		get_parent().clearing.connect(_clean_up_enemies)
		the_opposite.player_node.connect(_reset_player_instance)
	else:
		print("illegal parent...")

#NOTE: trigggered by signal sent by mazery
func _set_spawn_point_spawn_enemies(location : Vector2i, danger_value : int):
	print("enemy array currently: ", enemy_array)
	#NOTE: why the fuck does only one enemy have the player referennce??
	print("spawning enemies")
	set_modulate(Color(0.94, 0.0, 0.264, 1.0))
	enemy_spawn_point = location

	#make odds array  based on enemy ratio
	var enemy_odds_array = []
	for enemy_type in ENEMY_RATIO.keys():
		for count in range(ENEMY_RATIO.get(enemy_type)):
			enemy_odds_array.append(enemy_type)
	
	#choose an enemy type randomly from enemy odds array
	#if the enemy is of limited quanity (zombie master and mummy) remove them from the pool
	for unit in danger_value:
		set_modulate(Color(1.0, 1.0, 1.0, 1.0))
		var to_spawn = enemy_odds_array.pick_random()
		if to_spawn == "zombieMaster":
			enemy_odds_array.erase(zombieMaster)
		to_spawn = ENEMY_FETCH.get(to_spawn)
		enemy_array.push_front(to_spawn.instantiate())
		enemy_array[0].tilemap = the_maze
		if enemy_array[0] is vampire or enemy_array[0] is warewolf or enemy_array[0] is zombieMaster:
			print("giving player reference")
			enemy_array[0].player = player_reference
			print(enemy_array[0].player)
		if enemy_array[0] is Mummy:
			enemy_array[0].mumLength = randi_range(mummy_small,mummy_long)
	print(enemy_array)
	
	#begin spawning enemies
	
	#enemies are just stacked on eachother.
	#space out spawning
	for enemy in enemy_array:
		set_modulate(Color(0.94, 0.0, 0.264, 1.0))
		await get_tree().create_timer(1).timeout
		enemy.process_mode = Node.PROCESS_MODE_DISABLED
		print(enemy)
		add_child(enemy)
		enemy.process_mode = Node.PROCESS_MODE_INHERIT
		spawn_enemies.emit(enemy_spawn_point)
	set_modulate(Color(1.0, 1.0, 1.0, 1.0))

func _reset_player_instance(player : Node):
	#this gives this node the player instance again.
	#in case the player is deleted.
	player_reference = player
	pass

func _spawn_enemy_arbitrary():
	#this is called during gameplay to replace dead enemies
	pass

#NOTE: triggered by signal sent by mazery
func _clean_up_enemies():
	print("cleaning enemies")
	for enemy in enemy_array:
		enemy.queue_free()
	set_modulate(Color(0.302, 0.302, 0.302, 1.0))
	enemy_array.clear()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
