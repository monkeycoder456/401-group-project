class_name tilemapproxy extends Object
#this whole file IS the class

var rows : int
var columns : int
var myMatrix : Array

#tiles in the proxy are filled with an array of bools.
#[bool,bool,bool,bool]
#[north,south,east,west]
#true == open
#false == closed

var DIRECTIONS = {"N"=Vector2i(0,-1),"S"=Vector2i(0,1),"E"=Vector2i(1,0),"W"=Vector2i(-1,0)}
var ORDINALS = {"NE"=Vector2i(1,-1),"SE"=Vector2i(1,1),"SW"=Vector2i(-1,1),"NW"=Vector2i(-1,-1)}
var DIRECTION_TO_NUM = {"N"=0,"S"=1,"E"=2,"W"=3}
var OPPOSITES = {"N"="S","S"="N","E"="W","W"="E"}
var POLARIZED = {"N"=["W","E"],"S"=["E","W"],"E"=["N","S"],"W"=["S","W"]}

func _init(crows, molumns):
	rows = crows
	columns = molumns
	for i in range(rows):
		myMatrix.append([])
		for j in range(columns):
			myMatrix[i].append([false,false,false,false])

func printMe():
	for rog in myMatrix:
		print(rog)

func getpoint(vector:Vector2i):
	return myMatrix[vector.y][vector.x]

func carvePath(where : Vector2i, cardinal : String):
	#n = 0
	#s = 1
	#e = 2
	#w = 3
	var opposing_where = where + DIRECTIONS.get(cardinal)
	#print("where ", where," my opposor ", opposing_where)
	myMatrix[where.y][where.x][DIRECTION_TO_NUM.get(cardinal)] = true
	myMatrix[opposing_where.y][opposing_where.x][DIRECTION_TO_NUM.get(OPPOSITES.get(cardinal))] = true
	pass

func uncarve(where : Vector2i, cardinal :String):
	#n = 0
	#s = 1
	#e = 2
	#w = 3
	var opposing_where = where + DIRECTIONS.get(cardinal)
	#print("where ", where," my opposor ", opposing_where)
	myMatrix[where.y][where.x][DIRECTION_TO_NUM.get(cardinal)] = false
	myMatrix[opposing_where.y][opposing_where.x][DIRECTION_TO_NUM.get(OPPOSITES.get(cardinal))] = false
	pass

func uncarve_all(where):
	for dir in DIRECTION_TO_NUM:
		myMatrix[where.y][where.x][DIRECTION_TO_NUM.get(dir)] = false
		if inbounds(Vector2i(where.x + DIRECTIONS.get(dir).x,where.y + DIRECTIONS.get(dir).y)):
			myMatrix[where.y + DIRECTIONS.get(dir).y][where.x + DIRECTIONS.get(dir).x][DIRECTION_TO_NUM.get(OPPOSITES.get(dir))] = false


func connect_sections():
	for row in myMatrix.size(): #this is Y
		for cell in myMatrix[0].size(): #this is X
			#print(row, " ", cell)
			if(carved(Vector2i(cell,row))):
				for dir in DIRECTIONS:
					var able_flag = true
					#print(dir)
					var neighbor = Vector2i(cell,row) + DIRECTIONS.get(dir) #this is for the neighbors coords
					if inbounds(neighbor) and !connected_to_cell(Vector2i(cell,row),dir) and carved(neighbor):
						#print(inbounds(neighbor),!connected_to_cell(Vector2i(cell,row),dir),carved(neighbor))
						var leftright_neighdir = [POLARIZED.get(dir)[0],POLARIZED.get(dir)[1]]
						var leftright_neighbors = [Vector2i(cell,row) + DIRECTIONS.get(leftright_neighdir[0]),Vector2i(cell,row) + DIRECTIONS.get(leftright_neighdir[1])]
						#print(leftright_neighbors)
						for twinbor in leftright_neighbors:
							if inbounds(twinbor):
								if(getpoint(twinbor)[DIRECTION_TO_NUM.get(dir)]== true):
									able_flag = false
						if able_flag == true:
							carvePath(Vector2i(cell,row),dir)

func connected_to_cell(cell : Vector2i, dir:String):
	if(myMatrix[cell.y][cell.x][DIRECTION_TO_NUM.get(dir)] and myMatrix[cell.y + DIRECTIONS.get(dir).y][cell.x + DIRECTIONS.get(dir).x][DIRECTION_TO_NUM.get(OPPOSITES.get(dir))]):
		return true
	else:
		return false

func carved(cell : Vector2i):
	#print(myMatrix[cell.y][cell.x])
	if myMatrix[cell.y][cell.x].find(true) == -1:
		return false
	else:
		return true

func inbounds(vect_to_check :Vector2i):
	#print("checking if inbounds")
	if (vect_to_check.x >= myMatrix[0].size() or vect_to_check.y >= myMatrix.size()) or (vect_to_check.x < 0 or vect_to_check.y < 0):
		#print("not in bounds")
		return false
	else:
		return true

func giverow(row_num):
	return myMatrix[row_num].copy()

func givecolumn(column_num):
	var list : Array
	for i in range(rows):
		list.append(myMatrix[i][column_num])
	return list
