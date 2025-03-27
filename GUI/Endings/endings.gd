extends Control

@onready var scene_path : String = "res://GUI/Endings/Dialog.json"

@onready var label = $VBoxContainer/TextRim/VBoxContainer/Label
@onready var narrator = $VBoxContainer/Rim/BoxContainer/Narrator
@onready var neutrator = $VBoxContainer/Rim/BoxContainer/NarratorNeutral
@onready var sadtator = $VBoxContainer/Rim/BoxContainer3/NarratorSad
@onready var klepsydra = $VBoxContainer/Rim/KlepsydraLight
@onready var tbc = $VBoxContainer/Rim/BoxContainer2/TBC
@onready var kosmos = $VBoxContainer/Rim/TrueKosmos
@onready var choice_box = $VBoxContainer/TextRim/BoxContainer
@onready var choices = [$VBoxContainer/TextRim/BoxContainer/Label, $VBoxContainer/TextRim/BoxContainer/Label2,
						$VBoxContainer/TextRim/BoxContainer/Label3, $VBoxContainer/TextRim/BoxContainer/Label4]
@onready var new_texts = ["* Gdzie jesteśmy?", "* Co stało się z Reksiem?", "* Kim jestem?", "* Czym była ta klepsydra?"]

@onready var text_timer = $TextTimer

var scene_text = {}
var selected_text = []
var text : String

var letter_index = 0
var writting_in_progress = false

var choices_made = []

func _ready():
	scene_text = load_scene_text(scene_path)
#	display_dialog("TED")

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
				
func choice_clicked(index):
	clear_choices()
	if choices_made.is_empty():
		load_dialog("W1")
		choices_made = [1, 1, 1, 1]
		for c in choices:
			c.text = new_texts[c.get_index()]
		return
	match index:
		0:
			load_dialog("W2")
			choices_made[0] = 0
		1:
			load_dialog("W3")
			choices_made[1] = 0
		2:
			load_dialog("W4")
			choices_made[2] = 0
		3:
			load_dialog("W5")
			choices_made[3] = 0

func choice():
	if choices_made.is_empty():
		for c in choices:
			c.show()
	else:
		for i in range(len(choices_made)):
			choices[i].visible = choices_made[i]
			
	if choices_made == [0, 0, 0, 0]:
		display_dialog("PW")

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
	else:
		speaker = ""
	if "wybór" in parameters:
		choice()
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
				"narrator_neutral":
					show_sprite(neutrator)
				"narrator_sad":
					show_sprite(sadtator, 1.0)
				"tbc":
					show_sprite(tbc)
				"mu":
					var tween = get_tree().create_tween().bind_node(self)
					tween.tween_property(get_parent().bgm, "pitch_scale", 0.1, 1.0)
					tween.finished.connect(_on_tween_finished)
				"klepsydra_rotate":
					show_sprite(klepsydra)
					klepsydra.rotation_degrees = 180.0
					klepsydra.position += klepsydra.size
					var tween = get_tree().create_tween().bind_node(self)
					tween.tween_property(klepsydra, "self_modulate", Color(1, 0.345, 0.329), 5.0)
				"kosmos":
					show_sprite(kosmos)
					
	
	label.text += speaker
	writting_in_progress = true
	text_timer.start()
	
func show_sprite(sprite, t=2.0):
	clear()
	sprite.modulate.a = 0.0
	sprite.show()
	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(sprite, "modulate", Color.WHITE, t)
	
func clear():
	for sprite in [narrator, klepsydra, neutrator, sadtator]:
		if sprite.visible:
			var tween = get_tree().create_tween().bind_node(self)
			tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1.0)
			
func clear_choices():
	for c in choices:
		c.hide()
	
func finish(): #ending number
	pass
	
func load_dialog(text_key):
	selected_text = scene_text[text_key].duplicate()

func display_dialog(text_key):
	load_dialog(text_key)
	show_next()

func _on_text_timer_timeout():
	label.text += text[letter_index]
	letter_index += 1
	if letter_index == len(text):
		text_timer.stop()
		writting_in_progress = false
		
func _on_tween_finished():
	get_parent().bgm.stream = get_parent().mu
	get_parent().bgm.pitch_scale = 1.0
	get_parent().bgm.play()

