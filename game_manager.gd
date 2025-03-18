extends Node2D

const SAVE_DIR = "user://saves/"
const SAVE_FILE_NAME = "save_2.json"
const SECURITY_KEY = "092GSD2"

@onready var bgm = Bgm
@onready var plaza = preload("res://Wavs/Reksio i Skarb Piratów OST - Muza1-(p).mp3")
@onready var medley = preload("res://Wavs/Reksio i Skarb Piratów Medley (Tomasz Jachowicz cover ⧸ variation by KKR)-(p).mp3")
@onready var hills = preload("res://Wavs/Mysterious Hills-(p).mp3")
@onready var reverse = preload("res://Wavs/reversemapa.wav")

@onready var sfx = $SFX
@onready var ojoj = preload("res://Wavs/6dziura.wav")
@onready var dobrze = preload("res://Wavs/6entre.wav")
@onready var rozumiem = preload("res://Wavs/6failed.wav")
@onready var win = preload("res://Wavs/win.wav")
@onready var mina_setup = preload("res://Wavs/00ekran.wav")
@onready var mina_wybuch = preload("res://Wavs/explosion-91872.mp3")
@onready var postmapa = preload("res://Mapa/bkg_postlapa2.png")
@onready var ogien = preload("res://Wavs/snd_Fire.wav")

@onready var message_scene = preload("res://Items/Messages/message.tscn")

@onready var lapa_button_normal = preload("res://GUI/lapa_button.png")
@onready var lapa_button_hover = preload("res://GUI/lapa_button_glow.png")
@onready var lapa_exit_normal = preload("res://GUI/m_exit_0.png")
@onready var lapa_exit_hover = preload("res://GUI/m_exit_1.png")

@onready var wide_map = $WideMapa
@onready var base_map = $WideMapa/BaseMap
@onready var first_bkg = $WideMapa/BaseMap/FirstBackground
@onready var clouds = $WideMapa/Clouds

@onready var non_euclidean_map = $NonEuclideanMap
@onready var non_euclidean_pieces = $NonEuclideanMap/Pieces

@onready var fire_map = $FireMapa
@onready var fire_pieces = $FireMapa/Pieces
@onready var burn_map = $Camera2D/BurnMap

@onready var dark_map = $DarkMapa
@onready var dark_pieces = $DarkMapa/Pieces
@onready var infinity = $Infinity
@onready var infinity_indicator_rim = $Camera2D/Rim

@onready var blue_map = $BlueMapa
@onready var blue_pieces = $BlueMapa/Pieces

@onready var ognik = $Ognik
@onready var camera = $Camera2D
@onready var reset = camera.find_child("ResetButton")
@onready var exit = camera.find_child("Wyjście")
@onready var real_exit = camera.find_child("RealExit")
@onready var hills_exit = $HillsExit
@onready var lapa_button = camera.find_child("LapaButton")
@onready var ognik_button = camera.find_child("OgnikButton")
@onready var key_one = $Camera2D/OgnikButton/Sprite2D
@onready var mouse_left = $Camera2D/OgnikButton/Sprite2D2
@onready var small_piece = $SmallPiece
@onready var menu = camera.find_child("Menu")
@onready var screen_shadow = camera.find_child("Shadow")
@onready var white_shadow = camera.find_child("WhiteShadow")
@onready var endings = camera.find_child("Endings")
#@onready var detail_shadow = $"WideMapa/BaseMap/Kawałek100/DetailShadow"

var camera_limits = [-624, -684, 2544, 1764]
var reset_pos = Vector2(495, 413)

const MAX_WYPALENIA = 6

var first_map = true
const MAX_PIECES = 25 #all pieces including hidden on the first map + 1
var next_piece = 17 #index of next piece used to show hidden pieces in first map
var plaza_version = 0
var max_modulation = 1.0 #max modulation of first map

var between_maps = true

var unlock_hills = true
var camera_exit_pos
var first_door = true

var draggable = false #false
var offset : Vector2

var last_piece = null

func verify_save_directory(path : String):
	DirAccess.make_dir_absolute(path)
	
func save_data(path : String):
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, SECURITY_KEY)
	if file == null:
		print(FileAccess.get_open_error())
		return
		
	var data = {
		"player_data" : {
			"lapa_gained" : Globals.lapa_gained,
			"return_trapped" : Globals.return_trapped,
			"first_enter" : Globals.first_enter,
			"first_restart" : Globals.first_restart,
			"say_restart" : Globals.say_restart,
#			"wypalenia" : Globals.wypalenia,
			"map_pieces" : Globals.map_pieces
		}
	}
	
	var json_string = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()
	
