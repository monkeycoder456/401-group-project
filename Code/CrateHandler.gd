class_name CrateHandler extends Sprite2D
#Exists to span crates at the beginnig of a level

var item_spawn_point := Vector2i(-1,-1)
var player_reference : Node
var the_maze : Node
var an_item : Node

signal spawn_items

@export var crate_path = preload("res://scenes/crate.tscn")
@export var coin_path = preload("res://scenes/coin.tscn")


#The item pool, the crate will pick an item found here
var item_pool = {"coin":coin_path}

func _ready():
	set_modulate(Color(0.581, 0.454, 0.0, 1.0))
	if get_parent() is Mazery:
		print("Wake up item")
		get_parent().spawn_items.connect(_spawnCrates)
		get_parent().clearing.connect(_DestroyCrate)
		
	else:
		print("Not the parent")
	


func _spawnCrates(location : Vector2i, danger_value : int):
#Function should spawn a specific amount of crates
#The # of crates spawned would be in range of the danger value
	print("Spawning Crate!")
	item_spawn_point = location
	
	for unit in range(danger_value):
		#insanciate a crate and add to group crate
		var crate = crate_path.insanciate().add_to_group("crate") 
		the_maze = get_parent()  #Maze Reference
		print("I got the maze reference")
		set_modulate(Color(0.21, 0.119, 0.33, 1.0))
		pass

#void add_to_group(group: StringName, persistent: bool = false)
#To add to group 

	pass

func _DestroyCrate():
	print("Clearing crate")
	get_tree().call_group("crate", "forcedestroy")
	
	set_modulate(Color(0.237, 0.518, 0.187, 1.0))
	pass
	
	
