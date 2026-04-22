class_name Mazery extends TileMapLayer

var DIRECTIONS = {"N"=Vector2i(0,-1),"S"=Vector2i(0,1),"E"=Vector2i(1,0),"W"=Vector2i(-1,0)}
var DIRECTION_TO_NUM = {"N"=0,"S"=1,"E"=2,"W"=3}
var OPPOSITES = {"N"="S","S"="N","E"="W","W"="E"}
var POLARIZED = {"N"=["E","W"],"S"=["E","W"],"E"=["N","S"],"W"=["N","S"]}
var proxy : tilemapproxy
var blocks : blocklayer
#for tile classification and reference for later
#these should be emptied afteruse as to prevent too many dittos
var hallways = [] #represented with H
var hallwayCorner = [] #rep with CH
var tJunction = [] #rep with T
var crossing = [] #rep with X
var nooks = [] #rep with N
var junk = [] #reperesented with question mark

#check to see if in editor patterns are accessable
#if not: at instantiation quickly make patterns and save them

@export var simplcity := 2
'''the above variable is for how many times the tree cleaner will slim the maze down'''
@export var danger_value := 10
@export var my_seed : int
@export var debug_switch := false
@export var remove_brother_surrounded := true
@export var remove_brother_corners := true
#@export var remove_hallway_surrounded := true
#@export var crossings_to_other := true
@export var remove_orphans := true
@export var attach_hallways := true
#@export var pitty_connections := true
#@export var clean_up_crossings := true
#@export var tree_clean_up := true
@export var remake_if_unsolvable := true
@export var num_rows := 20
@export var num_columns := 20
var set_to_use : int
@export_enum("N", "S", "E","W") var enter_side_set: String
@export_enum("N", "S", "E","W") var exit_side_set: String
@export_enum("generic","woods","graveyard","house") var shape_set: String

#region // liked seeds
#10
#234
#endregion

#these are the shapes that are allowed to fill.
#if a shape doesn't work out then we must deviate...
#they are all rectangles and squares
#written as "name":[x,y]
#where x is the columns it occupies
#and y is the rows it occupies 
var SHAPES = {"Square2"=[2,2], "Rectangle32"=[3,2],"Rectangle23"=[2,3],"Square3"=[3,3],"Rectangle42"=[4,2],"Rectangle24"=[2,4],"Square4"=[4,4]}
var WOODS_SHAPES = {"Square3"=[3,3],"Rectangle34"=[3,4],"Rectangle43"=[4,3],"Square2"=[2,2],"rectangle64"=[6,4],"rectangle46"=[4,6]}
var GRAVE_SHAPES = {"square3"=[3,3],"square4"=[4,4],"rectangle54"=[5,4],"rectangle45"=[4,5],"Rectangle61"=[6,1],"Rectangle16"=[1,6],"dittoRectangle61"=[6,1],"dittoRectangle16"=[1,6]}
var HOUSE_SHAPES = {"Square3"=[3,3],"Square4"=[4,4],"Rectangle62"=[6,2],"Rectangle26"=[2,6],"dittoSquare3"=[3,3],"dittoSquare4"=[4,4]}
var MAZE_SIZES = {"generic" : [40,20],"woods" : [40,30],"graveyard" : [40,20],"house" : [20,20]}
var what_set = {"generic":1,"woods":1,"graveyard":2,"house":3}
var what_mini_set = {"woods":15,"graveyard":14,"house":13}

var decorations = {"graveyard" : 
	{Vector2i(2,2):[12,15],
	Vector2i(4,2):[27],
	Vector2i(4,1):[29],
	Vector2i(1,3):[14,24,25],
	Vector2i(1,2):[21,22,23,30,31],
	Vector2i(2,3):[16],
	Vector2i(3,2):[19],
	Vector2i(3,1):[13,20,28,32]}
	,"woods":
	{Vector2i(4,2):[2],
	Vector2i(3,2):[9,8],
	Vector2i(2,1):[5,6,10,26],
	Vector2i(2,2):[3,4,7,11],
	Vector2i(1,2):[0,1,17,18]}
	,"house":{Vector2i(2,2):[33],
	Vector2i(2,1):[34,35],
	Vector2i(1,2):[36,37]}}

#NOTE: woods creation pipeline; remove brother surround, remove brother corners
#NOTE: grave creation pipeline; remve brother surround
#NOTE: house creation pipeline; 

#WARNING: all mazes MUST haave remove orphans and attach hallways as part of pipeline
signal put_something_here_please
signal spawn_enemies
signal spawn_items
signal spawn_player
signal clearing
signal player_handler

func _ready():
	#NOTE: you must make all patterns by hand :skull:
	#before game start have all patterns on the grid organized neatly
	#mazery will create patterns and store them in the appropriate member
	#once patterns are made we can just overwrite the junk
	
	#just use "get_pattern()" on hard coded locations
	#do this a bunch of times so uh, its gonna be a little slow
	
	#NOTE: check to see if this is applicable and works.
	#DEADLINE IS APPROACHING!!!
	
	#_create_patterns()
	z_index = -5
	#print("I have entered scene tree: maze")
	if my_seed == 0:
		var new_seed  = randi_range(0,1000)
		seed(new_seed)
		print("random seed is: ", new_seed)
	else:
		print("using supplied seed: ", my_seed)
		seed(my_seed)
	#for i in ordinal.keys().size():
		#var dir = ordinal.get(ordinal.keys()[i])
		#set_cell(Vector2i(dir[0],dir[1]),1,Vector2i(3,3))


	if remake_if_unsolvable == true:
		
		var solvable = false
		while(solvable == false):
			_make_me_maze(enter_side_set,exit_side_set,shape_set)
		#verify if maze is solvable
		#just create a tree from start
		#check if the end spot is in tree
		#if not, make an entirely new maze
			var treeze = max_tree_from_here($MazeryExtraData.start_tile)
			if treeze.get_all_nodes_as_list().has($MazeryExtraData.end_tile):
				print("VALID :-)")
				solvable = true
			else:
				print("INVALID :-(")
				pass
	else:
		_make_me_maze(enter_side_set,exit_side_set,shape_set)
	proxy_to_tile_map_layer(set_to_use)
	#_use_pattern()
	place_fluff(shape_set)
	#print(get_children())
	#print(get_child(1))
	#print($MazeryExtraData)
	
	var end_point = $MazeryExtraData.end_tile
	var start_point = $MazeryExtraData.start_tile
	#print(end_point)
	spawn_player.emit(start_point)
	call_deferred("emit_signal","spawn_enemies",end_point, danger_value)
	spawn_items.emit()
	
	#TRY to get the player handler. if not a child, continue
	
	#if you can get the player handler, emit the node to the
	
	var supposed_PH = get_node_or_null("PH")
	if supposed_PH:
		#print("yes player handler")
		player_handler.emit(supposed_PH)
		pass
	else:
		#print("No player handler")
		pass
	

