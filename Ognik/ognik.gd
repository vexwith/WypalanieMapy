extends Area2D

@onready var timer = $Timer
@onready var audio = $AudioStreamPlayer
@onready var light = $PointLight2D
@onready var cursor_frames = [preload("res://Ognik/OGNIK_1.png"), preload("res://Ognik/OGNIK_2.png"),
							  preload("res://Ognik/OGNIK_3.png"), preload("res://Ognik/OGNIK_0.png")]
@onready var lapa = [preload("res://Ognik/cursor_0.png"), preload("res://Ognik/cursor_1.png")]
@onready var woda = [preload("res://Ognik/e_flash_16.png"), preload("res://Ognik/e_flash_17.png"), 
					preload("res://Ognik/e_flash_18.png"), preload("res://Ognik/e_flash_19.png"),
					preload("res://Ognik/e_flash_20.png"), preload("res://Ognik/e_flash_21.png"),
					preload("res://Ognik/e_flash_22.png"), preload("res://Ognik/e_flash_23.png")]

var frame_index = 0

var lapa_index = 0

var dark_mode = false

var przedmioty = {"ognik": true, "lapa": false}
	
func _process(delta):
	if dark_mode:
		light.global_position = get_global_mouse_position()
		if przedmioty["ognik"]:
			light.show()
		else:
			light.hide()
	else: light.hide()
	if not audio.playing and przedmioty["ognik"] and not Globals.fire_mode:
		audio.play()
#	global_position = get_global_mouse_position()
	if przedmioty["lapa"]:
		audio.stop()
		if Globals.undraggable and light.color.a == 0.0: #changing to lapa in any way will return to wide map
			#in case of infinity it wont happen
			get_parent().back_from_non_euclidean()
		if Input.is_action_just_pressed("PPM"):
			lapa_index = 1
			if Globals.trapped:
				SignalBus.emit_signal("mouse_freed")
		if Input.is_action_just_released("PPM"):
			lapa_index = 0

func _on_timer_timeout():
	if przedmioty["ognik"] and not Globals.fire_mode:
		Input.set_custom_mouse_cursor(cursor_frames[frame_index], Input.CURSOR_ARROW, Vector2(45, 100))
		frame_index = (frame_index + 1) % 4
	elif Globals.fire_mode and Globals.crawl_mode:
		Input.set_custom_mouse_cursor(woda[frame_index], Input.CURSOR_ARROW)
		frame_index = (frame_index + 1) % 8
	if przedmioty["lapa"]:
		Input.set_custom_mouse_cursor(lapa[lapa_index], Input.CURSOR_ARROW)
