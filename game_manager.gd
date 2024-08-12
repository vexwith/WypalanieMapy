extends Node2D

@onready var bgm = Bgm
@onready var plaza = preload("res://Wavs/Reksio i Skarb Piratów OST - Muza1-(p).mp3")
@onready var medley = preload("res://Wavs/Reksio i Skarb Piratów Medley (Tomasz Jachowicz cover ⧸ variation by KKR)-(p).mp3")

@onready var sfx = $SFX
@onready var ojoj = preload("res://Wavs/6dziura.wav")
@onready var dobrze = preload("res://Wavs/6entre.wav")
@onready var rozumiem = preload("res://Wavs/6failed.wav")

@onready var wide_map = $WideMapa
@onready var base_map = $WideMapa/BaseMap
@onready var first_bkg = $WideMapa/BaseMap/FirstBackground

@onready var non_euclidean_map = $NonEuclideanMap
@onready var non_euclidean_pieces = $NonEuclideanMap/Pieces

@onready var ognik = $Ognik
@onready var camera = $Camera2D
@onready var exit = $Camera2D/Wyjście
@onready var lapa_button = $Camera2D/LapaButton

var first_map = true
const MAX_PIECES = 25 #all pieces including hidden on the first map + 1
var next_piece = 17 #index of next piece used to show hidden pieces in first map
var plaza_version = 0
var max_modulation = 1.0 #max modulation of first map

var between_maps = true

var unlock_hills = true

var draggable = false #false
var offset : Vector2

func _ready():
	SignalBus.connect("piece_clicked", _on_piece_clicked)
	SignalBus.connect("non_euclidean_clicked", _on_non_euclidean_clicked)
#	MAX_PIECES = base_map.get_child_count()
	if not Globals.lapa_gained:
		lapa_button.hide()
		sfx.volume_db = 0.0
	else:
		upgrade_to_wide_map()
		base_map.get_child(0).texture = load("res://Mapa/bkg_postlapa.png")
		if bgm.stream == plaza:
			bgm.stop()
		sfx.volume_db = -7.0
		plaza_version = 9 #reset
		
	if Globals.first_enter:
		Globals.first_enter = false
		sfx.stream = dobrze
		sfx.play()
			
	if Globals.say_restart:
		Globals.say_restart = false
		sfx.stream = rozumiem
		sfx.play()
		
	for i in range(1, 72):
		var piece = base_map.get_child(i)
		piece.stage = 4
		piece.sprite.play(str(piece.stage))
	first_map = false
	between_maps = false
	
func _process(delta):
	#bgm handler
	if not bgm.playing:
		if not Globals.lapa_gained:
			bgm.stream = plaza
		else:
			bgm.stream = medley
		bgm.play()
	#slowing down plaza
#	if between_maps:
	match plaza_version:
		0:
			bgm.pitch_scale = 1.0
		1:
			bgm.pitch_scale = 0.95
		2:
			bgm.pitch_scale = 1.05
		3:
			bgm.pitch_scale = 0.90
		4:
			bgm.pitch_scale = 0.85
		5:
			bgm.pitch_scale = 0.80
		6:
			bgm.pitch_scale = 0.70
		7:
			bgm.pitch_scale = 0.65
		8:
			bgm.pitch_scale = 0.15
		9: #reset
			bgm.pitch_scale = 1.0
			plaza_version += 1
				
	#bkg handler
	if first_bkg.modulate.a > max_modulation:
		first_bkg.modulate.a -= 0.001
	
func _input(event): #dragging hamdler
	if event is InputEventMouseMotion and draggable:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			var new_pos = camera.position - event.relative * camera.zoom * 0.4
			camera.position = new_pos
			if new_pos.x < 400: #480
				camera.position.x = 400
			if new_pos.x > 1520: #1440
				camera.position.x = 1520
			if new_pos.y < -80: #0
				camera.position.y = -80
			if new_pos.y > 1160: #1080
				camera.position.y = 1160
	
func _on_piece_clicked(clicked_piece):
	if clicked_piece.stage == 5 or clicked_piece.stage == 6:
		sfx.stream = ojoj
		sfx.play()
	if first_map:
		#check if first map is almost done
		var map_uncompleted = true
		while first_map and map_uncompleted:
			map_uncompleted = false
			for i in range(1, next_piece):
				var piece = base_map.get_child(i)
				#check if youre one move away from winning then show new piece
				piece.make_move()
				if map_completed(next_piece):
					piece.undo_move()
					map_uncompleted = true
					#showing new piece
					var new_piece = base_map.get_child(next_piece)
					new_piece.sprite.show()
					new_piece.stage = 1 #starts on second stage
					new_piece.sprite.play(str(new_piece.stage))
					if new_piece.clickable == false:
						new_piece.update_affected()
						new_piece.clickable = true
					
					next_piece += 1
					plaza_version += 1
					
					max_modulation -= 0.15
					
					if next_piece == MAX_PIECES: #after getting all the closest ones change to 100 element map
						first_map = false
						
				else:
					piece.undo_move()
	elif between_maps:
		if map_completed(MAX_PIECES):
			between_maps = false
