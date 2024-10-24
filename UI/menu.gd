extends Control

@onready var cursor = preload("res://Ognik/cursor_0.png")

const SAVE_DIR = "user://saves/"
const SAVE_FILE_NAME = "save.json"

func _ready():
	Bgm.stop()
	Input.set_custom_mouse_cursor(cursor)
	
	if not $AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()
	
	if not FileAccess.file_exists(SAVE_DIR + SAVE_FILE_NAME):
		$Controls/VBoxContainer/Continue.disabled = true
		
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
	Globals.wypalenia = 0
	for key in Globals.map_pieces.keys():
		Globals.map_pieces[key] = false

	Globals.kontynuuj = false
	get_tree().change_scene_to_file("res://game_manager.tscn")

func _on_continue_pressed():
	Globals.crawl_mode = false
	Globals.kontynuuj = true
	get_tree().change_scene_to_file("res://game_manager.tscn")


func _on_tutorial_pressed():
	get_tree().change_scene_to_file("res://Tutorial/tutorial.tscn")


func _on_exit_pressed():
	get_tree().quit()