func place_fluff(shape_sett):
	#put 3-5 layers of blank tiles around the maze
	#for north and south face just do an offset run
	
	#for east and west face do the same but be warey of ruining shit
	for row in range(-1,-6,-1):
		for column in range(-6, MAZE_SIZES.get(shape_sett)[0] + 6):
			set_cell(Vector2i(column,row),what_set.get(shape_sett),Vector2i(0,0))
	for row in range(MAZE_SIZES.get(shape_sett)[1],MAZE_SIZES.get(shape_sett)[1] + 6):
		for column in range(-6, MAZE_SIZES.get(shape_sett)[0] + 6):
			set_cell(Vector2i(column,row),what_set.get(shape_sett),Vector2i(0,0))
	
	#WEST <- AKA X = NEG
	for row in range(0,MAZE_SIZES.get(shape_sett)[1]):
		for column in range(-1,-7,-1):
			if Vector2i(column,row) != $MazeryExtraData.start_tile:
				set_cell(Vector2i(column,row),what_set.get(shape_sett),Vector2i(0,0))
	
	#EAST -> AKA X = POS
	for row in range(0,MAZE_SIZES.get(shape_sett)[1]):
		for column in range(MAZE_SIZES.get(shape_sett)[0], MAZE_SIZES.get(shape_sett)[0] + 6):
			if Vector2i(column,row) != $MazeryExtraData.end_tile:
				set_cell(Vector2i(column,row),what_set.get(shape_sett),Vector2i(0,0))
	
	#for ease this function will also correct the incorrect appearances of enterance and exit
	#WE WILL ALWAYS ASSUME THAT ENTERANCE WEST, EXIT NORTH
	#NO TIME !!!
	set_cell($MazeryExtraData.start_tile,what_set.get(shape_sett),Vector2i(2,0))
	set_cell($MazeryExtraData.end_tile,what_set.get(shape_sett),Vector2i(1,0))
	
	#HACK: this function will also place all the pretty map things
	
	#get a list containg all tiles that are NOT used in the maze (aka have no maze relvant data)
	#	this can be doen with filtering if they have a true in them or not
	
	#once there try to place the largest decorative items first (picking randomly from a pool)
	#once you attempted to stuff as many in, try second largest, then third... etc
	#any remaining tiles will have a coin flip to if they are given a decoration or not.
	
	var every_tile = get_used_cells()
	var non_used = every_tile.filter(decoration_filter)
	non_used.sort()
	var decor_possible_cells = non_used.filter(not_a_decor_cell)
	
	var dict_to_use : Dictionary
	
	print("using shapeset: ",shape_set)
	dict_to_use = decorations.get(shape_set)
	var shape_descriptions = dict_to_use.keys()
	shape_descriptions.sort()
	shape_descriptions.reverse()
	print("sorted in size order: ", shape_descriptions)
	
	if shape_set == "house":
		print("special operation: castle")
		#create a list of all tiles adjecent to open maze tiles
		
		#get a list of all tiles
		#get a list of all tiles IN maze
		#create a list of which contains all tiles that have an IN maze neighbor
		#use a filter func
		var surrounding = non_used.filter(used_neighbor)
		var in_maze = every_tile.filter(part_of_maze)
		#the above arrays are cells we must keep to castle theme
		var keep_pure = surrounding.duplicate()
		keep_pure.append_array(in_maze)
		
		#print([1, 4, 5, 8].filter(func(number): return number % 2 == 0))
		var outside = every_tile.filter(func(cell): return !keep_pure.has(cell))
		
		for cell in outside:
			if [0,0,0,1].pick_random() == 1:
				#if 1 in 4 odds passed, place a random 1 tile decoration
				print("placing mini tile")
				set_cell(cell,4,Vector2i(range(0,16).pick_random(),15))
			else:
				set_cell(cell,1,Vector2i(0,0))
			
		for cell in surrounding:
			if [0,0,0,1].pick_random() == 1:
				#if 1 in 4 odds passed, place a random 1 tile decoration
				print("placing mini tile")
				set_cell(cell,4,Vector2i(range(0,16).pick_random(),what_mini_set.get(shape_sett)))
		#15 7 
		
		#purely here to exit early
		
		return

	#with the keys now sorted in decending order, we can now try putting
	#the largest pattern first
	#for simplicity, we will only attempt in intervals
	
	#to ensure we can place tiles, when trying a coord pair, check if all potential cells are inside NON_USED
	
	#decoration cells now have a bool for "decor" so every time a new decorative element is added
	#calculate a new list of valid places to put things based off the differenc of cells with decor
	#and not used cells
	var still_decorating = true
	#TODO: consider removing FOR loop and replacing it with a WHILE loop so-
	#index doesn't matter
	while(still_decorating):
		#for reccy in shape_descriptions:
		non_used.shuffle()
		for cell in non_used:
			#as time goes on, less cells will be in decor possible cells
			#do a check here to prevent time loss
			if decor_possible_cells.has(cell):
				#check if it, and all possible cells between it and the size of the shape are open (not decorated)
				#if not, pass
				var contained_in = []
				for possible_row in range(cell.y,cell.y + shape_descriptions[0].y):
					for possible_column in range(cell.x,cell.x + shape_descriptions[0].x):
						contained_in.append(Vector2i(possible_column,possible_row))
			#check if all the cells in contained in are in the every_tile array (prevent out of bounds leaks)
			#check if all the cells in contained in are in the non used array (prevents overwriting maze data)
			#check if all the cells in contained in are in the decor possible cells (prevents drawing over decor)
			#if any of the checks fail, move on.
				#check if contained in has ANY CELLS THAT ARE NOT INSIDE VERY_TILE, if so, return TRUE
					#the true here means there is a problem (out of bounds)
				#print("is in bounds: ",!contained_in.any(func(pair): return !every_tile.has(pair)))
				#print("is not maze: ",!contained_in.any(func(pair): return !non_used.has(pair)))
				#print("is not decorated: ",!contained_in.any(func(pair): return !decor_possible_cells.has(pair)))
				if(!contained_in.any(func(pair): return !every_tile.has(pair)) and !contained_in.any(func(pair): return !non_used.has(pair)) and !contained_in.any(func(pair): return !decor_possible_cells.has(pair))):
					#if we are here, we can actually decorate the "contained in" cels
					
					#pick a random index from dict_to_use reccy
					#past the pattern to the top LEFT (or just cell)
					#mark all the cells in contained in as deocrated (subtract this array from decor possible cells)
					var decoration = dict_to_use.get(shape_descriptions[0]).pick_random()
					set_pattern(cell,self.tile_set.get_pattern(decoration))
					decor_possible_cells = non_used.filter(not_a_decor_cell)
					shape_descriptions.shuffle()
					still_decorating = true
				pass
			else:
				still_decorating = false
				continue
	
	#when you reach here all large decoration has been placed
	
	decor_possible_cells = non_used.filter(not_a_decor_cell)
	decor_possible_cells.shuffle()
	
	for cell in decor_possible_cells:
		if [0,0,0,1].pick_random() == 1:
			#if 1 in 4 odds passed, place a random 1 tile decoration
			print("placing mini tile")
			set_cell(cell,4,Vector2i(range(0,16).pick_random(),what_mini_set.get(shape_sett)))
			pass
		pass

func used_neighbor(cell):
	var neighbors = get_surrounding_cells(cell)
	return neighbors.any(part_of_maze)

func part_of_maze(cell):
	var ball = get_cell_tile_data(cell)
	if ball == null:
		return false
	return ball.get_custom_data("N") or ball.get_custom_data("S") or ball.get_custom_data("E") or ball.get_custom_data("W")
	#return true to keep

