# This script creates a fear aura around the player that affects nearby enemies
extends Area2D

# Duration in seconds that the aura stays active
@export var duration: float = 10.0

# Reference to the player node
var player

func _ready():
	# Wait one frame to ensure all nodes like the  player are loaded into the scene
	await get_tree().process_frame
	
	# Find the player using the "player" group
	player = get_tree().get_first_node_in_group("player")

	# Ensure the aura renders above most objects
	z_index = 10

	# Configure and start the timer for the aura duration
	$Timer.wait_time = duration
	$Timer.start()

	# Request initial draw of the aura
	queue_redraw()

func _process(delta):
	# Continuously follow the player's position if the player exists
	if player != null:
		global_position = player.global_position
	
	# Redraw every frame to keep visuals updated
	queue_redraw()

func _draw():
	# Draw a semi-transparent yellow circle representing the fear radius
	draw_circle(Vector2.ZERO, 200, Color(1, 1, 0, 0.3))

func _on_timer_timeout():
	# When the timer ends, remove this aura from the scene
	queue_free()

func _on_body_entered(body):
	# Debug: log when a body enters the aura
	print("ENTERED:", body.name)

	# If the body is an enemy and supports fear behavior, trigger fear mode
	if body.is_in_group("enemies") and body.has_method("enter_fear_mode"):
		body.enter_fear_mode(self)

func _on_body_exited(body):
	# Debug: log when a body leaves the aura
	print("EXITED:", body.name)

	# If the body is an enemy and supports fear behavior, disable fear mode
	if body.is_in_group("enemies") and body.has_method("exit_fear_mode"):
		body.exit_fear_mode()
