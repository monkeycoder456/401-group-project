class_name blocklayer extends Node
#for aid in maze generation
var rows : int
var columns : int
var myMatrix : Array
#-1 equals blank tile
# literally any other number means filled tile.

func _init(crows, molumns):
	rows = crows
	columns = molumns
	for i in range(rows):
		myMatrix.append([])
		for j in range(columns):
			myMatrix[i].append(-1)

func printMe():
	for rog in myMatrix:
		print(rog)
	print("boo")

func getpoint(vector:Vector2i):
	return myMatrix[vector.y][vector.x]

func writepoint(vector: Vector2i, symbol):
	myMatrix[vector.y][vector.x] = symbol

func check_if_spot_free(vector : Vector2i):
	if (vector.x >= myMatrix[0].size() or vector.y >= myMatrix.size()) or (vector.x < 0 or vector.y < 0):
		return false
	if(getpoint(vector) == -1):
		return true
	else:
		return false

func inbound(vector : Vector2i):
	if (vector.x >= myMatrix[0].size() or vector.y >= myMatrix.size()) or (vector.x < 0 or vector.y < 0):
		return false
	else:
		return true

func check_if_area_free(topleft : Vector2i, bottomright : Vector2i):
	#checks if the asked area is free, INCLUSIVE ON BOTH ENDS
	#if true, free
	#if false, not free
	for i in range(bottomright.y - topleft.y):
		#NOTE: ensure topleft is applied as offset
		#print(i + topleft.y)
		for j in range(bottomright.x - topleft.x):
			#NOTE: ensure topleft is applied as offset
			#print(j + topleft.x)
			if(check_if_spot_free(Vector2i(j + topleft.x,i + topleft.y)) == false):
				return false
			else:
				pass
	return true

func find_edges(origin:Vector2i):
	#this is baby's first flood fill algorithm
	#beginning from some origin:
	#check all neighboors
	#if the neighboor has -1, put it in edge array
	#if the neighboor doesn't have -1, put it in newly visited
	#put the current index/point we are in into visited array
	var edge : Array # stack
	var new : Array # stack
	var out : Array # stack, explicitly for out of bounds
	var used : Array # stack

	# NORTH, SOUTH, EAST, WEST
	var neighboors = [Vector2i(0,-1),Vector2i(0,1),Vector2i(1,0),Vector2i(-1,0)]

	new.push_front(origin)
	while(new.is_empty() != true):
		#print("stuck in edge finder")
		#print("new spots: ",new)
		var examiner = new.pop_front()
		used.push_front(examiner)
		#grab all the neighboors
		for direction in neighboors:
			#print("stuck in for each neighboor loop")
			var new_vect = examiner + direction
			if  !out.has(new_vect) and !used.has(new_vect):
				#it is not visited, do care
				#check if -1
				#print("new_vector: ", new_vect)
				if (new_vect.x >= myMatrix[0].size() or new_vect.y >= myMatrix.size()) or (new_vect.x < 0 or new_vect.y < 0):
					#print("ignore. too big")
					out.append(new_vect)
				elif myMatrix[new_vect.y][new_vect.x] == -1:
					#print("it is an edge")
					#we found an edge
					if !edge.has(new_vect):
						edge.append(new_vect)
				else:
					#print("it is inside the shape")
					#we found something in
					if !new.has(new_vect):
						new.push_back(new_vect)
		#print("on the inside")
		#print(used.size())
		##print(used)
		#print("on the outside")
		#print(edge.size())
	#print("leaving edge finder")
	return edge

func fill_area_with_num(num : int, topleft : Vector2,bottomright : Vector2i):
	for i in range(bottomright.y - topleft.y):
		#NOTE: ensure topleft is applied as offset
		#print(i + topleft.y)
		for j in range(bottomright.x - topleft.x):
			#NOTE: ensure topleft is applied as offset
			#print("Writing to...")
			#print(Vector2i(j + topleft.x,i + topleft.y))
			myMatrix[i + topleft.y][j + topleft.x] = num