func load_data(path : String):
	if FileAccess.file_exists(path):
		var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, SECURITY_KEY)
		if file == null:
			print(FileAccess.get_open_error())
			return
			
		var content = file.get_as_text()
		file.close()
		
		var data = JSON.parse_string(content)
		if data == null:
			printerr("Cannot parse %s as a json_string: (%s)" % [path, content])
			return
			
		Globals.lapa_gained = data.player_data.lapa_gained
		Globals.return_trapped = data.player_data.return_trapped
		Globals.first_enter = data.player_data.first_enter
		Globals.first_restart = data.player_data.first_restart
		Globals.say_restart = data.player_data.say_restart
#		Globals.wypalenia = data.player_data.wypalenia
		Globals.map_pieces = data.player_data.map_pieces
		
#		Globals.map_state_log = data.map_data.map_state_log
		
	else:
		printerr("Cannot open non-existent file at %s!" % [path])

func _ready():
	SignalBus.connect("piece_clicked", _on_piece_clicked)
	SignalBus.connect("get_small_piece", get_small_piece)
	SignalBus.connect("non_euclidean_clicked", _on_non_euclidean_clicked)
	SignalBus.connect("blue_map_clicked", _on_blue_map_clicked)
	verify_save_directory(SAVE_DIR)
	if Globals.kontynuuj:
		Globals.kontynuuj = false
		_on_reset_button_pressed(false)
		load_data(SAVE_DIR + SAVE_FILE_NAME)
		get_tree().reload_current_scene()
		
#	MAX_PIECES = base_map.get_child_count()
	upgrade_to_wide_map()
	if not Globals.lapa_gained:
		lapa_button.hide()
		key_one.hide()
		mouse_left.hide()
		sfx.volume_db = 0.0
	elif !Globals.reset_dark:
		start_flying_piece()
		base_map.get_child(0).texture = postmapa
		if bgm.stream == plaza:
			bgm.stop()
		sfx.volume_db = -7.0
		plaza_version = 9 #reset
		
		var tween = get_tree().create_tween().bind_node(self)
		tween.tween_property(wide_map.find_child("Saper"), "modulate", Color(1.0, 1.0, 1.0, 1.0), 2.0)
		
	if not Globals.return_trapped:
		real_exit.hide()
	else:
		exit.hide()
		
	if Globals.first_enter:
		Globals.first_enter = false
		sfx.stream = dobrze
		sfx.play()
			
	if Globals.say_restart:
		Globals.say_restart = false
		sfx.stream = rozumiem
		sfx.play()
		
	#saving blank map
	save_prev()

	if Globals.reset_dark:
		Globals.reset_dark = false
		plaza_version = 8 #it resets to normal plaza so we have to slow it again
		screen_shadow.show()
		screen_shadow.modulate.a = 1.0
		_on_real_exit_button_up()
		
#	for i in range(1, 72):
#		var piece = base_map.get_child(i)
#		piece.stage = 4
#		piece.sprite.play(str(piece.stage))
#	for j in non_euclidean_pieces.get_children():
#		j.stage = 4
#	first_map = false
#	between_maps = false
	
func _process(delta):
	#bgm handler
	if not bgm.playing:
		if Globals.fire_mode and Globals.crawl_mode:
			bgm.stream = reverse
			plaza_version = 9 #reset
#		elif Globals.fire_mode: #silence between wide and fire map
#			bgm.stream = null
		elif Globals.crawl_mode:
			bgm.stream = hills
			plaza_version = 9 #reset
		elif dark_map.visible or blue_map.visible:
			bgm.stream = plaza
			plaza_version = 8 #max slow
		elif Globals.lapa_gained:
			bgm.stream = medley
			plaza_version = 9 #reset
		else:
			bgm.stream = plaza
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
		
	#double portal indicator handler 
	if (dark_map.visible or blue_map.visible) and Globals.detail_mode:
		var dark_portal = dark_pieces.get_child(0)
		var blue_portal = blue_pieces.get_child(0)
		if !dark_portal.locked and !blue_portal.locked:
			if dark_portal.rim.modulate == dark_portal.affected_modulation or blue_portal.rim.modulate == blue_portal.affected_modulation:
				infinity_indicator_rim.show()
			else: infinity_indicator_rim.hide()
	