func decoration_filter(cell):
	var ball = get_cell_tile_data(cell)
	return not(ball.get_custom_data("N") or ball.get_custom_data("S") or ball.get_custom_data("E") or ball.get_custom_data("W"))
	#return true to keep

func not_a_decor_cell(cell):
	var ball = get_cell_tile_data(cell)
	return not(ball.get_custom_data("Decor"))

func _process(delta):
	if debug_switch == true and Input.is_action_just_pressed("ui_focus_next"):
		if remake_if_unsolvable == true:
			
			var solvable = false
			while(solvable == false):
				_make_me_maze(enter_side_set,exit_side_set,shape_set)
			#verify if maze is solvable
			#just create a tree from start
			#check if the end spot is in tree
			#if not, make an entirely new maze
				var treeze = max_tree_from_here($MazeryExtraData.start_tile)
				if treeze.get_all_nodes_as_list().has($MazeryExtraData.end_tile):
					print("VALID :-)")
					solvable = true
				else:
					print("INVALID :-(")
					pass
		else:
			_make_me_maze(enter_side_set,exit_side_set,shape_set)
		proxy_to_tile_map_layer(set_to_use)
		place_fluff(shape_set)
		var end_point = $MazeryExtraData.end_tile
		var start_point = $MazeryExtraData.start_tile
		spawn_player.emit(start_point)
		call_deferred("emit_signal","spawn_enemies",end_point)
		clearing.emit()

func binToInt(array : Array):
	if array[0] == false:
		if array[1] == false:
			return 0
		else:
			return 1
	else:
		if array[1] == false:
			return 2
		else:
			return 3

func dump_old_class():
	hallways.clear()
	hallwayCorner.clear()
	tJunction.clear()
	crossing.clear()
	junk.clear()

func getRandomShape():
	#returns a random shape from shapes dict
	return SHAPES.get(SHAPES.keys().pick_random())

func shapeToVectorPair(topLeft : Vector2i,shapeDimensions : Array):
	#returns two vectors
	var bottomRight = Vector2i(topLeft.x + shapeDimensions[0], topLeft.y + shapeDimensions[1])
	return [topLeft, bottomRight]

func _make_me_maze_again(enterance_side,exit_side):
	if remake_if_unsolvable == true:
		var solvable = false
		while(solvable == false):
			_make_me_maze(enter_side_set,exit_side_set,shape_set)
		#verify if maze is solvable
		#just create a tree from start
		#check if the end spot is in tree
		#if not, make an entirely new maze
			var treeze = max_tree_from_here($MazeryExtraData.start_tile)
			if treeze.get_all_nodes_as_list().has($MazeryExtraData.end_tile):
				print("VALID :-)")
				solvable = true
			else:
				print("INVALID :-(")
				pass
	else:
		_make_me_maze(enter_side_set,exit_side_set,shape_set)
	proxy_to_tile_map_layer(shape_set)
	#_use_pattern()
	place_fluff(shape_set)
	var end_point = $MazeryExtraData.end_tile
	var start_point = $MazeryExtraData.start_tile
	#print(end_point)
	spawn_player.emit(start_point)
	call_deferred("emit_signal","spawn_enemies",end_point, danger_value)

func _make_me_maze(enterance_side: String,exit_side: String, shapeset : String):
	#NOTE: write an exception for the origin tile so the maze is always connected.
	
	#fill world with debug tile (le BLANK tile)
	if shape_set == "woods":
		$Camera2D.zoom = Vector2(0.8,0.8)
	else:
		$Camera2D.zoom = Vector2(1,1)
	clear()
	var rows = num_rows
	var columns = num_columns
