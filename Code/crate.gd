class_name Crate extends GenericMazeEntity
#Drops loot for the player to use against the swarm of enemies

signal points
var point_total = 100
var myItem : PackedScene 
var state = "notBroken"
var player_in_area = false


func _ready():
	print("Crate in ready func")
	print("My current_cell is: ", current_cell)
	
	#current_cell = await get_parent().spawn_items
	#target_position = tilemap.map_to_local(current_cell)
	#global_position = target_position
	
	#print("My current_cell is: ", current_cell)
	
	print("Crate has finished waiting")
	

func _process(delta):
	#if state == "Not Broken":
	#	$AnimatedSprite2D.play("Not Broken")
	#if state == "Broken":
	#	$AnimatedSprite2D.play("Broken")
	#	if player_in_area:
	#		 #On contact instead
	#		state = "Broken"
	pass

func _who_touched_me(node: Node2D):
	if node.is_in_group("player"):
		print("Player has touched a crate, destroying...")
		_destroy()
		

func _destroy():
	$AnimatedSprite2D.play("Broken")
	if myItem:
		var currentItem = myItem.instantiate()
		currentItem.global_position = global_position
		get_parent().add_child(currentItem)
	else:
		print("Warning: myItem is null")
	
	await $AnimatedSprite2D.animation_finished 
	queue_free()
	
func _force_destroy():
	$AnimatedSprite2D.play("Broken")
	await $AnimatedSprite2D.animation_finished 
	queue_free()
	
	

#func _on_area_2d_body_entered(body: Node2D) -> void:
#	if body.is_in_group("player"):
#		print("player touch crate")
#		pass

#func _on_breakable_area_body_entered(body) :
#	for group in get_groups():
#		if not str(group).begins_with("player"):
#			player_in_area = true

#func _on_breakable_area_body_exited(body) :
#	for group in get_groups():
#		if not str(group).begins_with("player"):
#			player_in_area = false

#func drop_coin():
#	var coin_instance = coin.instanciate()
#	coin_instance.global_position = $Marker2D.global_position
#	get_parent().add_child(coin_instance)
	