func _input(event): #dragging hamdler
	if event.is_action_pressed("ui_cancel"): #esc to end
		_on_menu_pressed()
		
	if (event.is_action_pressed("rewind") or event.is_action_pressed("rewind_camera")) and not Globals.crawl_mode:
		if Globals.lapa_gained or between_maps:
			var with_camera = event.is_action_pressed("rewind_camera")
			if len(Globals.map_state_log) > 1:
				var cur_state = Globals.map_state_log.pop_back()
				
				clear_modulation()
				var last = cur_state.pop_back()
				if last != null:
					last.sprite.self_modulate = Color.PALE_GREEN
#					if last.stage == -1:
#						last.sprite.play("1")
				
				var prev_state = Globals.map_state_log[-1].duplicate()
				load_prev(prev_state, with_camera)
			elif len(Globals.map_state_log) == 1:
				var prev_state = Globals.map_state_log[-1].duplicate()
				load_prev(prev_state, with_camera)
			
	if event.is_action_pressed("1") or event.is_action_released("LPM"):
		if not Globals.trapped:
			if ognik.przedmioty["lapa"]: Globals.ignore_clicks = false
			_on_ognik_button_button_up()
		
	if event.is_action_pressed("2") or event.is_action_pressed("PPM"):
		if not Globals.crawl_mode and Globals.lapa_gained:
			_on_lapa_button_button_up()
			
	if event.is_action_pressed("restart"):
		_on_reset_button_pressed()
		
	if event.is_action_pressed("ctrl"):
		Globals.detail_mode = !Globals.detail_mode
		if !Globals.detail_mode:
			for i in range(1, len(base_map.get_children())):
				var piece = base_map.get_child(i)
				piece.rim.modulate = Color(1.0, 1.0, 1.0, 0.0)
				if piece.stage_number != null: piece.stage_number.hide()
			if ognik.light.color.a == 1.0:
				clear_rims(dark_pieces)
				clear_rims(blue_pieces)
#		detail_shadow.color.a = 0.4 if detail_shadow.color.a == 0.0 else 0.0
#	if event.is_action_released("ctrl"):
#		Globals.detail_mode = false
#		$Camera2D/DetailShadow.color.a = 0.0
		
			
	#dragging
	if not Globals.crawl_mode and not Globals.trapped:
		if event is InputEventMouseMotion and draggable:
			if event.button_mask == MOUSE_BUTTON_MASK_RIGHT:
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


func clear_rims(map):
	infinity_indicator_rim.hide()
	for i in range(len(map.get_children())):
		var piece = map.get_child(i)
		piece.rim.modulate = Color(1.0, 1.0, 1.0, 0.0)
		if piece.stage_number != null: piece.stage_number.hide()

func clear_modulation():
	if dark_map.visible or blue_map.visible:
		for piece in dark_pieces.get_children():
			piece.sprite.self_modulate = Color.WHITE
		for piece in blue_pieces.get_children():
			piece.sprite.self_modulate = Color.WHITE
	else:
		for piece in base_map.get_children():
			if piece is Area2D:
				piece.sprite.self_modulate = Color.WHITE
				
		for piece in non_euclidean_pieces.get_children():
			piece.sprite.self_modulate = Color.WHITE

func failed(piece):
	if piece.stage == 5 or piece.stage == 6:
		Globals.wypalenia += 1
		if Globals.wypalenia == MAX_WYPALENIA:
			var message = message_scene.instantiate()
			get_tree().root.add_child(message)
			message.global_position = piece.global_position
		return true
	
	if not 'low_pos' in piece:
		for i in piece.affected_pieces:
			var affected
			if dark_map.visible:
				affected = dark_pieces.get_child(i)
			elif blue_map.visible:
				affected = blue_pieces.get_child(i)
			else:
				affected = base_map.get_child(i)
			if affected.stage == 5 or affected.stage == 6:
				return true
		
	return false
	
func _on_piece_clicked(clicked_piece):
	get_small_piece()
	clear_modulation()
	
	if failed(clicked_piece):
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
					plaza_version = next_piece - 17 if plaza_version < 9 else 9 #dont add plaza version from undoing
					
					max_modulation = 1.0 - (next_piece - 17) * 0.15 #dont add modulation from undoing
					
					if next_piece == MAX_PIECES: #after getting all the closest ones change to 100 element map
						first_map = false
						
				else:
					piece.undo_move()
	elif between_maps:
		if map_completed(MAX_PIECES):
			between_maps = false
#			draggable = true
			if not Globals.lapa_gained:
				start_flying_piece()
