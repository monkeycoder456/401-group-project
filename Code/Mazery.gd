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


@export var danger_value := 10
@export var my_seed : int
@export var debug_switch := false
@export var remove_brother_surrounded := true
@export var remove_brother_corners := true
@export var remove_hallway_surrounded := true
@export var crossings_to_other := true
@export var remove_orphans := true
@export var attach_hallways := true
@export var num_rows := 20
@export var num_columns := 20
@export_enum("N", "S", "E","W") var enter_side_set: String
@export_enum("N", "S", "E","W") var exit_side_set: String

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


signal put_something_here_please
signal spawn_enemies
signal spawn_items
signal begin_slime
signal spawn_player
signal clearing

func _ready():
	
	print("I have entered scene tree: maze")
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
	_make_me_maze(enter_side_set,exit_side_set)

	#print(get_children())
	#print(get_child(1))
	#print($MazeryExtraData)
	
	var end_point = $MazeryExtraData.end_tile
	var start_point = $MazeryExtraData.start_tile
	print(end_point)
	spawn_player.emit(start_point)
	#spawn_enemies.emit(end_point)
	call_deferred("emit_signal","spawn_enemies",end_point)

 #Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if debug_switch == true and Input.is_action_just_pressed("ui_focus_next"):
		_make_me_maze(enter_side_set,exit_side_set)
		var end_point = $MazeryExtraData.end_tile
		var start_point = $MazeryExtraData.start_tile
		spawn_player.emit(start_point)
		call_deferred("emit_signal","spawn_enemies",end_point)

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

func _make_me_maze(enterance_side: String,exit_side: String):
	#fill world with debug tile (le BLANK tile)
	clear()
	clearing.emit()
	var rows = num_rows
	var columns = num_columns
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
	
	block_placing(origin_tile)
	#print("exited block placing. here is the block map")
	#blocks.printMe()
	#print("converting block map into tilemap proxy...")
	#proxy.printMe()
	block_to_tile_proxy()
	#print("done with conversion")
	#proxy.printMe()
	#print("pushing changes to tile map earily: WARNING THIS IS FOR DEBUGGING ONLY")
	proxy_to_tile_map_layer()
	#print("connecting sections")
	proxy.connect_sections()
	#print("pushing changes to tile map earily: WARNING THIS IS FOR DEBUGGING ONLY")
	proxy_to_tile_map_layer()
	if remove_brother_surrounded == true:
		#print("removing redundent tiles")
		remove_redundent()
		#print("pushing changes to tile map earily: WARNING THIS IS FOR DEBUGGING ONLY")
		proxy_to_tile_map_layer()
	if remove_brother_corners == true:
		#print("classifying tiles")
		tile_discriminator()
		#print("looking for bad patter: two coners next to eachother")
		killer_corner_duos()
		#print("pushing changes to tile map earily: WARNING THIS IS FOR DEBUGGING ONLY")
		proxy_to_tile_map_layer()
		#print("emptying old classified tiles.")
		dump_old_class()
	if remove_hallway_surrounded == true:
		#print("classifying tiles")
		tile_discriminator()
		#print("looking for bad pattern: hallways should ALWAYS have polarized neighboors be closed.")
		killer_hallway_love_handles()
		#print("emptying old classified tiles.")
		dump_old_class()
		#print("pushing changes to tile map earily: WARNING THIS IS FOR DEBUGGING ONLY")
		proxy_to_tile_map_layer()
	if crossings_to_other == true:
		#print("classifying tiles")
		tile_discriminator()
		#print("looking for bad pattern: crossings/X should be T junctions or hallways with exceptions\nmade for crossings with neighbors with connections\nto other blocks")
		killer_crossings_splitter()
		#print("emptying old classified tiles.")
		dump_old_class()
		#print("pushing changes to tile map earily: WARNING THIS IS FOR DEBUGGING ONLY")
		proxy_to_tile_map_layer()
	if remove_orphans == true:
		var start_tile
		var setted = false
		for row in proxy.myMatrix.size():
			for slot in proxy.myMatrix[0].size():
				if proxy.carved(Vector2i(slot,row)):
					start_tile = Vector2i(slot,row)
					setted = true
					break
			if setted == true:
				break
		killer_orphans(start_tile)
		#print("pushing changes to tile map earily: WARNING THIS IS FOR DEBUGGING ONLY")
		proxy_to_tile_map_layer()
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
		proxy_to_tile_map_layer()
		#proxy.printMe()

