class_name crate extends Node2D


var state = "notBroken"
var player_in_area = false

var coin = preload("res://scenes/coin.tscn")

func _process(delta):
	if state == "Not Broken":
		$AnimatedSprite2D.play("Not Broken")
	if state == "Broken":
		$AnimatedSprite2D.play("Broken")
		if player_in_area:
			if Input.is_action_just_pressed("e"):
				state = "Broken"
				

func _on_breakable_area_body_entered(body) :
	for group in get_groups():
		if not str(group).begins_with("player"):
			player_in_area = true
			

func _on_breakable_area_body_exited(body) :
	for group in get_groups():
		if not str(group).begins_with("player"):
			player_in_area = false
	

func drop_coin():
	var coin_instance = coin.instanciate()
	coin_instance.global_position = $Marker2D.global_position
	get_parent().add_child(coin_instance)
