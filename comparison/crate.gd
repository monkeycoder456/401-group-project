class_name Crate extends GenericMazeEntity
#Drops loot for the player to use against the swarm of enemies

signal points 
var point_total = 100
var myItem : PackedScene 
var player_in_area = false
var is_destroyed = false


func _ready():
	#Tells where the crates are ready 
	#and if crates are ready to be spawned
	print("Crate in ready func")
	print("Crate ready at: ", global_position)
	print("Crate has finished waiting")
	

func _process(delta):
	#Nothing happens here 
	pass

func _on_area_2d_body_entered(body: Node2D):
	#When the player touches the crate,
	#Check if body is in the player group,
	#if so activate _destroy
	if body.is_in_group("player"):
		print("Player has touched a crate, destroying...")
		_destroy()
		
func _destroy():
	#When the item is touched it will run the destroy function
	if is_destroyed:
		return
	is_destroyed = true

	$AnimatedSprite2D.play("Broken")
	#plays the broken animatioon

	if myItem:
		var currentItem = myItem.instantiate()
		currentItem.global_position = global_position
		currentItem.add_to_group("item")
		get_parent().add_child(currentItem)

	await get_tree().create_timer(0.3).timeout
	queue_free()
	
func _force_destroy():
	await _destroy()
