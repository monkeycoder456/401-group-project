extends Area2D

@export var duration: float = 10.0

var player

func _ready():
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

	z_index = 10

	$Timer.wait_time = duration
	$Timer.start()
	queue_redraw()

func _process(delta):
	if player != null:
		global_position = player.global_position
	queue_redraw()

func _draw():
	draw_circle(Vector2.ZERO, 200, Color(1, 1, 0, 0.3))

func _on_timer_timeout():
	queue_free()

func _on_body_entered(body):
	print("ENTERED:", body.name)
	if body.is_in_group("enemies") and body.has_method("enter_fear_mode"):
		body.enter_fear_mode(self)

func _on_body_exited(body):
	print("EXITED:", body.name)
	if body.is_in_group("enemies") and body.has_method("exit_fear_mode"):
		body.exit_fear_mode()
