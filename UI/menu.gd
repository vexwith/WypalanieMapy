extends Control

const SAVE_DIR = "user://saves/"
const SAVE_FILE_NAME = "save_2.json"

@onready var cursor = preload("res://Ognik/cursor_0.png")

@onready var secret = $Secret
@onready var shadow = $Shadow
@onready var label = $Label

var tekst = ["REKSIU OCKNIJ SIĘ", "PRZED WYRUSZENIEM W DROGĘ NALEŻY WYPALIĆ MAPĘ, KTÓRĄ ZNALAZŁEŹ W BUTELCE",
			 "SPOKOJNIE, NA PEWNO CI SIĘ UDA"]
var tekst_index = 0
var tekst_time = 2.0
var temp_vol

func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -5.9)
	Globals.crawl_mode = false
	Globals.fire_mode = false
	Bgm.stop()
	Input.set_custom_mouse_cursor(cursor)
	
	if not $AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()
	
	if not FileAccess.file_exists(SAVE_DIR + SAVE_FILE_NAME):
		$Controls/VBoxContainer/Continue.disabled = true
		secret.hide()
		
func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
		
func _on_new_game_pressed():
	if FileAccess.file_exists(SAVE_DIR + SAVE_FILE_NAME):
		$Controls/ConfirmNewGame.show()
		$Controls/ConfirmText.show()
	else:
		start_new_game()

func _on_yes_pressed():
	start_new_game()

func _on_no_pressed():
	$Controls/ConfirmNewGame.hide()
	$Controls/ConfirmText.hide()
	
func start_new_game():
	Globals.ignore_clicks = false
	#reset meta globals
	Globals.lapa_gained = false
	Globals.return_trapped = false
	Globals.first_enter = true
	Globals.first_restart = true
	Globals.say_restart = false
	Globals.ending_one = true
	Globals.wypalenia = 0
	for key in Globals.map_pieces.keys():
		Globals.map_pieces[key] = false

	Globals.kontynuuj = false
	
	#new game start text
	shadow.show()
	temp_vol = $AudioStreamPlayer.volume_db
	var tween = get_tree().create_tween().set_parallel().bind_node(self)
	tween.finished.connect(_on_label_start)
	tween.tween_property(shadow, "modulate", Color.WHITE, tekst_time)
	tween.tween_property($AudioStreamPlayer, "volume_db", -15.0, tekst_time)
	
	
func _on_continue_pressed():
	Globals.kontynuuj = true
	get_tree().change_scene_to_file("res://game_manager.tscn")


func _on_tutorial_pressed():
	get_tree().change_scene_to_file("res://Tutorial/tutorial.tscn")


func _on_exit_pressed():
	get_tree().quit()


func _on_secret_button_up():
	get_tree().change_scene_to_file("res://Mapa/MetaMap/meta_mapa.tscn")
	
	
func _on_label_start():
	if tekst_index == tekst.size():
		get_tree().change_scene_to_file("res://game_manager.tscn")
	else:
		$AudioStreamPlayer.volume_db = temp_vol
		$AudioStreamPlayer.stop()
		label.text = tekst[tekst_index]
		var tween = get_tree().create_tween().bind_node(self)
		tween.finished.connect(_on_label_change)
		tween.tween_property(label, "modulate", Color.WHITE, tekst_time)
	

func _on_label_change():
	tekst_index += 1
	var tween = get_tree().create_tween().bind_node(self)
	tween.finished.connect(_on_label_start)
	tween.tween_property(label, "modulate", Color(1.0, 1.0, 1.0, 0.0), 3.0)
