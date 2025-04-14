extends Control

const SAVE_DIR = "user://saves/"
const SAVE_FILE_NAME = "save_2.json"
const SECURITY_KEY = "092GSD2"

@onready var flame_scene = preload("res://Mapa/FireMap/flames.tscn")
@onready var hills = preload("res://Wavs/Mysterious Hills-(p).mp3")
@onready var mu = preload("res://Wavs/Sunken Continent of Mu (variation ⧸ reinterpretation of Bartek Broszs track) ｜ Rex and Captain Nemo-(p).mp3")
@onready var reverse_mapa = preload("res://Wavs/reversemapa.wav")
@onready var pieces = $Pieces
@onready var bgm = $BGM
@onready var sfx = $SFX
@onready var ognik = $Ognik
@onready var modulation = $CanvasModulate
@onready var shadow = $Shadow
@onready var endings = $Endings
@onready var spawn_timer = $SpawnTimer
@onready var spread_timer = $SpreadTimer

@onready var czynaptak = $CzyNaPtakLight

var frame_index = 0

var ptak_change = -1

func verify_save_directory(path : String):
	DirAccess.make_dir_absolute(path)
	
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

		Globals.map_pieces = data.player_data.map_pieces
		Globals.ending_one = data.player_data.ending_one
		
	else:
		printerr("Cannot open non-existent file at %s!" % [path])

func _ready():
	verify_save_directory(SAVE_DIR)
	load_data(SAVE_DIR + SAVE_FILE_NAME)
	
	SignalBus.connect("piece_clicked", _on_piece_clicked)
	
	Globals.detail_mode = true
	for i in range(len(pieces.get_children())):
		var piece = pieces.get_child(i)
		if Globals.map_pieces.values()[i]:
			piece.rim.z_index = 1
			match i:
				1:
					modulation.color = Color.BLACK
					ognik.dark_mode = true
					ognik.light.color = Color(1, 0.7, 0.5)
				2:
					var flame = flame_scene.instantiate()
					piece.add_child(flame)
					flame.hide()
					spawn_timer.start()
						
		else:
			piece.clickable = false
			piece.find_child("Rim2").hide()
		piece.sprite.modulate.a = 0.7
		
	for piece in pieces.get_children():
		for affected_index in range(len(piece.affected_pieces)-1, -1, -1):
			var affected = piece.affected_pieces[affected_index]
			if not pieces.get_child(affected).clickable:
				piece.affected_pieces.remove_at(affected_index)
		
	bgm.play()

func _on_audio_stream_player_finished():
	bgm.play()


func _on_exit_button_up():
	Globals.ignore_clicks = false
	get_tree().change_scene_to_file("res://UI/menu.tscn")


func _on_reset_button_up():
	Globals.ignore_clicks = false
	get_tree().reload_current_scene()

func _on_spawn_timer_timeout():
	var fire_piece = pieces.get_child(2)
	if fire_piece.stage < 5:
		var flame = fire_piece.get_child(5)
		flame.show()
		spread_timer.start()

func _on_spread_timer_timeout():
	var flame = pieces.get_child(2).get_child(5)
	if flame.visible:
		flame.hide()
		pieces.get_child(2).update(1)
	spawn_timer.start()
		
func failed(piece):
	if piece.stage in [5, 6]:
		return true
	for i in piece.affected_pieces:
		if piece.get_parent().get_child(i).stage in [5, 6]:
			return true
	return false
		
func _on_piece_clicked(piece):
	if piece == pieces.get_child(2):
		var fire_piece = pieces.get_child(2)
		var flame = fire_piece.get_child(5)
		if flame.visible:
			flame.hide()
			fire_piece.undo_move()
	else:
		var cur_ptak = pieces.get_child(4).stage
		if cur_ptak <= 5 and cur_ptak > ptak_change:
			ptak_change = cur_ptak
			Globals.ignore_clicks = true
			var r = randi_range(0, len(czynaptak.get_children()) - 1)
			czynaptak.get_child(r).run()
			
	if piece == pieces.get_child(0): #blue
		modulation.color = Color(0, 0, 0.647)
		ognik.dark_mode = false
	elif piece == pieces.get_child(1): #dark
		modulation.color = Color.BLACK
		ognik.dark_mode = true
		
	if failed(piece):
		sfx.play()
		
	if win_condition():
		true_ending()
		
func true_ending():
	var temp_vol = bgm.volume_db
	Globals.detail_mode = false
	pieces.hide()
	shadow.show()
	#ognik
	modulation.color = Color.WHITE
	ognik.dark_mode = false
	ognik.przedmioty["ognik"] = false
	ognik.przedmioty["lapa"] = true
	#flame
	spawn_timer.stop()
	spread_timer.stop()
	var flame = pieces.get_child(2).get_child(5)
	flame.hide()
	
	var tween = get_tree().create_tween().set_parallel().bind_node(self)
	var t = 2.0
	tween.tween_property(shadow, "modulate", Color.WHITE, t)
	tween.tween_property(bgm, "volume_db", -15.0, t)
	
	await tween.finished
	bgm.stream = hills
	bgm.volume_db = temp_vol
	bgm.play()
	endings.show()
	
	var tween2 = get_tree().create_tween().bind_node(self)
	tween2.tween_property(shadow, "modulate", Color(1.0, 1.0, 1.0, 0.0), t/2)
	
	await tween2.finished
	shadow.hide()
	if Globals.ending_one:
		endings.display_dialog("TED")
	else:
		endings.display_dialog("TED2")

func win_condition():
	for piece in pieces.get_children():
		if piece.stage not in [3, 4]:
			return false
	return true