#				upgrade_to_wide_map()
				
	elif unlock_hills:
		if map_completed(72) and non_euclidean_completed(): #all before hills
			unlock_hills = false
			var entre = base_map.get_child(72)
			entre.global_position.x += 70
			
			#move clouds away
			for up in [53, 54, 31]:
				var piece = clouds.find_child("Cloud" + str(up))
				var tween = get_tree().create_tween().bind_node(self)
				tween.tween_property(piece, "position", Vector2(piece.position.x, piece.position.y - 70), 2.0)
#				piece.position.y -= 70
			for down in [9, 55, 32]:
				var piece = clouds.find_child("Cloud" + str(down))
				var tween = get_tree().create_tween().bind_node(self)
				tween.tween_property(piece, "position", Vector2(piece.position.x, piece.position.y + 70), 2.0)
#				piece.position.y += 70
			
	elif clicked_piece.get_index() == 72 and not Globals.crawl_mode:
		Globals.crawl_mode = true
		camera_exit_pos = camera.global_position
		var over = 9000
		camera.limit_left = -over
		camera.limit_top = camera.limit_top + 80 * 1.8
		camera.limit_bottom = camera.limit_bottom - 80 * 1.8
#		camera.limit_top = -over
#		camera.limit_right = over
#		camera.limit_bottom = over
		var tween = get_tree().create_tween().set_parallel(true).bind_node(self)
		tween.tween_property(camera, "global_position", clicked_piece.global_position, 1.0)
		tween.tween_property(camera, "zoom", Vector2(2.0, 2.0), 1.0)
		tween.tween_property(bgm, "pitch_scale", 0.1, 1.0)
		await tween.finished
		hills_exit.show()
		reset.modulate.a = 0.0
		reset.position = Vector2(371, 160)
		var tween2 = get_tree().create_tween().set_parallel(true).bind_node(self)
		tween2.tween_property(reset, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.0)
		tween2.tween_property(hills_exit, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.0)
		bgm.stop()
		bgm.pitch_scale = 1.0
		
	elif Globals.crawl_mode:
		var tween = get_tree().create_tween().bind_node(self)
		tween.tween_property(camera, "global_position", clicked_piece.global_position, 0.5)
		
		for i in clicked_piece.affected_pieces:
			var affected = base_map.get_child(i)
			affected.clickable = true
#		camera.global_position = clicked_piece.global_position
		if hills_failed():
			Globals.ignore_clicks = true
			await sfx.finished
			_on_hills_exit_button_up()
			Globals.ignore_clicks = false
			
	if all_failed():
		if burn_whole_map():
			var message = get_tree().root.find_child("Message", true, false)
			if message != null:
				message.queue_free()
				
			wide_map.hide()
			var tween = get_tree().create_tween().bind_node(self)
			tween.tween_property(white_shadow, "modulate", Color.WHITE, 4.0)
			await tween.finished
			
			Globals.fire_mode = true
			ognik.audio.stop()
			_on_ognik_button_button_up()
			bgm.stop()
			burn_map.hide()
			ognik_button.hide()
			lapa_button.hide()
			real_exit.hide()
			$Camera2D/Rewind.hide()
			fire_map.global_position = camera.global_position - Vector2(1920, 1080)/2
			fire_map.show()
			var reverse_tween = get_tree().create_tween().bind_node(self)
			reverse_tween.tween_property(white_shadow, "modulate", Color(1.0, 1.0, 1.0, 0.0), 3.0)
			await reverse_tween.finished
			
			fire_map.spawn_timer.start()
			white_shadow.hide()
		else:
			Globals.crawl_mode = true
			white_shadow.show()
			burn_map.show()
			var tween = get_tree().create_tween().bind_node(self)
			tween.tween_property(bgm, "pitch_scale", 0.1, 4.0)
			
	#saving map state
	if not ((wide_map.visible and clicked_piece.get_index() in range(25, 40)) or Globals.crawl_mode): #if not inside saper or hills
		last_piece = clicked_piece
		save_prev()


func _on_non_euclidean_clicked():
	#animating zoom in
	var portal_piece = base_map.get_child(41)
	var init_cam_pos = camera.position
	
	var over = 9000
	camera.limit_left = -over
	camera.limit_top = -over
	camera.limit_right = over
	camera.limit_bottom = over
	
	var tween = get_tree().create_tween().set_parallel(true).bind_node(self)
	tween.tween_property(camera, "zoom", Vector2(4.0, 4.0), 1.0)
	tween.tween_property(camera, "position", portal_piece.global_position, 1.0)
	await tween.finished
	camera.position = init_cam_pos
	camera.zoom = Vector2(1.0, 1.0)
	
	camera.limit_left = camera_limits[0]
	camera.limit_top = camera_limits[1]
	camera.limit_right = camera_limits[2]
	camera.limit_bottom = camera_limits[3]
	
	#enable non euclidean map and disable wide map
	non_euclidean_map.global_position = camera.global_position - Vector2(960, 540)
	non_euclidean_map.show()
	wide_map.hide()
	
	#lapa returns you to wide map instead
	lapa_to_door()
	
	
	Globals.undraggable = true
	