#var what_set = {"generic":0,"woods":1,"graveyard":2,"house":0}
	match shapeset:
		"generic":
			rows = num_rows
			columns = num_columns
			set_to_use = what_set.get("generic")
		"woods":
			rows = MAZE_SIZES.get("woods")[1]
			columns = MAZE_SIZES.get("woods")[0]
			set_to_use = what_set.get("woods")
		"graveyard":
			rows = MAZE_SIZES.get("graveyard")[1]
			columns = MAZE_SIZES.get("graveyard")[0]
			set_to_use = what_set.get("graveyard")
		"house":
			rows = MAZE_SIZES.get("house")[1]
			columns = MAZE_SIZES.get("house")[0]
			set_to_use = what_set.get("house")
		_:
			rows = num_rows
			columns = num_columns
			set_to_use = what_set.get(what_set.keys().pick_random())

	proxy = tilemapproxy.new(rows,columns)
	blocks = blocklayer.new(rows,columns)
	var origin_tile = Vector2i(columns/2,rows/2)
	for i in range(rows): #rows
		for j in range(columns): #columns
			if (i == origin_tile.x) and (j == origin_tile.y):
				#print("middle")
				set_cell(Vector2i(j,i),1,Vector2i(0,7))
			else:
				set_cell(Vector2i(j,i),1,Vector2i(4,1))
	#with the actual tile layer done, begin work on proxy
	#proxy.printMe()
	#blocks.printMe()
	#through blocks begin placing random blocks
	#you will need to loop the below until:
		#you can no longer place valid blocks
	#var shape_to_place = getRandomShape()
	#var shape_vectors = shapeToVectorPair(Vector2i(2,3),shape_to_place)
	#print(shape_vectors)
	#print(blocks.check_if_area_free(shape_vectors[0],shape_vectors[1]))
	#blocks.fill_area_with_num(0,shape_vectors[0],shape_vectors[1])
	#blocks.printMe()

	block_placing(origin_tile,shapeset)
	#print("exited block placing. here is the block map")
	#blocks.printMe()
	#print("converting block map into tilemap proxy...")
	#proxy.printMe()

	block_to_tile_proxy()
	#print("done with conversion")
	#proxy.printMe()
	#print("pushing changes to tile map earily: WARNING THIS IS FOR DEBUGGING ONLY")


	#print("connecting sections")
	proxy.connect_sections()

	#print("pushing changes to tile map earily: WARNING THIS IS FOR DEBUGGING ONLY")


	if shapeset == "generic" or shapeset == "woods" or shapeset == "graveyard":
		#print("removing redundent tiles")
		#remove_redundent()
		remove_redundant_new()

		#print("pushing changes to tile map earily: WARNING THIS IS FOR DEBUGGING ONLY")


	if shapeset == "generic" or shapeset == "woods":
		#print("classifying tiles")
		tile_discriminator()
		#print("looking for bad patter: two coners next to eachother")
		killer_corner_duos()
		#print("pushing changes to tile map earily: WARNING THIS IS FOR DEBUGGING ONLY")

		#print("emptying old classified tiles.")
		dump_old_class()

	#if remove_hallway_surrounded == true:
		##print("classifying tiles")
		#tile_discriminator()
		##print("looking for bad pattern: hallways should ALWAYS have polarized neighboors be closed.")
		#killer_hallway_love_handles()
		##print("emptying old classified tiles.")
		#dump_old_class()
		##print("pushing changes to tile map earily: WARNING THIS IS FOR DEBUGGING ONLY")

	#if crossings_to_other == true:
		##print("classifying tiles")
		#tile_discriminator()
		##print("looking for bad pattern: crossings/X should be T junctions or hallways with exceptions\nmade for crossings with neighbors with connections\nto other blocks")
		#killer_crossings_splitter()
		##print("emptying old classified tiles.")
		#dump_old_class()
		##print("pushing changes to tile map earily: WARNING THIS IS FOR DEBUGGING ONLY")


	print("FINISHED FILTERS")
	#region FORCE CONNECTION TO CENTER IF POSSIBLE
	#here would go the exception for the origin tile. force it in manually.
	#put_something_here_please.emit(origin_tile, Vector2i(5,2))
	#get all open neighbors to the center tile
	#connect them to center tile
	#make the center tile the appropriate tile 
	
	for dir in DIRECTIONS:
		#print(dir)
		var neighbor = origin_tile + DIRECTIONS.get(dir)
		if proxy.getpoint(neighbor).has(true):
			#this is a carved path horay
			#connect it to the center point
			proxy.carvePath(origin_tile,dir)
	#endregion
	
	#remove orphans it to harsh. this can remove basically the whole
	#fucking maze. we can work around this by forcing connections
	#between adjecent cells that are NOT connected.
	#if pitty_connections == true:
		#pass
		##for every tile in the proxy
		##grab it's neighbors
		##check if that nieghbor is CARVED but NOT CONNECTED
		##force a connection anyways.
		#var delta_queue = []
		#for row in proxy.myMatrix.size():
			#for slot in proxy.myMatrix[0].size():
				##var data = proxy.getpoint(Vector2i(slot,row))
				#for dir in DIRECTIONS:
					##await get_tree().create_timer(1).timeout
					#var neighbor = Vector2i(slot,row) + DIRECTIONS.get(dir)
					#if inbounds(neighbor) and proxy.carved(Vector2i(slot,row)):
						#var neighborData = proxy.getpoint(neighbor)
						#if proxy.carved(neighbor) and !proxy.connected_to_cell(Vector2i(slot,row),dir):
							##proxy.carvePath(Vector2i(slot,row),dir)
							#delta_queue.append([Vector2i(slot,row),dir])
		#for entry in delta_queue:
			#proxy.carvePath(entry[0],entry[1])

	if remove_orphans == true:
		var start_tiles = []
		var made = false
		#this gets top right
		for row in proxy.myMatrix.size() - 1:
			for slot in proxy.myMatrix[0].size()-1:
				if proxy.carved(Vector2i(slot,row)):
					start_tiles.append(Vector2i(slot,row))
					made = true
					break
			if made == true:
				break
		#get top left
		made = false
		for row in proxy.myMatrix.size() -1 :
			for slot in range(proxy.myMatrix[0].size()-1,-1,-1):
				if proxy.carved(Vector2i(slot,row)):
					start_tiles.append(Vector2i(slot,row))
					made = true
					break
			if made == true:
				break
		#get get bottom right
		made = false
		for row in range(proxy.myMatrix.size()-1,-1,-1):
			for slot in proxy.myMatrix[0].size()-1:
				if proxy.carved(Vector2i(slot,row)):
					start_tiles.append(Vector2i(slot,row))
					made = true
					break
			if made == true:
				break
		#get the bottom left
		made = false
		for row in range(proxy.myMatrix.size()-1,-1,-1):
			for slot in range(proxy.myMatrix[0].size()-1,-1,-1):
				if proxy.carved(Vector2i(slot,row)):
					start_tiles.append(Vector2i(slot,row))
					made = true
					break
			if made == true:
				break
		#test all 4 corners, compare trees
		#get the bigest tree
		#use that one for elimination
		
		#make 4 trees with each coord pair
		var trees = []
		for pair in start_tiles:
			set_cell(pair,0,Vector2i(8,9))
			trees.append(await max_tree_from_here(pair))
		
		#for tree in trees:
			#print(tree.get_all_nodes_as_list().size())
		
		#remove small trees, this should leave us with one biggest tree
		var biggest_tree
		var biggest_num = -1
		for tree in trees:
			if tree.get_all_nodes_as_list().size() > biggest_num:
				biggest_tree = tree
				biggest_num = tree.get_all_nodes_as_list().size()
		#print("biggest tree", biggest_tree.get_all_nodes_as_list().size())
		
		killer_orphans(biggest_tree)
		
	$Camera2D.global_position = map_to_local(origin_tile)
		#print("pushing changes to tile map earily: WARNING THIS IS FOR DEBUGGING ONLY")
	proxy_to_tile_map_layer(set_to_use)
	#if clean_up_crossings == true:
		##the pitty connection step added way to many X-ings
		##get every crossing, preform a flood fill beginning a crossing
		##which is ENTIRELY SURROUNDED BY CARVED CELLS (INCLUDING DIAGONALS)
		##the flood fill should find other crossing who also have the same 
		##condition.
		##tile_discriminator()
		#
		#for cross in crossing:
			#pass
		##once the flood fill is complete, add all the cells in the flood fill
		##to an array to mark their deletion.
		#
		##then uncarve every cell found in the array
		#
		#pass
	if attach_hallways == true:
		#print("emptying old classified tiles, also there is no need to classify anymore")
		dump_old_class()
		#print("attaching enterance door")
		attaching_enterance_or_exit(false,enterance_side)
		#print("attaching exit door")
		attaching_enterance_or_exit(true,exit_side)
		#print("classifying tiles")
		#tile_discriminator()
		#print("looking for bad pattern: hallways should ALWAYS have polarized neighboors be closed.")
		#killer_hallway_love_handles()
		#print("emptying old classified tiles.")
		dump_old_class()
		#print("pushing changes to tile map earily: WARNING THIS IS FOR DEBUGGING ONLY")
		proxy_to_tile_map_layer(set_to_use)
		#proxy.printMe()
	#fill the open array
	#get_used_tiles() to fetch the cells in use
	#loop with get_cell_data to check for if any of the extra data has a true
	#if it has a true, put that cell into open
	#remember that the open array must be cleared when a new maze is generated.
	var exit_node = get_node("exit_zone")
	print("exit_node: ", exit_node)
	exit_node.global_position = map_to_local($MazeryExtraData.end_tile)

	#if tree_clean_up == true:
	##create a tree, find every leaf
	##remove every leaf (BUT THE EXIT)
		#var iteration_count = 0
		#var start_tile = $MazeryExtraData.start_tile
		#var untouched_maze_tree = await max_tree_from_here_but_directed_tho(start_tile)
		#var maze_tree = await max_tree_from_here_but_directed_tho(start_tile)
		#print(maze_tree.my_graph)
		#print("I have this many leaves: ",maze_tree.get_all_leaves())
		#for leaf in maze_tree.get_all_leaves():
			#set_cell(leaf,2,Vector2i(1,0))
		#while(maze_tree.get_all_leaves().size() > 1 and iteration_count <simplcity):
			##the reason for 1 is that we need the exit leaf, it is always a leaf
			##print("num leaves: ",maze_tree.get_all_leaves().size())
			#var all_leaves = maze_tree.get_all_leaves()
			#for leaf in maze_tree.get_all_leaves():
				#set_cell(leaf,2,Vector2i(3,0))
				#await get_tree().create_timer(0.001).timeout
			#for leaf in all_leaves:
				#if leaf != $MazeryExtraData.end_tile:
					#maze_tree.prune(leaf)
			#iteration_count += 1
		#for node in maze_tree.get_all_nodes_as_list():
			#var num_connections = maze_tree.fetch_arb_node(node).size()
			#match num_connections:
				#1:
					#set_cell(node,2,Vector2i(0,1))
				#2:
					#set_cell(node,2,Vector2i(1,1))
				#3:
					#set_cell(node,2,Vector2i(2,1))
				#4:
					#set_cell(node,2,Vector2i(3,1))
				#_:
					#print("this node thinks he is special")
					#print(node)
					#print(maze_tree.fetch_arb_node(node))
					#print(num_connections)
			#pass
		##take the difference between untouched and touch
		#var difference = []
		#var untouched_tree_nodes = untouched_maze_tree.get_all_nodes_as_list()
		#var touched_tree_nodes = maze_tree.get_all_nodes_as_list()
		##for every element in the larger array, check if it is NOT in smaller array
		##if it isn't, put that node in difference.
		#for node in untouched_tree_nodes:
			#if !touched_tree_nodes.has(node):
				#difference.append(node)
		##with the difference, uncarve all tiles in difference
		#for node in difference:
			#proxy.uncarve_all(node)