func killer_orphans(start):
	var killer_tree = Tree_graph.new(start)
	#begin to do a depth first search
	var visited = []
	var new = killer_tree.get_all_nodes_as_list()
	var accumulator = 0
	#print("working")
	while !new.is_empty():
		var node = new.pop_front()
		visited.append(node)
		for dir in DIRECTIONS:
			var neighbor = node + DIRECTIONS.get(dir)
			if !visited.has(neighbor) and inbounds(neighbor) and (proxy.connected_to_cell(node,dir)) and !new.has(neighbor):
				#its new
				new.append(neighbor)
				killer_tree.add_node(node,neighbor)
		#print(visited.size())
		#print(new.size())
		accumulator += 1
	#print(killer_tree.get_all_nodes_as_list().size())
	#print_rich("[color=red]acummulator value: [/color]", accumulator)
	#print("varifying if the tree is correect")
	for pair in killer_tree.get_all_nodes_as_list():
		set_cell(pair,1,Vector2i(0,7))
	for row in proxy.myMatrix.size():
		for slot in proxy.myMatrix[0].size():
			if !killer_tree.get_all_nodes_as_list().has(Vector2i(slot,row)):
				proxy.uncarve_all(Vector2i(slot,row))

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

func block_placing(originVect : Vector2i):
	#origin vector is where the "holy square will go"
	blocks.writepoint(originVect,0)
	var can_place = true
	var block_num = 1
	while(can_place):
		#print("should we be working?", can_place)
		#get a random shape
		#region shape selected. tryign to use it
		#instead shuffle the shapes array and do a for loop
		#when encountering an unusable shape, skip it
		#when we run out of shapes. shuffle and repeat
			var shapes_to_use = SHAPES.values()
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

func proxy_to_tile_map_layer():
	#for each cell in proxy
	#use the binary trick i though of [N,S,E,W] => [00,00] => [int,int] => find appropriate tile in tileset
	#assign the correct tile values
	for row in proxy.myMatrix.size(): #this is Y
		for cell in proxy.myMatrix[0].size(): #this is X
			var data = proxy.getpoint(Vector2i(cell,row))
			var NS = binToInt([data[0],data[1]])
			var EW = binToInt([data[2],data[3]])
			#print("data ",data," converted into int pair ", binToInt([data[0],data[1]]),binToInt([data[2],data[3]]))
			set_cell(Vector2i(cell,row),1,Vector2i(EW,NS))
	pass

func remove_redundent():
	var notNegOne = []
	for row in blocks.myMatrix.size(): #this is Y
		for cell in blocks.myMatrix[0].size(): #this is X
			#print(row, " ", cell)
			if(blocks.getpoint(Vector2i(cell,row)) != -1):
				notNegOne.append(Vector2i(cell,row))
	var notBoarder = []
	var Boarder = []
	for cell in notNegOne:
		#if blocks.inbound(cell) == true:
			#notBoarder.append(cell)
		for dir in DIRECTIONS:
			#print(dir)
			var neighbor = cell + DIRECTIONS.get(dir)
			if(not(inbounds(neighbor))):
				Boarder.append(cell)

	#region filter boarder from notNegOne
	for cell in notNegOne:
		if(not(Boarder.has(cell))):
			notBoarder.append(cell)
	#endregion

	var toRemove = []
	for cell in notBoarder:
		var edge = true
		for dir in DIRECTIONS:
			#print(dir)
			var neighbor = cell + DIRECTIONS.get(dir)
			if not(blocks.getpoint(cell) == blocks.getpoint(neighbor)):
				edge = false
		if (edge == true):
			toRemove.append(cell)
	for cell in toRemove:
		for dir in DIRECTIONS:
			proxy.uncarve(cell,dir)
		set_cell(cell,1,Vector2i(0,7))

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
			elif((not(data[0]) and data[1] and data[2] and data[3]) or (data[0] and not(data[1]) and data[2] and data[3]) or (data[0] and data[1] and not(data[2]) and data[3]) or (data[0] and data[1] and data[2] and not(data[3]))):
				tJunction.append(Vector2i(cell,row))
				set_cell(Vector2i(cell,row),1,Vector2i(7,0))
			elif(data[0] and data[1] and data[2] and data[3]):
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