#			draggable = true
			if not Globals.lapa_gained:
				upgrade_to_wide_map()
				
	elif unlock_hills:
		if map_completed(72) and non_euclidean_completed(): #all before hills
			unlock_hills = false
			var entre = base_map.get_child(72)
			entre.global_position.x += 70
			
	elif clicked_piece.get_index() == 72:
		Globals.crawl_mode = true

func _on_non_euclidean_clicked():
	#animating zoom in
	var portal_piece = base_map.get_child(41)
	var init_cam_pos = camera.position
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(camera, "zoom", Vector2(4.0, 4.0), 1.0)
	tween.tween_property(camera, "position", portal_piece.global_position, 1.0)
	await tween.finished
	camera.position = init_cam_pos
	camera.zoom = Vector2(1.0, 1.0)
	#enable non euclidean map and disable wide map
	non_euclidean_map.global_position = camera.global_position - Vector2(960, 540)
	non_euclidean_map.show()
	wide_map.hide()
	#lapa returns you to wide map instead
	Globals.undraggable = true
	
func back_from_non_euclidean():
	non_euclidean_map.hide()
	wide_map.show()
	Globals.undraggable = false
	draggable = true
	
	if non_euclidean_completed():
		var teleport = base_map.get_child(41)
		teleport.stage = 4
		teleport.sprite.play(str(teleport.stage))

func upgrade_to_wide_map():
	#in outer wide map all pieces start from 1
	for i in range(25, base_map.get_child_count()):
		var piece = base_map.get_child(i)
		piece.update(1)
		
	#special cases
	var moving_piece = base_map.get_child(40)
	moving_piece.timer.start()
	
	for easy_saper in [31, 33, 39, 45]: #they start from 0
		var piece = base_map.get_child(easy_saper)
		piece.update(-1)
		
	for harder in [44]: #they start from 2
		var piece = base_map.get_child(harder)
		piece.update(1)

func map_completed(search_range):
	#check if map is done	
	var win_condition = true
	for i in range(1, search_range):
		var piece = base_map.get_child(i)
		if piece.stage != 3 and piece.stage != 4:
			return false
			
	return win_condition
	
func non_euclidean_completed():
	#check if non euclidean is done
	var win_condition = true
	for piece in non_euclidean_pieces.get_children():
		if piece.stage != 3 and piece.stage != 4:
			return false
			
	return win_condition

func _on_reset_button_pressed():
	get_tree().reload_current_scene()
	
	Globals.focused_piece = null
	Globals.ignore_clicks = false
	Globals.undraggable = false
	Globals.bomb_clicked = false
	Globals.crawl_mode = false
	
	if Globals.first_restart:
		Globals.first_restart = false
		Globals.say_restart = true
#	#return visibility
#	max_modulation = 1.0
#	first_bkg.modulate.a = 1.0
#
#	#reseting all pieces
#	for piece in base_map.get_children():
#		if piece is Area2D:
#			piece.stage = -1
#			piece.sprite.hide()
#
#	#reseting reset button
#	exit.global_position = Vector2(1570, 953)
#
#	#reseting hidden pieces progress
#	first_map = true
#	next_piece = 17
#
#	#reset audio to normal
#	plaza_version = 0

func _on_wyjście_button_down():
	var x
	var y
	while true:
		x = randi_range(-940, 940)
		y = randi_range(-540, 540)
		if abs(exit.position.x - x) < 90 or abs(exit.position.y - y) < 126:
			continue
		break
	exit.position = Vector2(x, y)

func clear_items():
	for item in ognik.przedmioty.keys():
		ognik.przedmioty[item] = false

func _on_ognik_button_mouse_entered():
	Globals.ignore_clicks = true

func _on_ognik_button_mouse_exited():
	if not ognik.przedmioty["lapa"]:
		Globals.ignore_clicks = false

func _on_ognik_button_button_up():
	clear_items()
	ognik.przedmioty["ognik"] = true
	draggable = false

func _on_lapa_button_mouse_entered():
	Globals.ignore_clicks = true

func _on_lapa_button_mouse_exited():
	if not ognik.przedmioty["lapa"]:
		Globals.ignore_clicks = false

func _on_lapa_button_button_up():
	clear_items()
	ognik.przedmioty["lapa"] = true
	if not Globals.undraggable:
		draggable = true
	Globals.ignore_clicks = true
