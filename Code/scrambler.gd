extends Node2D
var tile_mappy
# Called when the node enters the scene tree for the first time.
func _ready():
	tile_mappy = get_parent()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#create a tile with tiledata and write it constantly to the parent
	
	tile_mappy.set_cell(Vector2i(0,-3),1,Vector2i(0,3))
	tile_mappy.set_cell(Vector2i(0,-2),1,Vector2i(0,3))
	#tile_mappy.update_internals()
	pass