##endregion

func max_tree_from_here(start):
	var killer_tree = Tree_graph.new(start)
	#begin to do a depth first search
	var visited = []
	var new = killer_tree.get_all_nodes_as_list()
	#print("working")
	while !new.is_empty():
		var node = new.pop_front()
		visited.append(node)
		set_cell(node,2,Vector2i(0,0))
		#await get_tree().create_timer(0.1).timeout
		for dir in DIRECTIONS:
			var neighbor = node + DIRECTIONS.get(dir)
			#has to allow connection to already in tree nodes.
			#the only distinction is that the asked neighbor must NOT be in the node's neighbor list already
			if (!visited.has(neighbor) and inbounds(neighbor) and (proxy.connected_to_cell(node,dir)) and !new.has(neighbor)) or (node == $MazeryExtraData.start_tile and !new.has(neighbor) and !visited.has(neighbor) and inbounds(neighbor)) or (neighbor == $MazeryExtraData.end_tile):
				#its new
				new.append(neighbor)
				killer_tree.add_node(node,neighbor)
			#elif((visited.has(neighbor) and inbounds(neighbor) and inbounds(node) and proxy.connected_to_cell(node,dir)) and !killer_tree.fetch_arb_node(neighbor).has(node)):
				#killer_tree.add_node(node,neighbor)
				#set_cell(neighbor,2,Vector2i(2,0))
		#await get_tree().create_timer(0.01).timeout
	return killer_tree

#func max_tree_from_here_but_directed_tho(start):
	#var killer_tree = Directed_tree.new(start)
	##begin to do a depth first search
	#var visited = []
	#var new = killer_tree.get_all_nodes_as_list()
	##print("working")
	#while !new.is_empty():
		#var node = new.pop_front()
		#visited.append(node)
		#set_cell(node,2,Vector2i(0,0))
		#for dir in DIRECTIONS:
			#var neighbor = node + DIRECTIONS.get(dir)
			##has to allow connection to already in tree nodes.
			##the only distinction is that the asked neighbor must NOT be in the node's neighbor list already
			#if (!visited.has(neighbor) and inbounds(neighbor) and (proxy.connected_to_cell(node,dir)) and !new.has(neighbor)) or (node == $MazeryExtraData.start_tile and !new.has(neighbor) and !visited.has(neighbor) and inbounds(neighbor)) or (neighbor == $MazeryExtraData.end_tile):
				##its new
				#new.append(neighbor)
				#killer_tree.add_node(node,neighbor)
			##elif(visited.has(neighbor) and inbounds(neighbor) and inbounds(node) and proxy.connected_to_cell(node,dir) and !killer_tree.fetch_arb_node(neighbor).has(node)):
				##killer_tree.add_node(node,neighbor)
				##set_cell(node,2,Vector2i(2,0))
		##await get_tree().create_timer(0.01).timeout
	#return killer_tree

func killer_orphans(killer_tree):
	for pair in killer_tree.get_all_nodes_as_list():
		set_cell(pair,0,Vector2i(0,9))
	for row in proxy.myMatrix.size():
		for slot in proxy.myMatrix[0].size():
			if !killer_tree.get_all_nodes_as_list().has(Vector2i(slot,row)):
				if get_cell_tile_data(Vector2i(slot,row)).get_custom_data("N") or get_cell_tile_data(Vector2i(slot,row)).get_custom_data("S") or get_cell_tile_data(Vector2i(slot,row)).get_custom_data("E") or get_cell_tile_data(Vector2i(slot,row)).get_custom_data("W"):
					proxy.uncarve_all(Vector2i(slot,row))
					set_cell(Vector2i(slot,row),0,Vector2i(8,9))

func find_valid_offset(edge : Vector2i,shapedefinition : Array):
	var offset = Vector2i(0,0)
	var able = true
	while(able):
		var worked = blocks.check_if_area_free(edge + shapedefinition[0] + offset, edge + shapedefinition[1] + offset)
		if(worked):
			return offset
		else:
			#offset didn't work.
			#increment by -1
			offset.x -= 1
			if (abs(offset.x) > shapedefinition[1].x):
				offset.x = 0
				offset.y -= 1
			if (abs(offset.y) > shapedefinition[1].y):
				#couldn't find it. give up and return fail
				#print("failed to find offset")
				return Vector2(NAN,NAN)
			#if abs(offset.x) > shapedefinition.x then set offset.x to 0; decrement offset.y by -1
			#if abs(offset.y) > shapedefintion.y then return vector2(-inf,-inf) AKA didnt work

func block_placing(originVect : Vector2i,shapeset):
	print("INSIDE BLOCK_PLACING")
	#origin vector is where the "holy square will go"
	blocks.writepoint(originVect,0)
	var can_place = true
	var block_num = 1
	var used_shape_set : Dictionary
	match shapeset:
		"generic":
			used_shape_set = SHAPES
		"woods":
			used_shape_set = WOODS_SHAPES
		"graveyard":
			used_shape_set = GRAVE_SHAPES
		"house":
			used_shape_set = HOUSE_SHAPES
		_:
			used_shape_set = SHAPES
	print("using shape set: ",shapeset)
	while(can_place):
			#await get_tree().create_timer(1).timeout
			print("I AM STUCK")
		#print("should we be working?", can_place)
		#get a random shape
		#region shape selected. tryign to use it
		#instead shuffle the shapes array and do a for loop
		#when encountering an unusable shape, skip it
		#when we run out of shapes. shuffle and repeat
			var shapes_to_use = used_shape_set.values()
			shapes_to_use.shuffle()
			for shape_to_place in shapes_to_use:
				var shape_vectors = shapeToVectorPair(Vector2i(0,0),shape_to_place)
				#print("shape vectors")
				#print(shape_vectors)
				#shape vector is how we will represent our shape
				
				#find the edges of what we have worked with
				#print("going to find edges")
				var edges = blocks.find_edges(originVect)
				#print("have left find edges")
				
				#pick a random edge cell
				var tile_to_use
				#region using edges until valid found
				edges.shuffle()
				#print(edges)
				for edge in edges:
					tile_to_use = edge
					var offset = find_valid_offset(tile_to_use,shape_vectors)
					#print("working offset: ", offset, " for edge ", tile_to_use)
					if (!is_nan(offset.x)):
						#print("we can place!!")
						can_place = true
						blocks.fill_area_with_num(block_num,offset + shape_vectors[0]+tile_to_use,offset + shape_vectors[1]+tile_to_use)
						#blocks.printMe()
						block_num += 1
						break
					else:
						can_place = false
				#endregion leaving hear means we found a workable edge
				#endregion being here means we finsished with placing a shape
			
	#region debug cancel early
		#print("can we still place? ", can_place)
	#print("exited while loop")
	#endregion

