class_name mummy_segment_caboose extends "res://code/GenericMazeEntity.gd"

var wrapsScene = preload("res://scenes/wraps.tscn")
var sarcScene = preload("res://scenes/sarc.tscn")

var mum_length : int
var old_position : Vector2i
var has_tail = false
var alreadyHandledShit = false

signal move_ahead_seg
signal create_new_seg
signal how_long_are_we

func _ready():
	var something_got
	something_got = await get_parent().create_new_seg
	mum_length = await get_parent().how_long_are_we
	#print("finished waiting for create_new_seg and how_long_are_we")
	#print("sarc finish")
	#print(something_got)
	#print("recieved signal")
	moving = true
	var local_pos = tilemap.to_local(global_position)
	current_cell = something_got[0]
	target_position = tilemap.map_to_local(current_cell)
	get_parent().create_new_seg.connect(_extend)
	_followInFront()
	pass

func _physics_process(delta):
	#print("my ID is :", self)
	#print("Do I have a tail? ", has_tail, "MM")
	if moving:
		#global_position = global_position.move_toward(target_position ,move_speed * delta)
		global_position = target_position
		_followInFront()
		#print("segment emitting signal, OLD, NEW: ", old_position," ", tilemap.local_to_map(target_position))
		$AnimatedSprite2D.play("bobble")
		#print("I am back in the physics process")

func _followInFront():
	old_position = tilemap.local_to_map(target_position)
	var new_targ
	if get_parent() is Mummy:
		new_targ = await get_parent().move_ahead
		#print("got mummy command")
	elif get_parent() is mummy_segment:
		new_targ = await get_parent().move_ahead_seg
		#print("got wraps command")
	#print("my given targ: ", new_targ)
	target_position = tilemap.map_to_local(new_targ)
	move_ahead_seg.emit(old_position)
	#print("in follow front, OLD, NEW: ", old_position, tilemap.local_to_map(target_position))

func _extend(front_previous_cell,front_seg_num):
	#print("got command")
	
	#check if this segment is the LAST segment right now.
	#just check the "has tail" var to see
	#print("my seg number is: ", front_seg_num + 1," difference from mum length:",mum_length - (front_seg_num + 1), "JJ")
	if has_tail:
		#the segment has a tail,
		#we don't have to do anything
		#emit a signal for the segment behind to work
		#still increment front_seg_num
		#print("commanding the guy behind me to make the new seg JJ")
		create_new_seg.emit(old_position, front_seg_num + 1)
		how_long_are_we.emit(mum_length)
		return
	
	#increment the front_seg_num, that number is THIS segments positition.
	#if thisSegmentPosition and Mumlength have a difference of 1: make a sarc, else wraps
	#do all the formalities you would do in the Mummy class but here
	var my_seg_num = front_seg_num + 1
	#if has_tail == false:
		##print("I NEED A TAIL SO FUCKING BAD, do I make the sarc doe?")
		##print("seg num: ", my_seg_num, " mum length: ", mum_length, "  JJ")
		##if mum_length - 1 == my_seg_num:
			###print("that is my duty")
		
	#print("my seg number is: ", my_seg_num, " JJ")
	var new_seg
	if mum_length -1 == my_seg_num:
		#this is second to last, the last one is a sarc
		#print("I am creating the sarc")
		new_seg = sarcScene.instantiate()
	else:
		#this is not second to last, make a wrap
		#print("I am creating the wrap")
		new_seg = wrapsScene.instantiate()

	new_seg.tilemap = self.tilemap
	add_child(new_seg)
	create_new_seg.emit(old_position,my_seg_num)
	how_long_are_we.emit(mum_length)
	has_tail = true
