class_name EnemyHandler extends Label


#to spawn enemies
#CRITICAL: after signal recieved
#have a spawn queue
#when randomly selecting enemies
#check if the randomly picked enemy fits within the danger allowance
#if it does, add it to the spawn queue
#if not, then add it anyways and halt looping
#the spawn queue mainly to have mummy always spawn last, as to not get in the way.
#the spawn queue also allows to slowly spawn them one by one if wanted.

#if an enemy is defeated
#delete that isntance of the enemy and add it to spawn queue

enum enemy_names {Zombie,Zombie_Master,Vampire,Werewolf,Mummy,Peeper}
enum placeHolder {PlaceHolder}

enum states {WaitingToBegin,FillingQueue,SpawningEnemy,WaitingForTimer,EmptyQueue}

#enemies are added to the back, and popped from the front
#after a time interval, the front enemy is popped and added to the game
var enemy_spawn_queue = []

#enemies are added to this at the very start of the level
#depending on the danger value
var enemy_pool = []

#this is an array of bools to track if enemies in the above array are 
#"enreal" or spawned in physically into the maze
#this is so that if they are not "enreal" they should be spawned
#0 = not spawned
#1 = spawned
#NOTE: this can arguably be removed but whatever
var enemy_real = []

#NOTE: swap this for true when other enemies are out
var use_placeholder = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func do_thing():
	pass