func back_from_non_euclidean():
	Globals.undraggable = false
	non_euclidean_map.hide()
	wide_map.show()
	draggable = true
	
	door_to_lapa()
	
	if non_euclidean_completed():
		var teleport = base_map.get_child(41)
		teleport.stage = 4
		teleport.sprite.play(str(teleport.stage))
		_on_piece_clicked(teleport)

func lapa_to_door():
	var door_rect = Rect2(0, 0, 43, 51)
	lapa_button.get_theme_stylebox("normal").texture = lapa_exit_normal
	lapa_button.get_theme_stylebox("normal").region_rect = door_rect
	lapa_button.get_theme_stylebox("hover").texture = lapa_exit_hover
	lapa_button.get_theme_stylebox("hover").region_rect = door_rect
	
func door_to_lapa():
	var door_rect = Rect2(2, 2, 53, 52)
	lapa_button.get_theme_stylebox("normal").texture = lapa_button_normal
	lapa_button.get_theme_stylebox("normal").region_rect = door_rect
	lapa_button.get_theme_stylebox("hover").texture = lapa_button_hover
	lapa_button.get_theme_stylebox("hover").region_rect = door_rect
	
func _on_blue_map_clicked():
	#animating zoom in
	var portal_piece = dark_pieces.get_child(0)
	
	var tween = get_tree().create_tween().set_parallel(true).bind_node(self)
	tween.tween_property(camera, "zoom", Vector2(4.0, 4.0), 1.0)
	tween.tween_property(camera, "position", portal_piece.global_position, 1.0)
	await tween.finished
	camera.position = Vector2(960, 540)
	camera.zoom = Vector2(1.0, 1.0)
	
	ognik.dark_mode = !ognik.dark_mode
	
	#enable blue map and disable dark map
	if dark_map.visible:
		dark_map.visible = false
		blue_map.visible = true
	else:
		blue_map.visible = false
		dark_map.visible = true

func upgrade_to_wide_map():
	#in outer wide map all pieces start from 1
	for i in range(25, base_map.get_child_count()):
		var piece = base_map.get_child(i)
		piece.update(1)
		
	#special cases
	for easy_saper in [31, 33, 39, 45]: #they start from 0
		var piece = base_map.get_child(easy_saper)
		piece.update(-1)
		
	for harder in [44]: #they start from 2
		var piece = base_map.get_child(harder)
		piece.update(1)
		
	for hide_hills in range(73, 101):
		var piece = base_map.get_child(hide_hills)
		if hide_hills not in [80, 94]:
			piece.update(-1)
		if hide_hills > 74:
			piece.clickable = false
			
	var troll = base_map.get_child(84)
	troll.update(3)
	
func start_flying_piece():
	var moving_piece = base_map.get_child(40)
	moving_piece.timer.start()

