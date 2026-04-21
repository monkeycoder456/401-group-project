class_name Crate extends GenericMazeEntity
#Drops loot for the player to use against the swarm of enemies

signal points
var point_total = 100
var myItem : PackedScene 
var player_in_area = false
var is_destroyed = false


func _ready():
	print("Crate in ready func")
	print("Crate ready at: ", global_position)
	print("Crate has finished waiting")
	

func _process(delta):
	
	pass

func _on_area_2d_body_entered(body: Node2D):
	if body.is_in_group("player"):
		print("Player has touched a crate, destroying...")
		_destroy()
		
func _destroy():
	if is_destroyed:
		return
	is_destroyed = true

	$AnimatedSprite2D.play("Broken")

	if myItem:
		var currentItem = myItem.instantiate()
		currentItem.global_position = global_position
		currentItem.add_to_group("item")
		get_parent().add_child(currentItem)

	await get_tree().create_timer(0.3).timeout
	queue_free()
	
func _force_destroy():
	await _destroy()
	
	
#func _on_breakable_area_body_exited(body) :
#	for group in get_groups():
#		if not str(group).begins_with("player"):
#			player_in_area = false

#func drop_coin():
#	var coin_instance = coin.instanciate()
#	coin_instance.global_position = $Marker2D.global_position
#	get_parent().add_child(coin_instance)
	
