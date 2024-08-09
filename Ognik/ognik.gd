extends Area2D

@onready var timer = $Timer
@onready var cursor_frames = [preload("res://Ognik/OGNIK_1.png"), preload("res://Ognik/OGNIK_2.png"),
							  preload("res://Ognik/OGNIK_3.png"), preload("res://Ognik/OGNIK_0.png")]

var frame_index = 0
	
#func _process(delta):
#	global_position = get_global_mouse_position()

func _on_timer_timeout():
	Input.set_custom_mouse_cursor(cursor_frames[frame_index], Input.CURSOR_ARROW, Vector2(25, 45))
	frame_index = (frame_index + 1) % 4
