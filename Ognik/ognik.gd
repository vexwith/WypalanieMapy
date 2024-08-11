extends Area2D

@onready var timer = $Timer
@onready var audio = $AudioStreamPlayer
@onready var cursor_frames = [preload("res://Ognik/OGNIK_1.png"), preload("res://Ognik/OGNIK_2.png"),
							  preload("res://Ognik/OGNIK_3.png"), preload("res://Ognik/OGNIK_0.png")]
@onready var lapa = preload("res://Ognik/cursor_0.png")

var frame_index = 0

var przedmioty = {"ognik": true, "lapa": false}
	
func _process(delta):
	if not audio.playing:
		audio.play()
#	global_position = get_global_mouse_position()

func _on_timer_timeout():
	if przedmioty["ognik"]:
		Input.set_custom_mouse_cursor(cursor_frames[frame_index], Input.CURSOR_ARROW, Vector2(45, 100))
		frame_index = (frame_index + 1) % 4
	if przedmioty["lapa"]:
		Input.set_custom_mouse_cursor(lapa, Input.CURSOR_ARROW)