func block_to_tile_proxy():
	for row in blocks.myMatrix.size(): #this is Y
		for cell in blocks.myMatrix[0].size(): #this is X
			#take the cell, look at all neighboors
			#for every neighboor that shares that cell's value. make a connection in that direction
			#thats it.
			for nieghboor in DIRECTIONS:
				if blocks.getpoint(Vector2i(cell,row)) == -1:
					continue
				if inbounds(Vector2i(cell,row) + DIRECTIONS.get(nieghboor)):
					#print("self ",Vector2i(cell,row)," with value ", blocks.getpoint(Vector2i(cell,row)), " neighboor ", Vector2i(cell,row) + DIRECTIONS.get(nieghboor), " with value ",blocks.getpoint(Vector2i(cell,row) + DIRECTIONS.get(nieghboor)), " matching? ",blocks.getpoint(Vector2i(cell,row) + DIRECTIONS.get(nieghboor)) == blocks.getpoint(Vector2i(cell,row)))
					if blocks.getpoint(Vector2i(cell,row)) == blocks.getpoint(Vector2i(cell,row) + DIRECTIONS.get(nieghboor)):
						#print("found valid neighboor :-)")
						proxy.carvePath(Vector2i(cell,row),nieghboor)
			#print("this tile's connections are ",proxy.getpoint(Vector2i(cell,row)))

func inbounds(vect_to_check :Vector2i):
	if (vect_to_check.x >= blocks.myMatrix[0].size() or vect_to_check.y >= blocks.myMatrix.size()) or (vect_to_check.x < 0 or vect_to_check.y < 0):
		return false
	else:
		return true

func proxy_to_tile_map_layer(this_set):
	#for each cell in proxy
	#use the binary trick i though of [N,S,E,W] => [00,00] => [int,int] => find appropriate tile in tileset
	#assign the correct tile values
	for row in proxy.myMatrix.size(): #this is Y
		for cell in proxy.myMatrix[0].size(): #this is X
			var data = proxy.getpoint(Vector2i(cell,row))
			var NS = binToInt([data[0],data[1]])
			var EW = binToInt([data[2],data[3]])
			#print("data ",data," converted into int pair ", binToInt([data[0],data[1]]),binToInt([data[2],data[3]]))
			if this_set is int:
				set_cell(Vector2i(cell,row),this_set,Vector2i(EW,NS))
			else:
				set_cell(Vector2i(cell,row),what_set.get(this_set),Vector2i(EW,NS))
	pass

#func remove_redundent():
	#
	##check:
	##if N block is carved, 
	##all neighbors are carved, 
	##and it and all neighbors belong to same block
	#
	#var notNegOne = []
	#for row in blocks.myMatrix.size(): #this is Y
		#for cell in blocks.myMatrix[0].size(): #this is X
			##print(row, " ", cell)
			#if(blocks.getpoint(Vector2i(cell,row)) != -1):
				#notNegOne.append(Vector2i(cell,row))
	#var notBoarder = []
	#var Boarder = []
	#for cell in notNegOne:
		##if blocks.inbound(cell) == true:
			##notBoarder.append(cell)
		#for dir in DIRECTIONS:
			##print(dir)
			#var neighbor = cell + DIRECTIONS.get(dir)
			#if(not(inbounds(neighbor))):
				#Boarder.append(cell)
#
	##region filter boarder from notNegOne
	#for cell in notNegOne:
		#if(not(Boarder.has(cell))):
			#notBoarder.append(cell)
	##endregion
#
	#var toRemove = []
	#for cell in notBoarder:
		#var edge = true
		#for dir in DIRECTIONS:
			##print(dir)
			#var neighbor = cell + DIRECTIONS.get(dir)
			#if not(blocks.getpoint(cell) == blocks.getpoint(neighbor)):
				#edge = false
		#if (edge == true):
			#toRemove.append(cell)
	#for cell in toRemove:
		#for dir in DIRECTIONS:
			#proxy.uncarve(cell,dir)
		#set_cell(cell,1,Vector2i(0,7))
		
func remove_redundant_new():
	#check:
	#if N block is carved, 
	#all neighbors are carved, 
	#and it and all neighbors belong to same block
	var coord_connections = {}
	for row in blocks.myMatrix.size(): #this is Y
		for cell in blocks.myMatrix[0].size(): #this is X
			coord_connections[Vector2i(cell,row)] = proxy.getpoint(Vector2i(cell,row)).count(true)
	
#print([1, 4, 5, 8].filter(func(number): return number % 2 == 0))

	#get all the keys that are associated with 4
	#while your at it ensure they are carved; dumbass the above already does this
	var filtered_keys = []
	for key in coord_connections.keys():
		if coord_connections.get(key) == 4:
			filtered_keys.append(key)
	
	var eliminate = []
	for key in filtered_keys:
		var keys_block = blocks.getpoint(key)
		var neighbors = [key + DIRECTIONS.get("N"),key + DIRECTIONS.get("S"),key + DIRECTIONS.get("E"),key + DIRECTIONS.get("W")]
		#asking: if any of the neighbors are NOT in the same block as the key (coord pair) ignore
		if neighbors.any(func(bor): return !(blocks.getpoint(bor) == keys_block)):
			pass
		else:
			eliminate.append(key)
	
	for key in eliminate:
		proxy.uncarve_all(key)

func tile_discriminator():
	for row in proxy.myMatrix.size(): #this is Y
		for cell in proxy.myMatrix[0].size(): #this is X
			var data = proxy.getpoint(Vector2i(cell,row))
			#hallway check
			if(data[0] and data[1] and not(data[2]) and not(data[3])) or (not(data[0]) and not(data[1]) and data[2] and data[3]):
				hallways.append(Vector2i(cell,row))
				set_cell(Vector2i(cell,row),1,Vector2i(5,0))
			#hallway corner check
			elif(data[0] and not(data[1]) and not(data[2]) and data[3]) or (data[0] and not(data[1]) and data[2] and not(data[3])) or (not(data[0]) and data[1] and not(data[2]) and data[3]) or (not(data[0]) and data[1] and data[2] and not(data[3])):
				hallwayCorner.append(Vector2i(cell,row))
				set_cell(Vector2i(cell,row),1,Vector2i(6,0))
			elif(data.count(true) == 3):
				tJunction.append(Vector2i(cell,row))
				set_cell(Vector2i(cell,row),1,Vector2i(7,0))
			elif(data.count(true) == 4):
				crossing.append(Vector2i(cell,row))
				set_cell(Vector2i(cell,row),1,Vector2i(5,1))
			elif(data.count(true) == 1):
				nooks.append(Vector2i(cell,row))
				set_cell(Vector2i(cell,row),1,Vector2i(7,1))
			else:
				junk.append(Vector2i(cell,row))
				set_cell(Vector2i(cell,row),1,Vector2i(6,1))
	pass

