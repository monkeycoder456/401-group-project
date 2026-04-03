class_name MazeryExtraData extends TileMapLayer

var start_tile := Vector2i(-1,-1)
var end_tile := Vector2i(-1,-1)

const start_set = Vector2i(4,1)
const end_set = Vector2i(4,2)

signal data_train

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func assign(where :Vector2i, what: Vector2i):
	if what == start_set:
		start_tile = where
	elif what == end_set:
		end_tile = where
	set_cell(where,2,what)
	
func dump_old_assignments():
	start_tile = Vector2i(-1,-1)
	end_tile = Vector2i(-1,-1)
	clear()
