class_name CrateHandler extends Sprite2D
#Exists to span crates at the beginnig of a level

var player_reference : Node
var the_maze : TileMapLayer
var an_item : Node


signal spawn_items
@export var coin_path = preload("res://scenes/coin.tscn")
@export var crate_path = preload("res://scenes/crate.tscn")

#The item pool, the crate will pick an item found here
var item_pool = {"coin":coin_path}
#var chosen_item = item_pool.keys().pick_random()

func _ready():
	set_modulate(Color(0.581, 0.454, 0.0, 1.0))
	if get_parent() is Mazery:
		print("Wake up item")
		
		the_maze = get_parent()

		get_parent().spawn_items.connect(_spawnCrates)
		get_parent().clearing.connect(_DestroyCrate)
		
	else:
		print("Not the parent")
	
func get_open_cells():
	var all_cells = the_maze.get_used_cells()
	var all_open = all_cells.filter(used_filter)
	
	return all_open
	
func used_filter(cell): 
	if the_maze.get_cell_tile_data(cell).get_custom_data("N") or the_maze.get_cell_tile_data(cell).get_custom_data("S") or the_maze.get_cell_tile_data(cell).get_custom_data("E") or the_maze.get_cell_tile_data(cell).get_custom_data("W"):
		return true
		
	else:
		return false

func _spawnCrates(location, danger_value : int):
#Function should spawn a specific amount of crates
#The # of crates spawned would be in range of the danger value
	print("Spawning Crate!")

	
	for unit in range(danger_value):
		var crate = crate_path.instantiate()
		crate.add_to_group("crate")
		get_parent( ).add_child(crate)
		
		location = get_open_cells().pick_random()
		crate.myItem = _pickItem()
		
		crate.position = the_maze.map_to_local(location)  
		
	print("I got the maze reference")
	
	set_modulate(Color(0.21, 0.119, 0.33, 1.0))



func _pickItem():
		return item_pool.get(item_pool.keys().pick_random())

func _DestroyCrate():
	print("Clearing crate")
	
	get_tree().call_group("crate", "_force_destroy")
	
	set_modulate(Color(0.237, 0.518, 0.187, 1.0))
	queue_free()