func get_small_piece():
	var non_euclidean = non_euclidean_completed()
	var saper = map_completed(39, 25)
	var wide = map_completed(72) and non_euclidean_completed()
	var treasure = Globals.treasure
	var ptak = Globals.ptak_event
	var flame = Globals.map_saved
	var dark : bool
	var blue : bool
	if dark_map.visible or blue_map.visible:
		var dark_maps = dark_map_completed()
		dark = dark_maps[0]
		blue = dark_maps[1]
				
		if dark:
			if Globals.map_pieces["dark"] == false:
				Globals.map_pieces["dark"] = true
				small_piece_animation(camera.global_position)
		var dark_particles = dark_map.find_child("DarkParticles")
		if not dark_particles.emitting and dark and not sfx.playing:
			play_win()
		dark_particles.emitting = dark
		
		if blue:
			if Globals.map_pieces["blue"] == false:
				Globals.map_pieces["blue"] = true
				small_piece_animation(camera.global_position)
		var blue_particles = blue_map.find_child("BlueParticles")
		if not blue_particles.emitting and blue and not sfx.playing:
			play_win()
		blue_particles.emitting = blue
				
	if treasure:
		Globals.treasure = false
		if Globals.map_pieces["strzalki"] == false:
			Globals.map_pieces["strzalki"] = true
			small_piece_animation(base_map.get_child(70).find_child("Treasure").global_position + Vector2(85, 0))
	if treasure and not sfx.playing:
		play_win()
		
	if ptak:
		Globals.ptak_event = false
		if Globals.map_pieces["ptak_event"] == false:
			Globals.map_pieces["ptak_event"] = true
			small_piece_animation(camera.find_child("CzyNaPtak").find_child("PanelMap").global_position)
	if ptak and not sfx.playing:
		play_win()
		
	if flame:
		Globals.map_saved = false
		if Globals.map_pieces["flame"] == false:
			Globals.map_pieces["flame"] = true
			small_piece_animation(camera.global_position)
	if flame and not sfx.playing:
		play_win()
	
	if saper:
		if Globals.map_pieces["saper"] == false:
			Globals.map_pieces["saper"] = true
			small_piece_animation(Vector2(2061, -262))
	var saper_particles = wide_map.find_child("SaperParticles")
	if not saper_particles.emitting and saper and not sfx.playing:
		play_win()
	saper_particles.emitting = saper
	
	if sfx.playing:
		await sfx.finished
	
	if wide:
		if Globals.map_pieces["wide_map"] == false:
			Globals.map_pieces["wide_map"] = true
			small_piece_animation(camera.global_position)
	var wide_particles = wide_map.find_child("WideParticles")
	if not wide_particles.emitting and wide and not sfx.playing:
		play_win()
	wide_particles.emitting = wide
		
		
	if non_euclidean:
		if Globals.map_pieces["non_euclidean"] == false:
			Globals.map_pieces["non_euclidean"] = true
			small_piece_animation(camera.global_position)
	var non_euclidean_particles = base_map.get_child(41).find_child("Particles")
	if not non_euclidean_particles.emitting and non_euclidean and not sfx.playing:
		play_win()
	non_euclidean_particles.emitting = non_euclidean
	
	
func play_win():
	sfx.stop()
	sfx.stream = win
	sfx.play()
	
func small_piece_animation(pos : Vector2):
	play_win()
	
	small_piece.global_position = pos
	small_piece.show()
	var count = 0
	for value in Globals.map_pieces.values():
		if value:
			count += 1
	small_piece.play(str(count))
	var tween = get_tree().create_tween().set_parallel(true).bind_node(self)
	tween.tween_property(small_piece, "scale", Vector2(1.0, 1.0), 0.5).from(Vector2(0.1, 0.1))
	tween.tween_property(small_piece, "global_position", small_piece.position + Vector2(0, 40), 0.3).set_ease(Tween.EASE_IN)
	tween.chain().tween_property(small_piece, "global_position", small_piece.position - Vector2(0, 40), 0.3).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(small_piece, "global_position", menu.global_position + Vector2(39.75, 39), 0.7).set_ease(Tween.EASE_OUT_IN)
	tween.chain().tween_property(small_piece, "scale", Vector2(0.1, 0.1), 0.3)
	await tween.finished
	small_piece.hide()
	
func map_completed(search_range, start = 1):
	#check if map is done	
	for i in range(start, search_range):
		var piece = base_map.get_child(i)
		if piece.stage != 3 and piece.stage != 4:
			return false
			
	return true
	
func non_euclidean_completed():
	#check if non euclidean is done
	for piece in non_euclidean_pieces.get_children():
		if piece.stage != 3 and piece.stage != 4:
			return false
			
	return true
	
func dark_map_completed():
	var dark = true
	var blue = true
	for piece in dark_pieces.get_children():
		if piece.stage != 3 and piece.stage != 4:
			dark = false
	for piece in blue_pieces.get_children():
		if piece.stage != 3 and piece.stage != 4:
			blue = false
	if dark and blue:
		_on_dark_completed()
	return [dark, blue]
	
func saper_failed():
	for i in range(25, 40):
		var piece = base_map.get_child(i)
		if piece.stage >= 5:
			Globals.bomb_clicked = true
			
func saper_activated():
	for i in range(25, 40):
		var piece = base_map.get_child(i)
		if piece.stage >= 2:
			return true
	return false
	
func hills_failed():
	#check if wypaliles dziure
	for i in range(72, 101):
		var piece = base_map.get_child(i)
		if piece.stage >= 5:
			return true
			
	return false

func all_failed():
	for i in range(1, 72): #72
		var piece = base_map.get_child(i)
		if piece.clickable and piece.stage < 5:
			return false
	return true
	
func burn_whole_map():
	for piece in burn_map.get_children():
		if piece.stage == -1:
			return false
	return true