func killer_corner_duos():
	for corner in hallwayCorner:
		for dir in DIRECTIONS:
			var neighbor = corner + DIRECTIONS.get(dir)
			if hallwayCorner.has(neighbor) and (blocks.getpoint(corner) == blocks.getpoint(neighbor)):
				proxy.uncarve_all(corner)
				proxy.uncarve_all(neighbor)

#func killer_hallway_love_handles():
	#var hallway_count = hallways.size()
	#var previous_hallway_count = -1
	#while(hallway_count != previous_hallway_count):
		#for hall in hallways:
			##figure out facing direction
			##only two possibilities:
				##[1100]
				##[0011]
			##from there eliminate the polarized neighbors
			#var facing = -1
			#if proxy.getpoint(hall)[0] == true: #check north
				#facing = "N"
			#else: #assume east west
				#facing = "E"
			#var polarizeddir = POLARIZED.get(facing) 
			#for dir in polarizeddir:
				#var neighbor = hall + DIRECTIONS.get(dir)
				#if inbounds(neighbor):
					#proxy.uncarve_all(neighbor)
		#dump_old_class()
		#tile_discriminator()
		#previous_hallway_count = hallway_count
		#hallway_count = hallways.size()
		##print("working...")
		##print(previous_hallway_count, " ", hallway_count)
#
#func killer_crossings_splitter():
	##blocks.printMe()
	#for X in crossing:
		##get all X neighbor
		##remove neighbors that are:
		##NOT in the same block map block (this should remove at most 1 usually.
		##then find out what classes those neighbors are
		##if the neighbors ARE NOT 2 hallway corners and 1 T junction: DO NOTHING
		##else: random num from 0 to 1
		##if random num = 0: uncarve T juntion
		##else: uncarve both hallway corners
		#
		##new method
		##get all X neighbors
		##figure out which direction the non-sharing block num is
		##from there assign the rest of the neighbors as "front" "left" "right"
			##NOTE: front is removed alone, left and right are removed *together
		##get a random number 0 to 1
		##if rand number is 0:  uncarve the front neighbor #WARNING: this could cause a total maze seperation
		##if rand number is 1: uncarve left and right neighbors only if it is a coners, if only one is uncarved that is fine
		#var non_fitting_direction
		#for dir in DIRECTIONS:
			#if blocks.getpoint(X + DIRECTIONS.get(dir)) != blocks.getpoint(X):
				#non_fitting_direction = dir
		#var dir_neighbors = {}
		#dir_neighbors.set(OPPOSITES.get(non_fitting_direction), X + DIRECTIONS.get(OPPOSITES.get(non_fitting_direction)))
		#dir_neighbors.set(POLARIZED.get(non_fitting_direction)[0], X + DIRECTIONS.get(POLARIZED.get(non_fitting_direction)[0]))
		#dir_neighbors.set(POLARIZED.get(non_fitting_direction)[1], X + DIRECTIONS.get(POLARIZED.get(non_fitting_direction)[1]))
		#if randi_range(0,1) == 0:
			#proxy.uncarve_all(dir_neighbors.get(OPPOSITES.get(non_fitting_direction)))
		#else:
			#if hallwayCorner.has(dir_neighbors.get(POLARIZED.get(non_fitting_direction)[0])):
				#proxy.uncarve_all(dir_neighbors.get(POLARIZED.get(non_fitting_direction)[0]))
			#if hallwayCorner.has(dir_neighbors.get(POLARIZED.get(non_fitting_direction)[1])):
				#proxy.uncarve_all(dir_neighbors.get(POLARIZED.get(non_fitting_direction)[1]))
		##dump_old_class()
		##tile_discriminator()