func killer_hallway_love_handles():
	var hallway_count = hallways.size()
	var previous_hallway_count = -1
	while(hallway_count != previous_hallway_count):
		for hall in hallways:
			#figure out facing direction
			#only two possibilities:
				#[1100]
				#[0011]
			#from there eliminate the polarized neighbors
			var facing = -1
			if proxy.getpoint(hall)[0] == true: #check north
				facing = "N"
			else: #assume east west
				facing = "E"
			var polarizeddir = POLARIZED.get(facing) 
			for dir in polarizeddir:
				var neighbor = hall + DIRECTIONS.get(dir)
				if inbounds(neighbor):
					proxy.uncarve_all(neighbor)
		dump_old_class()
		tile_discriminator()
		previous_hallway_count = hallway_count
		hallway_count = hallways.size()
		#print("working...")
		#print(previous_hallway_count, " ", hallway_count)

func killer_crossings_splitter():
	#blocks.printMe()
	for X in crossing:
		#get all X neighbor
		#remove neighbors that are:
		#NOT in the same block map block (this should remove at most 1 usually.
		#then find out what classes those neighbors are
		#if the neighbors ARE NOT 2 hallway corners and 1 T junction: DO NOTHING
		#else: random num from 0 to 1
		#if random num = 0: uncarve T juntion
		#else: uncarve both hallway corners
		
		#new method
		#get all X neighbors
		#figure out which direction the non-sharing block num is
		#from there assign the rest of the neighbors as "front" "left" "right"
			#NOTE: front is removed alone, left and right are removed *together
		#get a random number 0 to 1
		#if rand number is 0:  uncarve the front neighbor #WARNING: this could cause a total maze seperation
		#if rand number is 1: uncarve left and right neighbors only if it is a coners, if only one is uncarved that is fine
		var non_fitting_direction
		for dir in DIRECTIONS:
			if blocks.getpoint(X + DIRECTIONS.get(dir)) != blocks.getpoint(X):
				non_fitting_direction = dir
		var dir_neighbors = {}
		dir_neighbors.set(OPPOSITES.get(non_fitting_direction), X + DIRECTIONS.get(OPPOSITES.get(non_fitting_direction)))
		dir_neighbors.set(POLARIZED.get(non_fitting_direction)[0], X + DIRECTIONS.get(POLARIZED.get(non_fitting_direction)[0]))
		dir_neighbors.set(POLARIZED.get(non_fitting_direction)[1], X + DIRECTIONS.get(POLARIZED.get(non_fitting_direction)[1]))
		if randi_range(0,1) == 0:
			proxy.uncarve_all(dir_neighbors.get(OPPOSITES.get(non_fitting_direction)))
		else:
			if hallwayCorner.has(dir_neighbors.get(POLARIZED.get(non_fitting_direction)[0])):
				proxy.uncarve_all(dir_neighbors.get(POLARIZED.get(non_fitting_direction)[0]))
			if hallwayCorner.has(dir_neighbors.get(POLARIZED.get(non_fitting_direction)[1])):
				proxy.uncarve_all(dir_neighbors.get(POLARIZED.get(non_fitting_direction)[1]))
		#dump_old_class()
		#tile_discriminator()

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
