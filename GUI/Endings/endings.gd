extends Control

@onready var scene_path : String = "res://GUI/Endings/Dialog.json"

@onready var label = $VBoxContainer/TextRim/VBoxContainer/Label
@onready var narrator = $VBoxContainer/Rim/BoxContainer/Narrator
@onready var neutrator = $VBoxContainer/Rim/BoxContainer5/NarratorNeutral
@onready var sadtator = $VBoxContainer/Rim/BoxContainer3/NarratorSad
@onready var deadtator = $VBoxContainer/Rim/BoxContainer4/NarratorDead
@onready var happyator = $VBoxContainer/Rim/BoxContainer4/NarratorHappy
@onready var klepsydra = $VBoxContainer/Rim/KlepsydraLight
@onready var tbc = $VBoxContainer/Rim/BoxContainer2/TBC
@onready var kosmos = $VBoxContainer/Rim/TrueKosmos
@onready var choice_box = $VBoxContainer/TextRim/BoxContainer
@onready var last_choice_box = $VBoxContainer/TextRim/GridContainer
@onready var choices = [$VBoxContainer/TextRim/BoxContainer/Label, $VBoxContainer/TextRim/BoxContainer/Label2,
						$VBoxContainer/TextRim/BoxContainer/Label3, $VBoxContainer/TextRim/BoxContainer/Label4]
@onready var new_texts = ["* Gdzie jesteśmy?", "* Co stało się z Reksiem?", "* Kim jestem?", "* Czym była ta klepsydra?"]
@onready var moletters = $Messages

@onready var text_timer = $TextTimer

@onready var white_shadow = $WhiteShadow
@onready var end = $EndTimes

var scene_text = {}
var selected_text = []
var text : String

var letter_index = 0
var writting_in_progress = false

var choices_made = []

var message_index = 0

func _ready():
	scene_text = load_scene_text(scene_path)
	
	for letter in moletters.get_children():
		letter.hide()
#	display_dialog("OW2")

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
				
func message_clicked():
	display_dialog("M"+str(message_index))
				
func show_message():
	for letter in moletters.get_children():
		letter.hide()
		
	moletters.get_child(message_index).show()
	message_index += 1
				
func choice_clicked(index):
	clear_choices()
#	if choices_made == [0, 0, 0, 0]:
	match index:
		0:
			load_dialog("OW1")
		1:
			load_dialog("OW2")
	return
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
	if "wybór2" in parameters:
		last_choice_box.show()
	if "end" in parameters:
		ending()
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
				"narrator_dead":
					show_sprite(deadtator, 1.0)
				"narrator_happy":
					show_sprite(happyator)
				"tbc":
					show_sprite(tbc)
				"kosmos":
					show_sprite(kosmos)
				"mu":
					var tween = get_tree().create_tween().bind_node(self)
					tween.tween_property(get_parent().bgm, "pitch_scale", 0.1, 1.0)
					tween.finished.connect(_on_tween_finished_mu)
				"hills":
					var tween = get_tree().create_tween().bind_node(self)
					tween.tween_property(get_parent().bgm, "volume_db", -15.0, 1.0)
					tween.finished.connect(_on_tween_finished_hills)
				"reverse_mapa":
					var tween = get_tree().create_tween().bind_node(self)
					tween.tween_property(get_parent().bgm, "volume_db", -15.0, 1.0)
					tween.finished.connect(_on_tween_finished_map)
				"silence":
					get_parent().bgm.pitch_scale = 0.15
					get_parent().bgm.play(213)
				"klepsydra_rotate":
					show_sprite(klepsydra)
					klepsydra.rotation_degrees = 180.0
					klepsydra.position += klepsydra.size
					var tween = get_tree().create_tween().bind_node(self)
					tween.tween_property(klepsydra, "self_modulate", Color(1, 0.345, 0.329), 5.0)
				"klepsydra_future":
					show_sprite(klepsydra)
					klepsydra.rotation_degrees = 0.0
					klepsydra.position -= klepsydra.size
					var tween = get_tree().create_tween().bind_node(self)
					tween.tween_property(klepsydra, "self_modulate", Color(0.996, 0.91, 0.157), 5.0)
				"message":
					show_message()
					
	
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
	for sprite in [narrator, klepsydra, neutrator, sadtator, deadtator, happyator]:
		if sprite.visible:
			var tween = get_tree().create_tween().bind_node(self)
			tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1.0)
			
func clear_choices():
	for c in choices:
		c.hide()
		
	last_choice_box.hide()
	
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
		
func _on_tween_finished_mu():
	var m = get_parent()
	m.bgm.stream = m.mu
	m.bgm.pitch_scale = 1.0
	m.bgm.play()
	
func _on_tween_finished_hills():
	var m = get_parent()
	m.bgm.stream = m.hills
	m.bgm.volume_db = -5.0
	m.bgm.play()
	
func _on_tween_finished_map():
	var m = get_parent()
	m.bgm.stream = m.reverse_mapa
	m.bgm.play()
	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(m.bgm, "volume_db", 0.0, 1.0)

func ending():
	white_shadow.modulate.a = 0.0
	white_shadow.show()
	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(white_shadow, "modulate", Color.WHITE, 6.0)
	
	await tween.finished
	end.modulate.a = 0.0
	end.show()
	var tween2 = get_tree().create_tween().bind_node(self)
	tween2.tween_property(end, "modulate", Color.WHITE, 3.0)
	
	await tween2.finished
	await get_tree().create_timer(5.0).timeout
	get_tree().quit()