func _on_reset_button_pressed(reload = true):
	if Globals.fire_mode:
		reset_fire_map()
		return
	if Globals.crawl_mode:
		_on_hills_exit_button_up()
		return
			
	if ognik.light.color.a != 0.0:
		Globals.reset_dark = true
		
	Globals.map_state_log.clear()
	Globals.focused_piece = null
	Globals.ignore_clicks = false
	Globals.undraggable = false
	Globals.bomb_clicked = false
	Globals.saper_count = 0
	Globals.trapped = false
	Globals.wypalenia = 0
	
#	if Globals.crawl_mode:
#		Globals.crawl_mode = false
#		bgm.stop()
	
	if Globals.first_restart:
		Globals.first_restart = false
		Globals.say_restart = true
		
	door_to_lapa()
		
	if reload: #we sometimes dont want to reload
		get_tree().reload_current_scene()

func reset_fire_map():
	for piece in fire_pieces.get_children():
		var fire = piece.get_child(4)
		fire.hide()
		piece.stage = 2
		piece.update(0)
	fire_map.LEVEL = 0
	fire_map.label.text = ""
	fire_map.spawn_timer.wait_time = fire_map.spawn_time
	fire_map.spread_timer.wait_time = fire_map.spread_time
	fire_map.spread_timer.stop()
	fire_map.spawn_timer.stop()
	fire_map.spawn_timer.start()

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


func _on_hills_exit_button_up():
	Globals.crawl_mode = false
	
	camera.limit_left = camera_limits[0]
	camera.limit_top = camera_limits[1]
	camera.limit_right = camera_limits[2]
	camera.limit_bottom = camera_limits[3]
	
	camera.global_position = camera_exit_pos
	camera.zoom = Vector2(1.0, 1.0)
	hills_exit.hide()
	hills_exit.modulate.a = 0.0
	
	reset.position = reset_pos
	
	bgm.stop()
	bgm.pitch_scale = 1.0

	for i in range(72, 101):
		var piece = base_map.get_child(i)
		piece.stage = -1
		piece.update(0)
		if i > 74:
			piece.clickable = false
	for i in [72, 80, 94, 84]:
		var piece = base_map.get_child(i)
		piece.update(1)
		
	var troll = base_map.get_child(84)
	troll.update(3)

func _on_z_button_down():
	var new_event = InputEventAction.new()
	new_event.action = "rewind"
	new_event.pressed = true
	_input(new_event)
	
func save_prev():
	var map_state = []
	
	var portal_button = dark_map.find_child("PortalButton")
	map_state.append(portal_button.next_state)
	
	if dark_map.visible or blue_map.visible: #different pieces saved on different maps
		for piece in dark_pieces.get_children():
			map_state.append(piece.stage)
		for piece in blue_pieces.get_children():
			map_state.append(piece.stage)
	else:
		for piece in base_map.get_children():
			if piece is Area2D:
				map_state.append(piece.stage)
		for non_euclidean_piece in non_euclidean_pieces.get_children():
			map_state.append(non_euclidean_piece.stage)
		
	map_state.append(camera.global_position)
	map_state.append(next_piece)
	map_state.append(first_map)
	
	if not dark_map.visible and not blue_map.visible:
		if not non_euclidean_map.visible: #bool responsible for changing from non-euclidean to normal
			map_state.append(true)
		else:
			map_state.append(false)
	else: #for switching between dark and blue map
		map_state.append(dark_map.visible)
		
	map_state.append(last_piece)
		
	Globals.map_state_log.append(map_state)
	