func attaching_enterance_or_exit(exit_or_enterance: bool,face : String):
	'''enterance is 0, exit is 1'''
	#do enterance first
	#loop through the approprate side
	
	#figure out what numbers to use for loop
		#grab an array that is just the north face of the maze
		#create a list
		#for every spot in the array that is a valid path, put it in list
		#shuffle list
		#take path out of list
		#attach nook to that side of maze (this will always be out of bounds
		#for both tilemaplayer and block map)
	#print(face)
	var canidate_coords = []
	var accumulator = 0
	var tunnel_flag = false
	if face == "N" or face == "W":
		accumulator = 0
	elif face == "S":
		accumulator = proxy.myMatrix.size() - 1 
	elif face == "E":
		accumulator = proxy.myMatrix[0].size() - 1 
	#this should loop endlessly until it can find a row with a a carved tile
	if face == "N" or face == "S":
		while(canidate_coords.size() == 0):
			for i in range(proxy.myMatrix[0].size()):
				#print(Vector2i(i,accumulator))
				var cell = get_cell_tile_data(Vector2i(i,accumulator))
				if(cell.get_custom_data("N") or cell.get_custom_data("S") or cell.get_custom_data("E") or cell.get_custom_data("W")):
					#it carved. do shit
					canidate_coords.append(Vector2i(i,accumulator))
			if face =="N":
				accumulator += 1
			elif face =="S":
				accumulator -= 1
	#region WE
	if face == "E" or face == "W":
		while(canidate_coords.size() == 0):
			for i in range(proxy.myMatrix.size()):
				#print(Vector2i(i,accumulator))
				var cell = get_cell_tile_data(Vector2i(accumulator,i))
				if(cell.get_custom_data("N") or cell.get_custom_data("S") or cell.get_custom_data("E") or cell.get_custom_data("W")):
					#it carved. do shit
					canidate_coords.append(Vector2i(accumulator,i))
			if face =="W":
				accumulator += 1
			elif face =="E":
				accumulator -= 1
	#endregion
	canidate_coords.shuffle()
	var to_use = canidate_coords.pop_front()
	if face == "N" or face == "S":
		accumulator = to_use.y
	if face == "E" or face == "W":
		accumulator = to_use.x
	var spout_vect = to_use + DIRECTIONS.get(face)
	#in case the acumulator was used, we must return it
	#to it's original value.
	#this will create a hallway
	#this is mainly to ensure all mazes have the entrances
	#and exits are always outside of the bounds of the maze
	#print("if needed: creating filler hallway")
	if face == "N" and accumulator != 0:
		#print("in north hallway maker")
		#accumulator has changed
		#decrement until 0
		#place hallways along the way
		var end_of_way
		var inverse_accumulator = 0
		while(accumulator != 0):
			#print(spout_vect, " + ",Vector2i(0,0 + accumulator), " = ",spout_vect + Vector2i(0,0 + accumulator))
			proxy.carvePath(spout_vect + Vector2i(0,0 + accumulator),"N")
			accumulator -= 1
			inverse_accumulator -= 1
		#print(spout_vect, " - ",Vector2i(0,0 + accumulator), " = ",spout_vect - Vector2i(0,0 + accumulator))
		end_of_way = spout_vect + Vector2i(0,inverse_accumulator)
		#print(end_of_way, " end")
		#print(end_of_way + Vector2i(0,1))
		#region PROBLEM CODE
		set_cell(end_of_way,1,Vector2i(0,1))
		var edge_to_brink = end_of_way + Vector2i(0,1)
		var proxy_to_use = proxy.getpoint(edge_to_brink)
		proxy_to_use[DIRECTION_TO_NUM.get(face)] = true
		proxy.myMatrix[edge_to_brink.y][edge_to_brink.x] = proxy_to_use
		#endregion
		if exit_or_enterance == false:
			put_something_here_please.emit(end_of_way, Vector2i(4,1))
		elif exit_or_enterance == true:
			put_something_here_please.emit(end_of_way, Vector2i(4,2))
		tunnel_flag = true

	elif face == "S" and accumulator != proxy.myMatrix.size() - 1:
		#print("in south hallway maker")
		#accumulator has changed
		#increment until N
		#place hallways along the way
		var end_of_way
		var inverse_accumulator = 0
		while(accumulator != proxy.myMatrix.size() - 1):
			proxy.carvePath(spout_vect - Vector2i(0,proxy.myMatrix.size() - 1 - accumulator),"S")
			#print(spout_vect, " - ",Vector2i(0,proxy.myMatrix.size() - 1 - accumulator), " = ",spout_vect - Vector2i(0,proxy.myMatrix.size() - 1 - accumulator))
			accumulator += 1
			inverse_accumulator += 1
		#print(spout_vect, " - ",Vector2i(0,proxy.myMatrix.size() - 1 - accumulator), " = ",spout_vect - Vector2i(0,proxy.myMatrix.size() - 1 - accumulator))
		end_of_way = spout_vect + Vector2i(0,inverse_accumulator)
		#print(end_of_way, " end")
		set_cell(end_of_way,1,Vector2i(0,2))
		var edge_to_brink = end_of_way - Vector2i(0,1)
		var proxy_to_use = proxy.getpoint(edge_to_brink)
		proxy_to_use[DIRECTION_TO_NUM.get(face)] = true
		proxy.myMatrix[edge_to_brink.y][edge_to_brink.x] = proxy_to_use
		if exit_or_enterance == false:
			put_something_here_please.emit(end_of_way, Vector2i(4,1))
		elif exit_or_enterance == true:
			put_something_here_please.emit(end_of_way, Vector2i(4,2))
		tunnel_flag = true

	elif face == "W" and accumulator != 0:
		#print("in west hallway maker")
		#accumulator has changed
		#decrement until 0
		#place hallways along the way
		var end_of_way
		var inverse_accumulator = 0
		while(accumulator != 0):
			#print(spout_vect, " + ",Vector2i(0,0 + accumulator), " = ",spout_vect + Vector2i(0,0 + accumulator))
			proxy.carvePath(spout_vect + Vector2i(0 + accumulator,0),"W")
			accumulator -= 1
			inverse_accumulator -= 1
		#print(spout_vect, " - ",Vector2i(0,0 + accumulator), " = ",spout_vect - Vector2i(0,0 + accumulator))
		end_of_way = spout_vect + Vector2i(inverse_accumulator,0)
		#print(end_of_way, " end")
		#print(end_of_way + Vector2i(1,0))
		#region PROBLEM CODE
		set_cell(end_of_way,1,Vector2i(2,0))
		var edge_to_brink = end_of_way + Vector2i(1,0)
		var proxy_to_use = proxy.getpoint(edge_to_brink)
		proxy_to_use[DIRECTION_TO_NUM.get(face)] = true
		proxy.myMatrix[edge_to_brink.y][edge_to_brink.x] = proxy_to_use
		#endregion
		if exit_or_enterance == false:
			put_something_here_please.emit(end_of_way, Vector2i(4,1))
		elif exit_or_enterance == true:
			put_something_here_please.emit(end_of_way, Vector2i(4,2))
		tunnel_flag = true

	elif face == "E" and accumulator != proxy.myMatrix[0].size() -1:
		#print("in east hallway maker")
		#accumulator has changed
		#increment until N
		#place hallways along the way
		var end_of_way
		var inverse_accumulator = 0
		while(accumulator != proxy.myMatrix[0].size() - 1):
			proxy.carvePath(spout_vect - Vector2i(proxy.myMatrix[0].size() - 1 - accumulator,0),"E")
			#print(spout_vect, " - ",Vector2i(0,proxy.myMatrix.size() - 1 - accumulator), " = ",spout_vect - Vector2i(0,proxy.myMatrix.size() - 1 - accumulator))
			accumulator += 1
			inverse_accumulator += 1
		#print(spout_vect, " - ",Vector2i(0,proxy.myMatrix.size() - 1 - accumulator), " = ",spout_vect - Vector2i(0,proxy.myMatrix.size() - 1 - accumulator))
		end_of_way = spout_vect + Vector2i(inverse_accumulator,0)
		#print(end_of_way, " end")
		set_cell(end_of_way,1,Vector2i(1,0))
		var edge_to_brink = end_of_way - Vector2i(1,0)
		var proxy_to_use = proxy.getpoint(edge_to_brink)
		proxy_to_use[DIRECTION_TO_NUM.get(face)] = true
		proxy.myMatrix[edge_to_brink.y][edge_to_brink.x] = proxy_to_use
		if exit_or_enterance == false:
			put_something_here_please.emit(end_of_way, Vector2i(4,1))
		elif exit_or_enterance == true:
			put_something_here_please.emit(end_of_way, Vector2i(4,2))
		tunnel_flag = true
	pass
	if tunnel_flag == false:
		#print("placing default")
		#accumulator wasn't changed, proceed normally
		if face == "N":
			set_cell(spout_vect,1,Vector2i(0,1))
		elif face == "S":
			set_cell(spout_vect,1,Vector2i(0,2))
		elif face == "E":
			set_cell(spout_vect,1,Vector2i(1,0))
		elif face == "W":
			set_cell(spout_vect,1,Vector2i(2,0))
		var proxy_to_use = proxy.getpoint(to_use)
		proxy_to_use[DIRECTION_TO_NUM.get(face)] = true
		proxy.myMatrix[to_use.y][to_use.x] = proxy_to_use
		if exit_or_enterance == false:
			put_something_here_please.emit(spout_vect, Vector2i(4,1))
		elif exit_or_enterance == true:
			put_something_here_please.emit(spout_vect, Vector2i(4,2))
	pass

func _on_exit_zone_body_entered(body : Node):
	if not(body.is_in_group("player")):
		print("false alarm")
	else:
		print("maze clear!!")
		set_modulate(Color(0.317, 0.715, 0.0, 1.0))
		clearing.emit()
		await get_tree().create_timer(2).timeout
		
		danger_value += 1
		_make_me_maze_again(enter_side_set,exit_side_set)
		
		shape_set = ["woods","graveyard","house"].pick_random()
		set_modulate(Color(1.0, 1.0, 1.0, 1.0))


func _toggle_exit(open : bool):
	#this will turn on or off detection for the exit (aka goal)
	$exit_zone.monitoring = open
	pass

	#NOTE:
	#here would go all the signals and alerts to the UI
