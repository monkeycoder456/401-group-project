class_name CrateHandler extends Sprite2D
#Exists to span crates at the beginnig of a level
signal spawn_items
#A spawn_items.emit() is at the end of the _make_me_maze_again func
#The _make_me_maze_again is in Mazery, this allows for the crate to respawn after a level completion

var player_reference : Node
var the_maze = TileMapLayer
var an_item : Node
var rng := RandomNumberGenerator.new()

@export var coin_path = preload("res://scenes/coin.tscn")
@export var crate_path = preload("res://scenes/crate.tscn")
@export var GandC_Path = preload("res://scenes/cross_garlic_aura.tscn")
#The item pool, the crate will pick an item found here

var item_pool = {"coin":coin_path}

func _ready():
	set_modulate(Color(0.581, 0.454, 0.0, 1.0))
	rng.randomize()
	
	if get_parent() is Mazery:
		print("Wake up item")
		var parent = get_parent()
		the_maze = parent

		parent.spawn_items.connect(Callable(self, "_spawnCrates"))
		parent.clearing.connect(Callable(self, "_DestroyCrate"))
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

func get_reachable_cells():
	#Serches for reachable tiles in the maze
	var start = the_maze.get_node("MazeryExtraData").start_tile
	print("searching for reachable tiles")
	var visited := {}
	var queue := [start]
	visited[start] = true

	var directions = {
		"N": Vector2i(0, -1),
		"S": Vector2i(0, 1),
		"E": Vector2i(1, 0),
		"W": Vector2i(-1, 0)
	}

	while queue.size() > 0:
		var current = queue.pop_front()
		var data = the_maze.get_cell_tile_data(current)

		for dir in directions.keys():
			if data.get_custom_data(dir):
				var neighbor = current + directions[dir]

				if not visited.has(neighbor):
					visited[neighbor] = true
					queue.append(neighbor)

	print("found for reachable tiles")
	return visited.keys() 

func _spawnCrates():
#Function should spawn a specific amount of crates
#The # of crates spawned would be in range of the danger value
	print("Spawning Crate!")
	var danger_value = the_maze.danger_value
	var reachable_cells = await get_reachable_cells()

	for unit in range(min(danger_value, reachable_cells.size())):
		var crate = crate_path.instantiate()
		crate.add_to_group("crate") 
		get_parent().add_child(crate)

		var cell = reachable_cells[rng.randi_range(0, reachable_cells.size() - 1)]
		crate.myItem = _pickItem()
		

		crate.position = the_maze.map_to_local(cell)
		print("Spawn at cell: ", cell)
	print("I got the maze reference")
	
	set_modulate(Color(0.21, 0.119, 0.33, 1.0))

func _pickItem():
	#Randomly selects an item from the item pool
	var keys = item_pool.keys()
	return item_pool[keys.pick_random()]
		
func _DestroyCrate():
	#Clears and destroys the crate and item upon level completion
	
	print("Clearing crate")
	
	get_tree().call_group("crate", "_force_destroy")
	get_tree().call_group("item", "queue_free")
	await get_tree().create_timer(0.5).timeout 
	
	set_modulate(Color(0.237, 0.518, 0.187, 1.0))
