extends Node2D

const SAVE_DIR = "user://saves/"
const SAVE_FILE_NAME = "save.json"
const SECURITY_KEY = "092GSD2"

@onready var bgm = Bgm
@onready var plaza = preload("res://Wavs/Reksio i Skarb Piratów OST - Muza1-(p).mp3")
@onready var medley = preload("res://Wavs/Reksio i Skarb Piratów Medley (Tomasz Jachowicz cover ⧸ variation by KKR)-(p).mp3")
@onready var hills = preload("res://Wavs/Mysterious Hills-(p).mp3")

@onready var sfx = $SFX
@onready var ojoj = preload("res://Wavs/6dziura.wav")
@onready var dobrze = preload("res://Wavs/6entre.wav")
@onready var rozumiem = preload("res://Wavs/6failed.wav")
@onready var win = preload("res://Wavs/win.wav")
@onready var mina_setup = preload("res://Wavs/00ekran.wav")
@onready var mina_wybuch = preload("res://Wavs/explosion-91872.mp3")
@onready var postmapa = preload("res://Mapa/bkg_postlapa2.png")

@onready var message_scene = preload("res://Items/message.tscn")

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

@onready var ognik = $Ognik
@onready var camera = $Camera2D
@onready var reset = $Camera2D/ResetButton
@onready var exit = $Camera2D/Wyjście
@onready var real_exit = $Camera2D/RealExit
@onready var hills_exit = $HillsExit
@onready var lapa_button = $Camera2D/LapaButton
@onready var key_one = $Camera2D/OgnikButton/Sprite2D
@onready var small_piece = $SmallPiece
@onready var menu = $Camera2D/Menu

var camera_limits = [-624, -684, 2544, 1764]
var reset_pos = Vector2(495, 413)

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
			"wypalenia" : Globals.wypalenia,
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
		Globals.wypalenia = data.player_data.wypalenia
		Globals.map_pieces = data.player_data.map_pieces
		
#		Globals.map_state_log = data.map_data.map_state_log
		
	else:
		printerr("Cannot open non-existent file at %s!" % [path])

func _ready():
	SignalBus.connect("piece_clicked", _on_piece_clicked)
	SignalBus.connect("non_euclidean_clicked", _on_non_euclidean_clicked)
	verify_save_directory(SAVE_DIR)
	if Globals.kontynuuj:
		Globals.kontynuuj = false
		_on_reset_button_pressed()
		load_data(SAVE_DIR + SAVE_FILE_NAME)
		get_tree().reload_current_scene()
	
#	MAX_PIECES = base_map.get_child_count()
	upgrade_to_wide_map()
	if not Globals.lapa_gained:
		lapa_button.hide()
		key_one.hide()
		sfx.volume_db = 0.0
	else:
		start_flying_piece()
		base_map.get_child(0).texture = postmapa
		if bgm.stream == plaza:
			bgm.stop()
		sfx.volume_db = -7.0
		plaza_version = 9 #reset
		
		var tween = get_tree().create_tween()
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
		if Globals.crawl_mode:
			bgm.stream = hills
			plaza_version = 9 #reset
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
	
func _input(event): #dragging hamdler
	if event.is_action_pressed("ui_cancel"): #esc to end
		_on_menu_pressed()
		
	if event.is_action_pressed("rewind") and not Globals.crawl_mode:
		if Globals.lapa_gained or between_maps:
			if len(Globals.map_state_log) > 1:
				var cur_state = Globals.map_state_log.pop_back()
				
				for piece in base_map.get_children():
					if piece is Area2D:
						piece.sprite.self_modulate = Color.WHITE
				var last = cur_state.pop_back()
				if last != null:
					last.sprite.self_modulate = Color.PALE_GREEN
				
				var prev_state = Globals.map_state_log[-1].duplicate()
				load_prev(prev_state)
			elif len(Globals.map_state_log) == 1:
				var prev_state = Globals.map_state_log[-1].duplicate()
				load_prev(prev_state)
			
	if event.is_action_pressed("1"):
		if not Globals.trapped:
			_on_ognik_button_button_up()
			Globals.ignore_clicks = false
		
	if event.is_action_pressed("2"):
		if not Globals.crawl_mode and Globals.lapa_gained:
			_on_lapa_button_button_up()
			
	if event.is_action_pressed("restart"):
		_on_reset_button_pressed()
		
	if event.is_action_pressed("ctrl"):
		Globals.detail_mode = !Globals.detail_mode
#		$Camera2D/DetailShadow.color.a = 0.4
#	if event.is_action_released("ctrl"):
#		Globals.detail_mode = false
#		$Camera2D/DetailShadow.color.a = 0.0
		
			
	#dragging
	if not Globals.crawl_mode and not Globals.trapped:
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

func failed(piece):
	if piece.stage == 5 or piece.stage == 6:
		Globals.wypalenia += 1
		if Globals.wypalenia == 3:
			var message = message_scene.instantiate()
			get_tree().root.add_child(message)
			message.global_position = piece.global_position
		return true
		
	if not 'low_pos' in piece:
		for i in piece.affected_pieces:
			var affected = base_map.get_child(i)
			if affected.stage == 5 or affected.stage == 6:
				return true
		
	return false
	
func _on_piece_clicked(clicked_piece):
	get_small_piece()
	
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
				var tween = get_tree().create_tween()
				tween.tween_property(piece, "position", Vector2(piece.position.x, piece.position.y - 70), 2.0)