func load_prev(map_state, with_camera=false):
	var message = get_tree().root.find_child("Message", true, false)
	if message != null:
		message.queue_free()
	
	map_state.pop_back() #get rid of last piece
	
	#clearing saper
	Globals.bomb_clicked = false
	Globals.saper_count = 0
	SignalBus.emit_signal("rewind_numbers")
	SignalBus.emit_signal("rewind_bomb")
	
	#reading in which map you are
	if not dark_map.visible and not blue_map.visible:
		var in_normal = map_state.pop_back()
		wide_map.visible = in_normal
		non_euclidean_map.visible = !in_normal
		Globals.undraggable = !in_normal
		if in_normal: door_to_lapa()
		else: lapa_to_door()
	else:
		var in_dark = map_state.pop_back()
		if in_dark != dark_map.visible: with_camera = true #save camera if going through portal
		dark_map.visible = in_dark
		blue_map.visible = !in_dark
		if !blue_map.visible:
			dark_map.visible = false
			dark_map.visible = true
		ognik.dark_mode = in_dark
	
	#rewinding first map outer pieces
	first_map = map_state.pop_back()
	next_piece = map_state.pop_back()
	for i in range(next_piece, MAX_PIECES):
		var piece = base_map.get_child(i)
		piece.clickable = false
		piece.clear_affected()
		
	var camera_pos = map_state.pop_back()
	if with_camera:
		camera.global_position = camera_pos
		non_euclidean_map.global_position = camera.global_position - Vector2(960, 540) #teleport non-euclidean back
	
	if ognik.light.color.a != 0.0: #dark and blue map
		for i in range(len(blue_pieces.get_children()) - 1, -1, -1):
			var piece = blue_pieces.get_child(i)
			piece.stage = map_state.pop_back()
			piece.update(0)
		for i in range(len(dark_pieces.get_children()) - 1, -1, -1):
			var piece = dark_pieces.get_child(i)
			piece.stage = map_state.pop_back()
			piece.update(0)
	else: #normal map
		var non_euclidean_count = 9
		for i in range(len(map_state) - 2, -1, -1):
			if non_euclidean_count >= 0:
				var piece = non_euclidean_pieces.get_child(non_euclidean_count)
				piece.stage = map_state.pop_back()
				piece.update(0)
				non_euclidean_count -= 1
			else:
				var piece = base_map.get_child(i + 1)
				piece.stage = map_state.pop_back()
				piece.update(0)
				
	#changing portal button state
	var cur_button = dark_map.find_child("PortalButton")
	var prev_state = map_state.pop_back()
	if prev_state != cur_button.next_state:
		for i in range(abs(prev_state - cur_button.next_state)):
			cur_button.update_buttons(self, -1)
			
	#reestablish particles
	get_small_piece()

func _on_real_exit_button_up():
	var message = get_tree().root.find_child("Message", true, false)
	if message != null:
		message.queue_free()
		
	sfx.volume_db = -7.0
	
	var tween = get_tree().create_tween()
	tween.bind_node(self)
	screen_shadow.show()
#	$Camera2D/Endings.show()
#	$Camera2D/Endings.text = "TO BE CONTINUED"
	tween.tween_property(screen_shadow, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2.0)
#	tween.tween_property($Camera2D/Endings, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2.0)
	
	await tween.finished
	wide_map.hide()
	real_exit.hide()
	dark_map.show()
	
	blue_pieces.get_child(0).locked = true #need to disable infinite loop
	for piece in dark_pieces.get_children():
		piece.update(1)
	for upgraded_dark in [2]:
		var piece = dark_pieces.get_child(upgraded_dark)
		piece.update(1)
	for upgrade_blue in [1, 2]:
		var piece = blue_pieces.get_child(upgrade_blue)
		piece.update(1)
	blue_pieces.get_child(0).locked = false
	
	camera.global_position = Vector2(960, 540)
	if bgm.stream != plaza:
		bgm.stop()
	
	Globals.map_state_log.clear() #disabling old map states
	save_prev()
	
	await get_tree().create_timer(1.0, false).timeout
	screen_shadow.hide()
	screen_shadow.modulate.a = 0.0
	ognik.dark_mode = true
	var tween_light = get_tree().create_tween().bind_node(self)
	tween_light.tween_property(ognik.light, "color", Color(1.0, 0.68, 0.0, 1.0), 2.0)


func _on_door_button_up():
	if first_door:
		first_door = false
		var tween = get_tree().create_tween()
		tween.bind_node(self)
		$Door/AnimatedSprite2D.play("open")
		tween.tween_property($Door/AnimatedSprite2D, "global_position", Vector2(-3879, 350 + 184), 1.0)
	else:
		var tween = get_tree().create_tween().bind_node(self)
		screen_shadow.show()
		endings.show()
		endings.text = "ENDING 1"
		tween.tween_property(screen_shadow, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2.0)
		tween.tween_property(endings, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2.0)
		
		await tween.finished
		wide_map.hide()
		
func _on_dark_completed():
	var tween = get_tree().create_tween().bind_node(self)
	screen_shadow.show()
	endings.show()
	endings.text = "ENDING 2137"
	tween.tween_property(screen_shadow, "modulate", Color(1.0, 1.0, 1.0, 1.0), 3.0)
	tween.tween_property(endings, "modulate", Color(1.0, 1.0, 1.0, 1.0), 3.0)

func _on_menu_pressed():
	save_data(SAVE_DIR + SAVE_FILE_NAME)
	get_tree().change_scene_to_file("res://UI/menu.tscn")

