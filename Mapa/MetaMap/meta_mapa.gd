extends Control

const SAVE_DIR = "user://saves/"
const SAVE_FILE_NAME = "save.json"
const SECURITY_KEY = "092GSD2"

@onready var pieces = $Pieces

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
		
	else:
		printerr("Cannot open non-existent file at %s!" % [path])

func _ready():
	verify_save_directory(SAVE_DIR)
	load_data(SAVE_DIR + SAVE_FILE_NAME)
	
	Globals.detail_mode = true
	for i in range(len(pieces.get_children())):
		var piece = pieces.get_child(i)
		if Globals.map_pieces.values()[i]:
			pass
		else:
			piece.clickable = false
		piece.sprite.modulate.a = 0.7
		