#				piece.position.y -= 70
			for down in [9, 55, 32]:
				var piece = clouds.find_child("Cloud" + str(down))
				var tween = get_tree().create_tween()
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
		var tween = get_tree().create_tween().set_parallel(true)
		tween.tween_property(camera, "global_position", clicked_piece.global_position, 1.0)
		tween.tween_property(camera, "zoom", Vector2(2.0, 2.0), 1.0)
		tween.tween_property(bgm, "pitch_scale", 0.1, 1.0)
		await tween.finished
		hills_exit.show()
		reset.modulate.a = 0.0
		reset.position = Vector2(371, 160)
		var tween2 = get_tree().create_tween().set_parallel(true)
		tween2.tween_property(reset, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.0)
		tween2.tween_property(hills_exit, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.0)
		bgm.stop()
		bgm.pitch_scale = 1.0
		
	elif Globals.crawl_mode:
		var tween = get_tree().create_tween()
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
			
	#saving map state
	if clicked_piece.get_index() not in range(25, 40) and not Globals.crawl_mode: #if not inside saper or hills
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
	
	var tween = get_tree().create_tween().set_parallel(true)
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
	var door_rect = Rect2(0, 0, 43, 51)
	lapa_button.get_theme_stylebox("normal").texture = lapa_exit_normal
	lapa_button.get_theme_stylebox("normal").region_rect = door_rect
	lapa_button.get_theme_stylebox("hover").texture = lapa_exit_hover
	lapa_button.get_theme_stylebox("hover").region_rect = door_rect
	
	
	Globals.undraggable = true
	
func back_from_non_euclidean():
	Globals.undraggable = false
	non_euclidean_map.hide()
	wide_map.show()
	draggable = true
	
	var door_rect = Rect2(2, 2, 53, 52)
	lapa_button.get_theme_stylebox("normal").texture = lapa_button_normal
	lapa_button.get_theme_stylebox("normal").region_rect = door_rect
	lapa_button.get_theme_stylebox("hover").texture = lapa_button_hover
	lapa_button.get_theme_stylebox("hover").region_rect = door_rect
	
	if non_euclidean_completed():
		var teleport = base_map.get_child(41)
		teleport.stage = 4
		teleport.sprite.play(str(teleport.stage))
		_on_piece_clicked(teleport)

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
	var tween = get_tree().create_tween().set_parallel(true)
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

func _on_reset_button_pressed():
	if Globals.crawl_mode:
		_on_hills_exit_button_up()
		return
		
	Globals.map_state_log.clear()
	Globals.focused_piece = null
	Globals.ignore_clicks = false
	Globals.undraggable = false
	Globals.bomb_clicked = false
	Globals.saper_count = 0
	Globals.trapped = false
	
#	if Globals.crawl_mode:
#		Globals.crawl_mode = false
#		bgm.stop()
	
	if Globals.first_restart:
		Globals.first_restart = false
		Globals.say_restart = true
		
	get_tree().reload_current_scene()
	
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
	
func save_prev():
	var map_state = []
	for piece in base_map.get_children():
		if piece is Area2D:
			map_state.append(piece.stage)
	for non_euclidean_piece in non_euclidean_pieces.get_children():
		map_state.append(non_euclidean_piece.stage)
		
	map_state.append(camera.global_position)
	map_state.append(next_piece)
	map_state.append(first_map)
	
	if not non_euclidean_map.visible: #bool responsible for changing from non-euclidean to normal
		map_state.append(true)
	else:
		map_state.append(false)
		
	map_state.append(last_piece)
		
	Globals.map_state_log.append(map_state)
	
func load_prev(map_state):
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
	var in_normal = map_state.pop_back()
	wide_map.visible = in_normal
	non_euclidean_map.visible = !in_normal
	Globals.undraggable = !in_normal
	
	#rewinding first map outer pieces
	first_map = map_state.pop_back()
	next_piece = map_state.pop_back()
	for i in range(next_piece, MAX_PIECES):
		var piece = base_map.get_child(i)
		piece.clickable = false
		piece.clear_affected()
		
	var camera_pos = map_state.pop_back()
	camera.global_position = camera_pos
	non_euclidean_map.global_position = camera.global_position - Vector2(960, 540) #teleport non-euclidean back
	
	var non_euclidean_count = 9
	for i in range(len(map_state) - 1, -1, -1):
		if non_euclidean_count >= 0:
			var piece = non_euclidean_pieces.get_child(non_euclidean_count)
			piece.stage = map_state.pop_back()
			piece.update(0)
			non_euclidean_count -= 1
		else:
			var piece = base_map.get_child(i + 1)
			piece.stage = map_state.pop_back()
			piece.update(0)
			
	#reestablish particles
	get_small_piece()

func _on_real_exit_button_up():
	var tween = get_tree().create_tween()
	$Camera2D/Shadow.show()
	$Camera2D/Endings.show()
	$Camera2D/Endings.text = "TO BE CONTINUED"
	tween.tween_property($Camera2D/Shadow, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2.0)
	tween.tween_property($Camera2D/Endings, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2.0)
	
	await tween.finished
	wide_map.hide()


func _on_door_button_up():
	if first_door:
		first_door = false
		var tween = get_tree().create_tween()
		$Door/AnimatedSprite2D.play("open")
		tween.tween_property($Door/AnimatedSprite2D, "global_position", Vector2(-3879, 350 + 184), 1.0)
	else:
		var tween = get_tree().create_tween()
		$Camera2D/Shadow.show()
		$Camera2D/Endings.show()
		$Camera2D/Endings.text = "ENDING 1"
		tween.tween_property($Camera2D/Shadow, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2.0)
		tween.tween_property($Camera2D/Endings, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2.0)
		
		await tween.finished
		wide_map.hide()

func _on_menu_pressed():
	save_data(SAVE_DIR + SAVE_FILE_NAME)
	get_tree().change_scene_to_file("res://UI/menu.tscn")
