class_name enemyHandler extends Sprite2D


var player_reference : Node
var the_opposite : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent() is Mazery:
		the_opposite = await get_parent().player_handler
		print("I have player handler reference")
		player_reference = await the_opposite.player_node
		print("I have player reference")
		print(player_reference)
	else:
		print("alone...")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
