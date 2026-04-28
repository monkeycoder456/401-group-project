extends Area2D
signal coin_collected(points)


var value := 10
var is_obtained = false



func _on_body_entered(body):
	print("Something entered:", body.name)

	if body.is_in_group("player"):
		print("Coin collected")
		_obtained()
		
		
func _obtained():
	#play obtained animation
	#vanish after animation ends 
	queue_free()
	
	
func _force_destroy():
	#force the destroy animation once the level ends 
	await _obtained()
