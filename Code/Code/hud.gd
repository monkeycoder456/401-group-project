extends Control

var lives := 3
var score := 0
var time_left := 180.0


# Point System subject to change.
var enemy_points = {
	"werewolf": 200,
	"vampire": 200,
	"watcher_eye": 300,
	"mummy": 100,
	"zombie": 50,
	"zombie_master": 100
}

var item_points = {
	"stake": 100,
	"revolver": 150,
	"garlic_cross": 250,
	"zombie_book": 250,
	"slab": 70,
	"holy_water": 50,
	"eye_drops": 1000
}

var maze_points = {
	"manor": 1000,
	"woods": 1000,
	"castle": 1000
}


@onready var heart1 = $HeartsContainer/Heart1
@onready var heart2 = $HeartsContainer/Heart2
@onready var heart3 = $HeartsContainer/Heart3

@onready var timer_label = $TimerFrame/TimerLabel
@onready var points_label = $PointsPanel/PointsLabel
@onready var item_icon = $ItemBox/ItemIcon


func _ready():
	update_hearts()
	points_label.text = str(score)
	update_timer()


func _process(delta):
	if time_left > 0:
		time_left -= delta
		update_timer()


func update_timer():
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]


func take_damage():
	lives -= 1
	lives = clamp(lives, 0, 3)
	update_hearts()


func heal():
	lives += 1
	lives = clamp(lives, 0, 3)
	update_hearts()


func update_hearts():
	heart1.visible = lives >= 1
	heart2.visible = lives >= 2
	heart3.visible = lives >= 3


func add_score(amount):
	score += amount
	points_label.text = str(score)


# when the enemy dies
func enemy_killed(enemy_name):
	if enemy_name in enemy_points:
		add_score(enemy_points[enemy_name])


# when player picks up a item
func item_collected(item_name):
	if item_name in item_points:
		add_score(item_points[item_name])


# when he completes the part of the map /level
func level_completed(level_name):
	if level_name in maze_points:
		add_score(maze_points[level_name])


func set_item(texture):
	item_icon.texture = texture


func clear_item():
	item_icon.texture = null
