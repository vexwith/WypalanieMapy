extends Control

@onready var scene_path : String = "res://GUI/Endings/Dialog.json"

@onready var label = $VBoxContainer/TextRim/VBoxContainer/Label
@onready var narrator = $VBoxContainer/Rim/BoxContainer/Narrator
@onready var klepsydra = $VBoxContainer/Rim/KlepsydraLight
@onready var tbc = $VBoxContainer/Rim/BoxContainer2/TBC

@onready var text_timer = $TextTimer

var scene_text = {}
var selected_text = []
var text : String

var letter_index = 0
var writting_in_progress = false

func _ready():
	scene_text = load_scene_text(scene_path)
#	display_dialog("ED1")

func load_scene_text(scene_file):
	if FileAccess.file_exists(scene_file):
		var file = FileAccess.open(scene_file, FileAccess.READ)
		return JSON.parse_string(file.get_as_text())

func _input(event):
	if self.visible:
		if event.is_action_pressed("LPM"):
			if selected_text.size() > 0:
				show_next()
			else:
				finish()

func show_next():
	text_timer.stop()
	if writting_in_progress:
		writting_in_progress = false
		for l in range(letter_index, len(text)):
			label.text += text[l]
		return
	letter_index = 0
	
	var parameters = selected_text.pop_front()
	var speaker = parameters.pop_front()
	text = parameters.pop_front()
	if "cont" not in parameters: #clear text
		label.text = ""
	var sprite : String
	if parameters.size() > 0: #sprites
		sprite = parameters.pop_front()
		if sprite.is_valid_int():
			clear()
		else:
			match sprite:
				"klepsydra":
					show_sprite(klepsydra)
				"narrator":
					show_sprite(narrator)
				"tbc":
					show_sprite(tbc)
	
	label.text += speaker
	writting_in_progress = true
	text_timer.start()
	
func show_sprite(sprite):
	clear()
	sprite.modulate.a = 0.0
	sprite.show()
	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(sprite, "modulate", Color.WHITE, 2.0)
	
func clear():
	for sprite in [narrator, klepsydra]:
		if sprite.visible:
			var tween = get_tree().create_tween().bind_node(self)
			tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1.0)
	
func finish(): #ending number
	pass

func display_dialog(text_key):
	selected_text = scene_text[text_key].duplicate()
	show_next()

func _on_text_timer_timeout():
	label.text += text[letter_index]
	letter_index += 1
	if letter_index == len(text):
		text_timer.stop()
		writting_in_progress = false
